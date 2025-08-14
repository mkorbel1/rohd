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
          LogicType.typed => 'addMatchedInput',
        },
      _PortDirection.output => switch (genInfo.logicType) {
          LogicType.logic => 'addOutput',
          LogicType.array => 'addOutputArray',
          LogicType.typed => 'addMatchedOutput',
        },
      _PortDirection.inOut => switch (genInfo.logicType) {
          LogicType.logic => 'addInOut',
          LogicType.array => 'addInOutArray',
          LogicType.typed => 'addMatchedInOut',
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

            switch (genInfo.isConditional) {
              case true:
                buffer.writeln('$sourceName ='
                    ' $createConditionName ? $constructorCall : null;');
                sourceStr += '!';
              case false:
                buffer.writeln('$sourceName = $constructorCall;');
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

  static _PortInfo? ofAnnotatedParameter(FormalParameterElement param) {
    final genInfo = GenInfoExtracted.ofAnnotatedParameter(param);
    if (genInfo == null) {
      return null;
    }

    return _PortInfo(
      genInfo: genInfo,
      direction: _PortDirection.ofAnnotationName(genInfo.annotationName!),
      origin: _PortInfoOrigin.constructorArgAnnotation,
    );
  }

  // static _PortInfo ofGenLogicConstReader(
  //     ConstantReader oConst, _PortDirection direction) {
  //   final genInfo = GenInfoExtracted.ofGenLogicConstReader(oConst);

  //   return _PortInfo(
  //     genInfo: genInfo,
  //     direction: direction,
  //     origin: _PortInfoOrigin.classAnnotation,
  //   );
  // }

  //TODO: add support for List<Logic> things, will be convenient I think.

  static _PortInfo? ofAnnotatedField(FieldElement2 field) {
    for (final portDirection in _PortDirection.values) {
      final genInfo = GenInfoExtracted.ofAnnotatedField(
        field,
        portDirection.toAnnotationName(),
      );

      if (genInfo != null) {
        return _PortInfo(
          genInfo: genInfo,
          direction: portDirection,
          origin: _PortInfoOrigin.fieldAnnotation,
        );
      }
    }
    return null;
  }
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

  // static List<_PortInfo> _extractPortsFromAnnotation(
  //     ConstantReader annotation) {
  //   final portInfos = <_PortInfo>[];

  //   final annotationFieldToDirection = {
  //     'inputs': _PortDirection.input,
  //     'outputs': _PortDirection.output,
  //     'inOuts': _PortDirection.inOut,
  //   };

  //   for (final MapEntry(key: field, value: direction)
  //       in annotationFieldToDirection.entries) {
  //     final dirPortInfos = annotation.peek(field)?.listValue.map((o) {
  //           final oConst = ConstantReader(o);
  //           return _PortInfo.ofGenLogicConstReader(oConst, direction);
  //         }).toList() ??
  //         [];

  //     portInfos.addAll(dirPortInfos);
  //   }

  //   return portInfos;
  // }

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
    for (final portInfo in portInfos.where((p) =>
        // p.origin == _PortInfoOrigin.classAnnotation ||
        p.origin == _PortInfoOrigin.fieldAnnotation)) {
      if (portInfo.genInfo.isConditional) {
        constructorParams.add(FormalParameter(
          paramType: ParamType.namedRequired,
          name: portInfo.createConditionName,
          varLocation: ParamVarLocation.constructor,
          type: 'bool',
        ));
      }
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
