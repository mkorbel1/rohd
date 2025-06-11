import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:rohd/src/builders/gen_info.dart';

import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/interface_generator.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

enum _PortDirection {
  input,
  output,
  inOut;

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
  classAnnotation,
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

  static _PortInfo? ofAnnotatedParameter(ParameterElement param) {
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

  static _PortInfo ofGenLogicConstReader(
      ConstantReader oConst, _PortDirection direction) {
    final genInfo = GenInfoExtracted.ofGenLogicConstReader(oConst);

    return _PortInfo(
      genInfo: genInfo,
      direction: direction,
      origin: _PortInfoOrigin.classAnnotation,
    );
  }
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  static List<_PortInfo> _extractPortsFromConstructor(
      ConstructorElement constructor) {
    final portInfos = <_PortInfo>[];
    for (final param in constructor.parameters) {
      final portInfo = _PortInfo.ofAnnotatedParameter(param);
      if (portInfo != null) {
        portInfos.add(portInfo);
      }
    }
    return portInfos;
  }

  static List<_PortInfo> _extractPortsFromAnnotation(
      ConstantReader annotation) {
    final portInfos = <_PortInfo>[];

    final annotationFieldToDirection = {
      'inputs': _PortDirection.input,
      'outputs': _PortDirection.output,
      'inOuts': _PortDirection.inOut,
    };

    for (final MapEntry(key: field, value: direction)
        in annotationFieldToDirection.entries) {
      final dirPortInfos = annotation.peek(field)?.listValue.map((o) {
            final oConst = ConstantReader(o);
            return _PortInfo.ofGenLogicConstReader(oConst, direction);
          }).toList() ??
          [];

      portInfos.addAll(dirPortInfos);
    }

    return portInfos;
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final superParams = <SuperParameter>[];

    final constructorParams = <FormalParameter>[];

    final portInfos = <_PortInfo>[
      ..._extractPortsFromAnnotation(annotation),
    ];

    final classElement = element as ClassElement;

    for (final constructor in classElement.constructors
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

    final inputs = portInfos.where((p) => p.direction == _PortDirection.input);
    final inOuts = portInfos.where((p) => p.direction == _PortDirection.inOut);
    final outputs =
        portInfos.where((p) => p.direction == _PortDirection.output);

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate protected fields for inputs
    for (final input in [...inputs, ...inOuts]) {
      if (input.genInfo.description != null) {
        buffer.writeln('  /// ${input.genInfo.description}');
      }
      buffer.writeln('  @protected');
      final nullableSuffix = input.genInfo.isConditional ? '?' : '';
      //TODO: handle inouts
      buffer
          .writeln('  late final Logic$nullableSuffix ${input.genInfo.name};');
    }

    // Generate output getters
    for (final o in outputs) {
      if (o.genInfo.description != null) {
        buffer.writeln('  /// ${o.genInfo.description}');
      }
      buffer.write(
          "  Logic get ${o.genInfo.name} => output('${o.genInfo.name}');\n");
    }

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

  static String _genConstructorContents(List<_PortInfo> portInfos) {
    final inputs = portInfos.where((p) => p.direction == _PortDirection.input);
    final inOuts = portInfos.where((p) => p.direction == _PortDirection.inOut);
    final outputs =
        portInfos.where((p) => p.direction == _PortDirection.output);

    final buffer = StringBuffer();

    // Generate addInput calls for annotated parameters
    for (final input in inputs) {
      final paramName = input.genInfo.name;
      final inputName = input.genInfo.logicName;
      final widthParam =
          input.genInfo.width != null ? ', width: ${input.genInfo.width}' : '';
      buffer.writeln(
          '    this.$paramName = addInput(\'$inputName\', $paramName$widthParam);');
    }

    //TODO: inouts

    // Generate addOutput calls
    for (final o in outputs) {
      final width = o.genInfo.width ?? 1;

      buffer.writeln("    addOutput('${o.genInfo.name}', width: $width);");
    }

    return buffer.toString();
  }
}
