import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

enum _PortDirection {
  input(forInternalUsage: true),
  output(),
  inOut(forInternalUsage: true);

  final bool forInternalUsage;

  const _PortDirection({this.forInternalUsage = false});

  String get moduleAccessorName => name;

  String toAnnotationName() {
    switch (this) {
      case _PortDirection.input:
        return 'Input';
      case _PortDirection.output:
        return 'Output';
      case _PortDirection.inOut:
        return 'InOut';
    }
  }

  static _PortDirection ofAnnotationName(String annotationName) {
    switch (annotationName) {
      case 'Input':
        return _PortDirection.input;
      case 'Output':
        return _PortDirection.output;
      case 'InOut':
        return _PortDirection.inOut;
      default:
        throw ArgumentError(
            'Unknown port direction annotation name: $annotationName');
    }
  }
}

enum _PortInfoOrigin {
  constructorArgAnnotation,
  // classAnnotation, // TODO: remove this?
  fieldAnnotation,
}

class _PortInfo {
  final _PortDirection direction;
  final _PortInfoOrigin origin;
  final GenInfoExtracted genInfo;

  _PortInfo({
    required this.genInfo,
    required this.direction,
    required this.origin,
  });

  String get createConditionName => genInfo.isConditional
      ? '${genInfo.name}IsPresent'
      : throw Exception('Should not be called for non-conditional ports');

  /// The name of a signal to use as the source for addInput, addInOut, etc.
  String get sourceName => switch (origin) {
        // _PortInfoOrigin.classAnnotation => '${genInfo.name}Source',
        _PortInfoOrigin.constructorArgAnnotation => genInfo.name,
        _PortInfoOrigin.fieldAnnotation => '${genInfo.name}Source',
      };

  /// Indicates that the generated base class should include a [sourceName]
  /// argument for driving the input/inout.
  bool get needsSourceParameter =>
      origin == _PortInfoOrigin.fieldAnnotation &&
      (direction == _PortDirection.input ||
          direction == _PortDirection.inOut) &&
      genInfo.logicType == LogicType.typed;

  FormalParameter? get sourceParameter {
    if (!needsSourceParameter) {
      return null;
    }

    final isRequired = genInfo.structDefaultConstructorType ==
        StructDefaultConstructorType.unusable;

    return FormalParameter(
      paramType: isRequired ? ParamType.namedRequired : ParamType.namedOptional,
      name: sourceName,
      varLocation:
          isRequired ? ParamVarLocation.this_ : ParamVarLocation.constructor,
      type: genInfo.typeName,
      isNullable: genInfo.structDefaultConstructorType !=
          StructDefaultConstructorType.unusable,
    );
  }

  String moduleAccessor() {
    // TODO: handle structs
    var accessorFunction = switch (direction) {
      _PortDirection.input => 'input',
      _PortDirection.output => 'output',
      _PortDirection.inOut => 'inOut'
    };

    final buffer = StringBuffer();

    if (genInfo.description != null) {
      buffer.writeln(genMultilineDocComment(genInfo.description!));
    }
    if (direction.forInternalUsage) {
      buffer.writeln('@protected');
    }

    var type = genInfo.typeName;

    if (genInfo.isConditional) {
      final capsVersion =
          accessorFunction[0].toUpperCase() + accessorFunction.substring(1);
      accessorFunction = 'try$capsVersion';

      type += '?';
    }

    var castStr = '';
    if (genInfo.logicType != LogicType.logic) {
      castStr = ' as $type';
    }

    if (origin == _PortInfoOrigin.fieldAnnotation) {
      buffer.writeln('@visibleForOverriding '
          'set ${genInfo.name}($type ${genInfo.name});');
    } else {
      buffer.writeln('$type get ${genInfo.name} =>'
          " $accessorFunction('${genInfo.logicName}')$castStr;");
    }

    if (direction == _PortDirection.input ||
        direction == _PortDirection.inOut) {
      // we need to declare the source variable
      buffer.writeln(
          '/// The [${accessorFunction}Source] for the [${genInfo.name}] port.');

      switch (origin) {
        case _PortInfoOrigin.constructorArgAnnotation:
          // this is coming from the constructor arg, so just access
          buffer.writeln('$type get ${genInfo.name}Source =>'
              " ${accessorFunction}Source('${genInfo.logicName}');");

        case _PortInfoOrigin.fieldAnnotation:
          // this needs to be constructed in the constructor
          final constructorCall =
              //TODO: what about when struct can't be made?
              genInfo.genConstructorCall(naming: Naming.mergeable);

          buffer.writeln('late final $type $sourceName;');
      }
    }

    return buffer.toString();
  }

