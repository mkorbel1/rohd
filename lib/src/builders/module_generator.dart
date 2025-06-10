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
  inout;

  static _PortDirection ofAnnotationName(String annotationName) {
    switch (annotationName) {
      case 'Input':
        return _PortDirection.input;
      case 'Output':
        return _PortDirection.output;
      case 'Inout':
        return _PortDirection.inout;
      default:
        throw ArgumentError(
            'Unknown port direction annotation name: $annotationName');
    }
  }
}

class _PortInfo {
  final _PortDirection direction;
  final GenInfoExtracted genInfo;

  _PortInfo({
    required this.genInfo,
    required this.direction,
  });

  static _PortInfo? ofAnnotatedParameter(ParameterElement param) {
    final genInfo = GenInfoExtracted.ofAnnotatedParameter(param);
    if (genInfo == null) {
      return null;
    }

    return _PortInfo(
      genInfo: genInfo,
      direction: _PortDirection.ofAnnotationName(genInfo.annotationName!),
    );
  }

  static _PortInfo ofGenLogicConstReader(
      ConstantReader oConst, _PortDirection direction) {
    final genInfo = GenInfoExtracted.ofGenLogicConstReader(oConst);

    return _PortInfo(
      genInfo: genInfo,
      direction: direction,
    );
  }
}

/// Metadata about a port collected during code generation
class _PortInfoOld {
  /// Name of the variable
  final String name;

  /// Name of the Logic
  final String logicName;

  /// Width
  final int? width;

  /// Description
  final String? description;

  /// Whether this Logic is nullable/conditional
  final bool isNullable;

  /// Type of parameter, or null if it is not an argument to the constructor.
  final ParamType? paramType;

  final _PortDirection direction;

  final List<int>? dimensions;

  final String type;

  String get portDeclaration {
    final nullableSuffix = isNullable ? '?' : '';
    return '$type$nullableSuffix $name';
  }

  const _PortInfoOld({
    required this.name,
    required this.logicName,
    required this.paramType,
    required this.direction,
    this.width,
    this.description,
    this.isNullable = false,
    this.dimensions,
    this.type = 'Logic',
  });

  /// Returns `null` if the parameter does not have any port annotation.
  static _PortInfoOld? ofAnnotatedParameter(ParameterElement param) {
    final name = param.name;
    final isNullable =
        param.type.nullabilitySuffix == NullabilitySuffix.question;

    final annotation = param.metadata.firstWhereOrNull(
      //TODO: make this look at class instead??
      (meta) => meta.element?.displayName == 'Input',
    );

    if (annotation == null) {
      return null;
    }

    if (param.hasDefaultValue) {
      throw Exception('Cannot have a default value for a port argument.');
    }

    final ParamType paramType;
    if (param.isOptionalPositional) {
      paramType = ParamType.optionalPositional;
    } else if (param.isOptionalNamed) {
      paramType = ParamType.namedOptional;
    } else if (param.isRequiredNamed) {
      paramType = ParamType.namedRequired;
    } else if (param.isRequiredPositional) {
      paramType = ParamType.requiredPositional;
    } else {
      throw ArgumentError('Parameter $name has an unknown type');
    }

    final annotationConst =
        annotation.computeConstantValue()!.getField('(super)')!;

    final logicName = annotationConst.getField('logicName')!.isNull
        ? null
        : annotationConst.getField('logicName')!.toStringValue();

    final width = annotationConst.getField('width')!.isNull
        ? null
        : annotationConst.getField('width')!.toIntValue();

    //TODO: rest of the fields

    return _PortInfoOld(
      name: name,
      logicName: logicName ?? name,
      paramType: paramType,
      direction: _PortDirection.input, //TODO: fix this
    );
  }

  factory _PortInfoOld.ofGenLogicConstReader(
      ConstantReader oConst, _PortDirection direction) {
    final name =
        oConst.read('name').isNull ? null : oConst.read('name').stringValue;

    if (name == null) {
      throw ArgumentError('Port name cannot be null');
    }

    final logicName = oConst.read('logicName').isNull
        ? name
        : oConst.read('logicName').stringValue;

    final width =
        oConst.read('width').isNull ? null : oConst.read('width').intValue;
    final description = oConst.read('description').isNull
        ? null
        : oConst.read('description').stringValue;
    final isConditional = oConst.read('isConditional').boolValue;
    // final isNullable = oConst.read('isNullable').boolValue;
    final dimensions = oConst.read('dimensions').isNull
        ? null
        : oConst
            .read('dimensions')
            .listValue
            .map((e) => e.toIntValue()!)
            .toList();

    var type =
        oConst.read('type').isNull ? 'Logic' : oConst.read('type').stringValue;
    if (dimensions != null) {
      type = 'LogicArray';
    }

    return _PortInfoOld(
      name: name,
      logicName: logicName,
      width: width,
      description: description,
      isNullable: isConditional,
      paramType: null, // Not a constructor parameter
      direction: direction,
      dimensions: dimensions,
      type: type,
    );
  }
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final superParams = <SuperParameter>[];

    final constructorParams = <FormalParameter>[];

    // Extract outputs from the annotation
    final outputs = annotation.peek('outputs')?.listValue.map((o) {
          final oConst = ConstantReader(o);
          return _PortInfo.ofGenLogicConstReader(oConst, _PortDirection.output);
        }).toList() ??
        [];

    // Find constructor and look for @Input annotations
    final classElement = element as ClassElement;
    // TODO: what do we do if there are *multiple* constructors?? do them all!
    final constructor = classElement.constructors.firstWhereOrNull(
      (c) => !c.isFactory && !c.isSynthetic,
    );

    final inputParams = <_PortInfo>[];
    if (constructor != null) {
      for (final param in constructor.parameters) {
        final portInfo = _PortInfo.ofAnnotatedParameter(param);
        if (portInfo != null) {
          inputParams.add(portInfo);

          constructorParams.add(FormalParameter(
            paramType: portInfo.genInfo.paramType!,
            name: portInfo.genInfo.name,
            varLocation: ParamVarLocation.constructor,
            type: portInfo.genInfo.typeName,
            isNullable: portInfo.genInfo.isConditional,
          ));
        }
      }
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

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate protected fields for inputs
    for (final input in inputParams) {
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
    for (final input in inputParams) {
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
