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

  /// Whether this represents one of the port types that can only be used inside
  /// of the module and requires a separate external source (i.e. input/inOut).
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

  bool get createConditionNullable =>
      genInfo.isConditional && needsSourceParameter && !sourceParamRequired!;

  /// The name of a signal to use as the source for addInput, addInOut, etc.
  ///
  /// When it's an output, it is the name of the generator.
  String get sourceName => switch (origin) {
        _PortInfoOrigin.constructorArgAnnotation =>
          genInfo.name, // no typed here
        _PortInfoOrigin.fieldAnnotation => switch (direction) {
            _PortDirection.input ||
            _PortDirection.inOut =>
              '${genInfo.name}Source',
            _PortDirection.output => '${genInfo.name}Generator',
          },
      };

  String get sourceParamName => switch (direction) {
        _PortDirection.input || _PortDirection.inOut => genInfo.name,
        _PortDirection.output => sourceName,
      };

  String get sourceType => switch (direction) {
        _PortDirection.input || _PortDirection.inOut => genInfo.typeName,
        _PortDirection.output => '${genInfo.typeName} Function({String? name})',
      };

  /// Indicates that the generated base class constructor should include an
  /// extra [sourceName] argument for driving the input/inout or for creating
  /// the output.
  ///
  /// This is only needed when it's a field annotation since we already have the
  /// super argument created if it's a constructor argument annotation.
  bool get needsSourceParameter =>
      origin == _PortInfoOrigin.fieldAnnotation &&
      genInfo.logicType == LogicType.typed;

  /// If [needsSourceParameter], then indicates whether it should be `required`.
  bool? get sourceParamRequired => needsSourceParameter
      ? (genInfo.structDefaultConstructorType ==
          StructDefaultConstructorType.unusable)
      : null;

  FormalParameter? sourceParameter(ParamPosition extraPosition) {
    if (!needsSourceParameter) {
      return null;
    }

    final isRequired = sourceParamRequired!;

    return FormalParameter(
      paramType: extraPosition.toParamType(isRequired: isRequired),
      name: sourceParamName,
      varLocation: ParamVarLocation.constructor,
      type: sourceType,
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
    if (genInfo.logicType != LogicType.logic && type != 'Logic') {
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
              " ${accessorFunction}Source('${genInfo.logicName}')$castStr;");

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
                genInfo.genConstructorCall(naming: Naming.mergeable);

            if (needsSourceParameter &&
                genInfo.isConditional &&
                createConditionNullable) {
              buffer.writeln(
                  '$createConditionName ??= $sourceParamName != null;');
            }

            final sourceOrConstructorCall = needsSourceParameter
                ? ' $sourceParamName ?? ($constructorCall)'
                : constructorCall;

            final sourceConstructionString = switch (genInfo.isConditional) {
              true => ' $createConditionName ? $sourceOrConstructorCall : null',
              false => sourceOrConstructorCall,
            };

            if (genInfo.logicType == LogicType.typed) {
              assert(
                  needsSourceParameter, 'Should only get here if we need it.');

              if (sourceParamRequired!) {
                buffer.writeln('this.$sourceName = $sourceParamName;');
              } else {
                // if it's required, we don't need to do anything, `this.`
                final addSourceName = 'this.$sourceName';
                sourceStr = ', $addSourceName';

                assert(sourceConstructionString != null,
                    'Should not have null constructor here.');

                buffer.writeln('$addSourceName = $sourceConstructionString;');
              }
            } else {
              assert(sourceConstructionString != null,
                  'Should not have null constructor here.');

              buffer.writeln('$sourceName = $sourceConstructionString;');
            }

            if (genInfo.isConditional) {
              sourceStr += '!';
            }

          case _PortDirection.output:
            if (genInfo.logicType == LogicType.typed) {
              const genName = 'name';
              final constructorCall = genInfo.genConstructorCall(
                  naming: Naming.mergeable,
                  nameVariable: "$genName ?? '${genInfo.logicName}'");
              final defaultGeneratorCall =
                  '({String? $genName}) => $constructorCall';

              assert(
                  needsSourceParameter, 'Should only get here if we need it.');

              if (genInfo.isConditional && createConditionNullable) {
                buffer.writeln(
                    '$createConditionName ??= $sourceParamName != null;');
              }

              final sourceOrConstructorCall = needsSourceParameter
                  ? ' $sourceParamName ?? ($defaultGeneratorCall)'
                  : defaultGeneratorCall;

              final sourceConstructionString = switch (genInfo.isConditional) {
                true =>
                  ' $createConditionName ? $sourceOrConstructorCall : null',
                false => sourceOrConstructorCall,
              };

              if (!sourceParamRequired!) {
                // if it's required, we don't need to do anything
                sourceStr = ', $sourceName';

                buffer.writeln('$sourceName ='
                    ' $sourceName ?? ($sourceConstructionString);');

                if (genInfo.isConditional) {
                  sourceStr += '!';
                }
              }
            }
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
          _PortInfoOrigin.fieldAnnotation => 'this.${genInfo.name} ='
              ' $createConditionName ? $portCreationString : null;',
        },
      false => switch (origin) {
          _PortInfoOrigin.constructorArgAnnotation => '$portCreationString;',
          _PortInfoOrigin.fieldAnnotation =>
            'this.${genInfo.name} = $portCreationString;',
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

    final extraPosition = constructorParams
            .any((cp) => cp.paramType == ParamType.optionalPositional)
        ? ParamPosition.positional
        : ParamPosition.named;

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

      if (extraPosition == ParamPosition.positional) {
        // here we need to convert to positional arguments
        superParams.addAll(moduleBaseParams.map((name) => SuperParameter(
              name: name,
              type: ParamType.namedOptional,
              value: name,
            )));

        constructorParams.addAll([
          FormalParameter(
            paramType: ParamType.optionalPositional,
            name: 'name',
            varLocation: ParamVarLocation.constructor,
            type: 'String',
            defaultValue: "'${sourceClassName}_inst'",
          ),
          FormalParameter(
            paramType: ParamType.optionalPositional,
            name: 'reserveName',
            varLocation: ParamVarLocation.constructor,
            type: 'bool',
            defaultValue: 'false',
          ),
          FormalParameter(
            paramType: ParamType.optionalPositional,
            name: 'definitionName',
            varLocation: ParamVarLocation.constructor,
            type: 'String',
            isNullable: true,
          ),
          FormalParameter(
            paramType: ParamType.optionalPositional,
            name: 'reserveDefinitionName',
            varLocation: ParamVarLocation.constructor,
            type: 'bool',
            defaultValue: 'false',
          ),
        ]);
      } else {
        constructorParams.addAll(moduleBaseParams.map(
          (name) => FormalParameter(
            paramType: ParamType.namedOptional,
            name: name,
            varLocation: ParamVarLocation.super_,
            type: null,
            defaultValue: name == 'name' ? "'${sourceClassName}_inst'" : null,
          ),
        ));
      }
    } else {
      final parsedBaseConstructor =
          parseBaseConstructor(baseConstructor, extraPosition);
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
          paramType: extraPosition.toParamType(isRequired: false),
          name: portInfo.createConditionName,
          varLocation: ParamVarLocation.constructor,
          type: 'bool${portInfo.createConditionNullable ? '?' : ''}',
          defaultValue: portInfo.createConditionNullable ? null : 'true',
        ));
      }
    }

    // Add arguments for typed/struct ports from field annotations
    for (final portInfo in portInfos.where((p) => p.needsSourceParameter)) {
      constructorParams.add(portInfo.sourceParameter(extraPosition)!);
    }

    for (final portInfo in portInfos) {
      constructorParams
          .addAll(portInfo.genInfo.configurationParameters(extraPosition));
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
