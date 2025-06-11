import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:rohd/src/builders/gen_info.dart';

import 'package:rohd/src/builders/annotations.dart';
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
      if (baseConstructor.type is FunctionType) {
        final func = baseConstructor.type! as FunctionType;
        final returnType = func.returnType;

        final parameters = func.formalParameters;

        baseClassName = returnType.getDisplayString();

        // e.g. "GenBaseMod Function({required bool myFlag}) (new)"
        final constructorString = baseConstructor.toString();
        final namedConstructorMatch =
            RegExp(r'\((\w+)\)$').firstMatch(constructorString);
        final namedConstructor = namedConstructorMatch?.group(1);
        if (namedConstructor == null) {
          throw Exception('Could not deduce the name of the'
              ' base constructor from $constructorString');
        }
        superConstructor = 'super.$namedConstructor';

        for (final param in parameters) {
          final paramName = param.displayName;
          final paramType = param.type.getDisplayString();
          final paramDefault = param.defaultValueCode;
          final paramIsNullable =
              param.type.nullabilitySuffix == NullabilitySuffix.question;

          if (param.isPositional) {
            // for positional arguments, we need to transform them into named
            // arguments

            // keep the order the same
            superParams.add(
              SuperParameter(
                  name: paramName, type: ParamType.requiredPositional),
            );

            constructorParams.add(
              FormalParameter(
                paramType: paramDefault == null
                    ? ParamType.namedRequired
                    : ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                defaultValue: paramDefault,
                varLocation: ParamVarLocation.constructor,
                type: paramType,
              ),
            );
          } else {
            constructorParams.add(
              FormalParameter(
                paramType: param.isRequired
                    ? ParamType.namedRequired
                    : ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                varLocation: ParamVarLocation.super_,
                type: null,
              ),
            );
          }
        }
      } else {
        throw Exception('`baseConstructor` must be a function type.');
      }
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

    // Generate constructor
    buffer.writeln('  $genClassName(');

    buffer.writeln(constructorArguments(constructorParams));

    buffer.writeln(')');

    buffer.writeln(' : $superConstructor(${superArguments(superParams)}) {');

    // Generate addInput calls for annotated parameters
    for (final input in [...inputs, ...inOuts]) {
      final paramName = input.genInfo.name;
      final inputName = input.genInfo.logicName;
      final widthParam =
          input.genInfo.width != null ? ', width: ${input.genInfo.width}' : '';
      buffer.writeln(
          '    this.$paramName = addInput(\'$inputName\', $paramName$widthParam);');
    }

    // Generate addOutput calls
    for (final o in outputs) {
      final width = o.genInfo.width ?? 1;

      buffer.writeln("    addOutput('${o.genInfo.name}', width: $width);");
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  @visibleForTesting
  static String constructorArguments(List<FormalParameter> params) {
    if (params.map((e) => e.name).toSet().length != params.length) {
      throw ArgumentError('Duplicate parameter names found in constructor');
    }

    final requiredPositionalArgs = params
        .where((p) => p.paramType == ParamType.requiredPositional)
        .map((p) => '$p,')
        .join();

    final optionalPositionalArgs = params
        .where((p) => p.paramType == ParamType.optionalPositional)
        .map((p) => '$p,')
        .join();

    final namedArgs =
        params.where((p) => p.paramType.isNamed).map((p) => '$p,').join();

    if (namedArgs.isNotEmpty && optionalPositionalArgs.isNotEmpty) {
      throw ArgumentError(
          'Cannot have both optional positional and named arguments');
    }

    return [
      requiredPositionalArgs,
      if (optionalPositionalArgs.isNotEmpty) '[$optionalPositionalArgs]',
      if (namedArgs.isNotEmpty) '{$namedArgs}',
    ].join();
  }

  @visibleForTesting
  static String superArguments(List<SuperParameter> params) {
    if (params.map((e) => e.name).toSet().length != params.length) {
      throw ArgumentError('Duplicate parameter names found in constructor');
    }

    final positionalArgs =
        params.where((p) => p.type.isPositional).map((p) => '$p,');

    final namedArgs = params.where((p) => p.type.isNamed).map((p) => '$p,');

    return [
      if (positionalArgs.isNotEmpty) '$positionalArgs',
      if (namedArgs.isNotEmpty) '{${namedArgs.join()}}',
    ].join();
  }
}