  String modulePortCreator() {
    final buffer = StringBuffer();
    final creator = switch (direction) {
      _PortDirection.input => switch (genInfo.logicType) {
          LogicType.logic => 'addInput',
          LogicType.array => 'addInputArray',
          LogicType.typed => 'addTypedInput',
        },
      _PortDirection.output => switch (genInfo.logicType) {
          LogicType.logic => 'addOutput',
          LogicType.array => 'addOutputArray',
          LogicType.typed => 'addTypedOutput',
        },
      _PortDirection.inOut => switch (genInfo.logicType) {
          LogicType.logic => 'addInOut',
          LogicType.array => 'addInOutArray',
          LogicType.typed => 'addTypedInOut',
        },
    };

    var sourceStr = switch (genInfo.logicType) {
      LogicType.logic || LogicType.array => switch (direction) {
          _PortDirection.input || _PortDirection.inOut => ', $sourceName',
          _PortDirection.output => '',
        },
      LogicType.typed => ', $sourceName',
    };

    // create the source here, if necessary
    switch (origin) {
      case _PortInfoOrigin.fieldAnnotation:
        switch (direction) {
          case _PortDirection.input || _PortDirection.inOut:
            final constructorCall =
                //TODO: what about when struct can't be made?
                genInfo.genConstructorCall(naming: Naming.mergeable);

            //TODO: doc that if source is provided, then create/`Present` is not relevant

            final sourceConstructionString = switch (genInfo.isConditional) {
              true => ' $createConditionName ? $constructorCall : null',
              false => constructorCall,
            };

            if (genInfo.logicType == LogicType.typed) {
              assert(
                  needsSourceParameter, 'Should only get here if we need it.');

              if (!sourceParameter!.paramType.isRequired) {
                // if it's required, we don't need to do anything, `this.`
                final addSourceName = 'this.$sourceName';
                sourceStr = ', $addSourceName';

                buffer.writeln('$addSourceName ='
                    ' $sourceName ?? ($sourceConstructionString);');
              }
            } else {
              buffer.writeln('$sourceName = $sourceConstructionString;');
            }

            if (genInfo.isConditional) {
              sourceStr += '!';
            }

          case _PortDirection.output:
            break;
        }

      case _PortInfoOrigin.constructorArgAnnotation:
        break;
    }

    final portCreationString = "$creator('${genInfo.logicName}' $sourceStr"
        ' ${genInfo.widthString(isLogicConstructor: false)})';

    buffer.writeln(switch (genInfo.isConditional) {
      true => switch (origin) {
          _PortInfoOrigin.constructorArgAnnotation =>
            'if(${genInfo.name} != null) { $portCreationString; }',
          _PortInfoOrigin.fieldAnnotation => '${genInfo.name} ='
              ' $createConditionName ? $portCreationString : null;',
        },
      false => switch (origin) {
          _PortInfoOrigin.constructorArgAnnotation => '$portCreationString;',
          _PortInfoOrigin.fieldAnnotation =>
            '${genInfo.name} = $portCreationString;',
        },
    });

    return buffer.toString();
  }

  static _PortInfo? ofAnnotated<T>(
    T t,
    GenInfoExtracted? Function(T, String annotationName) ofT,
    _PortInfoOrigin origin,
  ) {
    for (final portDirection in _PortDirection.values) {
      final genInfo = ofT(
        t,
        portDirection.toAnnotationName(),
      );

      if (genInfo != null) {
        return _PortInfo(
          genInfo: genInfo,
          direction: portDirection,
          origin: origin,
        );
      }
    }
    return null;
  }

  static _PortInfo? ofAnnotatedParameter(FormalParameterElement param) =>
      ofAnnotated(param, GenInfoExtracted.ofAnnotatedParameter,
          _PortInfoOrigin.constructorArgAnnotation);

  static _PortInfo? ofAnnotatedField(FieldElement2 field) => ofAnnotated(field,
      GenInfoExtracted.ofAnnotatedField, _PortInfoOrigin.fieldAnnotation);

  //TODO: add support for List<Logic> things, will be convenient I think.
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  static List<_PortInfo> _extractPortsFromConstructor(
      ConstructorElement2 constructor) {
    final portInfos = <_PortInfo>[];
    for (final param in constructor.formalParameters) {
      final portInfo = _PortInfo.ofAnnotatedParameter(param);
      if (portInfo != null) {
        portInfos.add(portInfo);
      }
    }
    return portInfos;
  }

