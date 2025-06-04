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

class _FormalParameter {
  _ParamType type;

  String name;

  bool isNullable;

  String? defaultValue;

  bool isSuper;

  _FormalParameter({
    required this.type,
    required this.name,
    this.isNullable = false,
    this.defaultValue,
    this.isSuper = false,
  }) {
    if (type.isRequired && defaultValue != null) {
      throw ArgumentError(
          'Required positional parameters cannot have a default value');
    }
  }

  @override
  String toString() {
    if (isSuper) {
      return 'super.$name';
    }

    final nullableSuffix = isNullable ? '?' : '';
    final defaultSuffix = defaultValue != null ? ' = $defaultValue' : '';
    return '$type$nullableSuffix $name$defaultSuffix';
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
    final isNullable = oConst.read('isNullable').boolValue;
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
      isNullable: isNullable,
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
          return _PortInfo(
            name: oConst.read('name').stringValue,
            width: oConst.read('width').isNull
                ? null
                : oConst.read('width').intValue,
            description: oConst.read('description').isNull
                ? null
                : oConst.read('description').stringValue,
            isConditional: oConst.read('isConditional').isNull
                ? false
                : oConst.read('isConditional').boolValue,
          );
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
        final inputAnnotation = param.metadata
            .where(
              (meta) => meta.element?.displayName == 'Input',
            )
            .firstOrNull;

        if (inputAnnotation != null) {
          final inputName = inputAnnotation
              .computeConstantValue()
              ?.getField('name')
              ?.toStringValue();
          final inputWidth = inputAnnotation
              .computeConstantValue()
              ?.getField('width')
              ?.toIntValue();
          final inputDesc = inputAnnotation
              .computeConstantValue()
              ?.getField('description')
              ?.toStringValue();

          // Check if parameter type is nullable
          final isNullable =
              param.type.nullabilitySuffix == NullabilitySuffix.question;

          inputParams.add(_PortInfo(
            name: param.name,
            logicName: inputName ?? param.name,
            width: inputWidth,
            description: inputDesc,
            isNullable: isNullable,
            isNamed: param.isNamed,
            isOptionalPositional: param.isOptionalPositional,
          ));
        }
      }
    }

    // Extract baseConstructor from the annotation
    final baseConstructor = annotation.peek('baseConstructor')?.objectValue;
    String baseClassName = 'Module';
    List<String> baseConstructorParams = [];

    if (baseConstructor == null) {
      const moduleBaseParams = [
        'name',
        'reserveName',
        'definitionName',
        'reserveDefinitionName',
      ];
      constructorParams.addAll(moduleBaseParams.map(
        (name) => _FormalParameter(
          type: _ParamType.namedOptional,
          name: name,
          isSuper: true,
        ),
      ));
    } else {
      if (baseConstructor.type is FunctionType) {
        final func = baseConstructor.type! as FunctionType;
        final returnType = func.returnType;
        final parameters = func.formalParameters;

        baseClassName = returnType.getDisplayString();

        superParams.clear();
        constructorParams.clear();

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
                type: paramDefault == null
                    ? _ParamType.namedRequired
                    : _ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                defaultValue: paramDefault,
              ),
            );
          } else {
            constructorParams.add(
              _FormalParameter(
                type: param.isRequired
                    ? _ParamType.namedRequired
                    : _ParamType.namedOptional,
                name: paramName,
                isNullable: paramIsNullable,
                isSuper: true,
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
      buffer.writeln('  @protected');
      final nullableSuffix = input.isNullable ? '?' : '';
      buffer.writeln('  late final Logic$nullableSuffix ${input.name};');
    }

    // Generate output getters
    for (final o in outputs) {
      buffer.write("  Logic get ${o.name} => output('${o.name}');\n");
    }

    // Generate constructor
    buffer.writeln('  $genClassName(');

    // Generate constructor parameters
    final requiredPositionalParams = inputParams
        .where((p) => !p.isNamed && !p.isOptionalPositional)
        .map((p) => p.portDeclaration);

    final optionalPositionalParams = inputParams
        .where((p) => !p.isNamed && p.isOptionalPositional)
        .map((p) => p.portDeclaration);

    final requiredNamedParams =
        inputParams.where((p) => p.isNamed).map((p) => p.portDeclaration);

    if (optionalPositionalParams.isNotEmpty &&
        requiredPositionalParams.isNotEmpty) {
      throw Exception(
          'Cannot have both optional positional and named arguments both');
    }

    if (inputParams.any((ip) => baseClassParams.contains(ip.name))) {
      //TODO: test this
      throw Exception('Cannot have input port args with the same names'
          ' as super module parameters: $baseClassParams');
    }

    final namedParams = [
      ...requiredNamedParams,
      ...baseClassParams.map((e) => 'super.$e'),
    ];

    final paramList = [
      requiredPositionalParams.join(', '),
      if (optionalPositionalParams.isNotEmpty)
        ',[${optionalPositionalParams.join(', ')}]',
      if (namedParams.isNotEmpty) ',{${namedParams.join(', ')}}',
    ].join(' ');

    buffer.writeln(paramList);
    buffer.writeln('  ) : super(${baseConstructorParams.join(', ')}) {');

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
      final conditionalParam = o.isConditional ? ', isConditional: true' : '';
      buffer.writeln(
          "    addOutput('${o.name}', width: $width$conditionalParam);");
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
        .where((p) => p.type == _ParamType.requiredPositional)
        .map((p) => '$p,');

    final optionalPositionalArgs = params
        .where((p) => p.type == _ParamType.optionalPositional)
        .map((p) => '$p,');

    final namedArgs = params.where((p) => p.type.isNamed).map((p) => '$p,');

    if (namedArgs.isNotEmpty && optionalPositionalArgs.isNotEmpty) {
      throw ArgumentError(
          'Cannot have both optional positional and named arguments');
    }

    return [
      requiredPositionalArgs,
      if (optionalPositionalArgs.isNotEmpty) '[$optionalPositionalArgs]',
      if (namedArgs.isNotEmpty) '{${namedArgs.join()}}',
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
