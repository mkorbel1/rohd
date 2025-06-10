import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/interface_generator.dart';
import 'package:source_gen/source_gen.dart';

enum _ParamType {
  requiredPositional(isRequired: true, isPositional: true),
  optionalPositional(isPositional: true),
  namedOptional,
  namedRequired(isRequired: true);

  final bool isRequired;
  final bool isPositional;
  bool get isNamed => !isPositional;
  const _ParamType({this.isRequired = false, this.isPositional = false});
}

enum _ParamVarLocation {
  constructor,
  super_,
  this_,
}

class _FormalParameter {
  _ParamType paramType;

  String name;

  String? type;

  bool isNullable;

  String? defaultValue;

  _ParamVarLocation varLocation;

  _FormalParameter({
    required this.paramType,
    required this.name,
    required this.varLocation,
    required this.type,
    this.isNullable = false,
    this.defaultValue,
  }) {
    if (paramType.isRequired && defaultValue != null) {
      throw ArgumentError(
          'Required positional parameters cannot have a default value');
    }
    if (varLocation == _ParamVarLocation.constructor && type == null) {
      throw ArgumentError('Constructor parameters must have a type specified');
    }
  }

  @override
  String toString() {
    final requiredPrefix =
        paramType == _ParamType.namedRequired ? 'required ' : '';

    switch (varLocation) {
      case _ParamVarLocation.super_:
        return '${requiredPrefix}super.$name';

      case _ParamVarLocation.this_:
        return 'this.$name';

      case _ParamVarLocation.constructor:
        final nullableSuffix = isNullable ? '?' : '';
        final defaultSuffix = defaultValue != null ? ' = $defaultValue' : '';
        return '$requiredPrefix $type $nullableSuffix $name$defaultSuffix';
    }
  }
}

class _SuperParameter {
  String name;
  _ParamType type;

  _SuperParameter({required this.name, required this.type});

  @override
  String toString() {
    if (type.isPositional) {
      return name;
    } else {
      return '$name: $name';
    }
  }
}

enum _PortDirection {
  input,
  output,
  inout,
}

/// Metadata about a port collected during code generation
class _PortInfo {
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
  final _ParamType? paramType;

  final _PortDirection direction;

  final List<int>? dimensions;

  final String type;

  String get portDeclaration {
    final nullableSuffix = isNullable ? '?' : '';
    return '$type$nullableSuffix $name';
  }

  const _PortInfo({
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
  static _PortInfo? ofAnnotatedParameter(ParameterElement param) {
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

    final _ParamType paramType;
    if (param.isOptionalPositional) {
      paramType = _ParamType.optionalPositional;
    } else if (param.isOptionalNamed) {
      paramType = _ParamType.namedOptional;
    } else if (param.isRequiredNamed) {
      paramType = _ParamType.namedRequired;
    } else if (param.isRequiredPositional) {
      paramType = _ParamType.requiredPositional;
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

    return _PortInfo(
      name: name,
      logicName: logicName ?? name,
      paramType: paramType,
      direction: _PortDirection.input, //TODO: fix this
    );
  }

  factory _PortInfo.ofGenLogicConstReader(
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

    return _PortInfo(
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

    final superParams = <_SuperParameter>[];

    final constructorParams = <_FormalParameter>[];

    // Extract outputs from the annotation
    final outputs = annotation.peek('outputs')?.listValue.map((o) {
          final oConst = ConstantReader(o);
          return _PortInfo.ofGenLogicConstReader(oConst, _PortDirection.output);
        }).toList() ??
        [];

    // Find constructor and look for @Input annotations
    final classElement = element as ClassElement;
    // TODO: what do we do if there are *multiple* constructors??
    final constructor = classElement.constructors.firstWhereOrNull(
      (c) => !c.isFactory && !c.isSynthetic,
    );

    final inputParams = <_PortInfo>[];
    if (constructor != null) {
      for (final param in constructor.parameters) {
        final portInfo = _PortInfo.ofAnnotatedParameter(param);
        if (portInfo != null) {
          inputParams.add(portInfo);

          constructorParams.add(_FormalParameter(
            paramType: portInfo.paramType!,
            name: portInfo.name,
            varLocation: _ParamVarLocation.constructor,
            type: portInfo.type,
            isNullable: portInfo.isNullable,
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
        (name) => _FormalParameter(
          paramType: _ParamType.namedOptional,
          name: name,
          varLocation: _ParamVarLocation.super_,
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
              _SuperParameter(
                  name: paramName, type: _ParamType.requiredPositional),
            );

            constructorParams.add(
              _FormalParameter(
                paramType: paramDefault == null
                    ? _ParamType.namedRequired
                    : _ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                defaultValue: paramDefault,
                varLocation: _ParamVarLocation.constructor,
                type: paramType,
              ),
            );
          } else {
            constructorParams.add(
              _FormalParameter(
                paramType: param.isRequired
                    ? _ParamType.namedRequired
                    : _ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                varLocation: _ParamVarLocation.super_,
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
      if (input.description != null) {
        buffer.writeln('  /// ${input.description}');
      }
      buffer.writeln('  @protected');
      final nullableSuffix = input.isNullable ? '?' : '';
      buffer.writeln('  late final Logic$nullableSuffix ${input.name};');
    }

    // Generate output getters
    for (final o in outputs) {
      if (o.description != null) {
        buffer.writeln('  /// ${o.description}');
      }
      buffer.write("  Logic get ${o.name} => output('${o.name}');\n");
    }

    // Generate constructor
    buffer.writeln('  $genClassName(');

    buffer.writeln(constructorArguments(constructorParams));

    buffer.writeln(')');

    buffer.writeln(' : $superConstructor(${superArguments(superParams)}) {');

    // Generate addInput calls for annotated parameters
    for (final input in inputParams) {
      final paramName = input.name;
      final inputName = input.logicName;
      final widthParam = input.width != null ? ', width: ${input.width}' : '';
      buffer.writeln(
          '    this.$paramName = addInput(\'$inputName\', $paramName$widthParam);');
    }

    // Generate addOutput calls
    for (final o in outputs) {
      final width = o.width ?? 1;

      buffer.writeln("    addOutput('${o.name}', width: $width);");
    }

    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  @visibleForTesting
  static String constructorArguments(List<_FormalParameter> params) {
    if (params.map((e) => e.name).toSet().length != params.length) {
      throw ArgumentError('Duplicate parameter names found in constructor');
    }

    final requiredPositionalArgs = params
        .where((p) => p.paramType == _ParamType.requiredPositional)
        .map((p) => '$p,')
        .join();

    final optionalPositionalArgs = params
        .where((p) => p.paramType == _ParamType.optionalPositional)
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
  static String superArguments(List<_SuperParameter> params) {
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