  static List<_PortInfo> _extractPortsFromAnnotatedFields(Element2 element) {
    final portInfos = <_PortInfo>[];
    if (element is ClassElement2) {
      for (final field in element.fields2) {
        final portInfo = _PortInfo.ofAnnotatedField(field);

        if (portInfo != null) {
          portInfos.add(portInfo);
        }
      }
    }
    return portInfos;
  }

  @override
  String generateForAnnotatedElement(
      Element2 element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name3!;
    final genClassName = '_\$$sourceClassName';

    final superParams = <SuperParameter>[];
    final constructorParams = <FormalParameter>[];

    final portInfos = <_PortInfo>[
      // ..._extractPortsFromAnnotation(annotation),
      ..._extractPortsFromAnnotatedFields(element),
    ];

    final classElement = element as ClassElement2;

    for (final constructor in classElement.constructors2
        .where((c) => !c.isFactory && !c.isSynthetic)) {
      portInfos.addAll(_extractPortsFromConstructor(constructor));
    }

    // any constructor args need to be listed as parameters in the constructor
    for (final portInfo in portInfos
        .where((p) => p.origin == _PortInfoOrigin.constructorArgAnnotation)) {
      constructorParams.add(FormalParameter(
        paramType: portInfo.genInfo.paramType!,
        name: portInfo.genInfo.name,
        varLocation: ParamVarLocation.constructor,
        type: portInfo.genInfo.typeName,
        isNullable: portInfo.genInfo.isConditional,
      ));
    }

    // Extract baseConstructor from the annotation
    final baseConstructor = annotation.peek('baseConstructor')?.objectValue;
    final String baseClassName;
    final String superConstructor;

    if (baseConstructor == null) {
      // can't tear-off `Module.new` since it's abstract, so set up manually
      baseClassName = 'Module';
      superConstructor = 'super';
      const moduleBaseParams = [
        'name',
        'reserveName',
        'definitionName',
        'reserveDefinitionName',
      ];
      constructorParams.addAll(moduleBaseParams.map(
        (name) => FormalParameter(
          paramType: ParamType.namedOptional,
          name: name,
          varLocation: ParamVarLocation.super_,
          type: null,
        ),
      ));
    } else {
      final parsedBaseConstructor = parseBaseConstructor(baseConstructor);
      baseClassName = parsedBaseConstructor.baseClassName;
      superConstructor = parsedBaseConstructor.superConstructor;
      superParams.addAll(parsedBaseConstructor.superParams);
      constructorParams.addAll(parsedBaseConstructor.constructorParams);
    }

    // Add arguments for all the optional presence of ports
    for (final portInfo in portInfos
        .where((p) => p.origin == _PortInfoOrigin.fieldAnnotation)) {
      if (portInfo.genInfo.isConditional) {
        constructorParams.add(FormalParameter(
          paramType: ParamType.namedRequired,
          name: portInfo.createConditionName,
          varLocation: ParamVarLocation.constructor,
          type: 'bool',
        ));
      }
    }

    // Add arguments for typed/struct ports from field annotations
    for (final portInfo in portInfos.where((p) => p.needsSourceParameter)) {
      constructorParams.add(portInfo.sourceParameter!);
    }

    for (final portInfo in portInfos) {
      constructorParams.addAll(portInfo.genInfo.configurationParameters);
    }

    final buffer = StringBuffer();
    buffer.writeln('abstract class $genClassName extends $baseClassName {');

    // Generate module accessors
    buffer.writeln(_genAccessors(portInfos));

    final constructorContents = _genConstructorContents(portInfos);

    buffer.writeln(genConstructor(
      constructorName: genClassName,
      contents: constructorContents,
      superConstructor: superConstructor,
      constructorParams: constructorParams,
      superParams: superParams,
    ));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genAccessors(List<_PortInfo> portInfos) {
    final buffer = StringBuffer();

    for (final p in portInfos) {
      buffer.writeln(p.moduleAccessor());
    }

    return buffer.toString();
  }

  static String _genConstructorContents(List<_PortInfo> portInfos) {
    final buffer = StringBuffer();

    //TODO: need to ??= initialize struct ports that are not required

    for (final port in portInfos) {
      buffer.writeln(port.modulePortCreator());
    }

    return buffer.toString();
  }
}
