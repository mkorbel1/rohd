import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';

import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/interface_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Metadata about an input port collected during code generation
class InputPortInfo {
  /// Name of the parameter in the constructor
  final String paramName;

  /// Name of the input port (may be different from paramName if specified in @Input)
  final String inputName;

  /// Width specified in @Input annotation, if any
  final int? width;

  /// Description specified in @Input annotation, if any
  final String? description;

  /// Whether this Logic input is nullable
  final bool isNullable;

  /// Whether this is a named parameter
  final bool isNamed;

  /// Whether this is an optional positional parameter
  final bool isOptionalPositional;

  String get portDeclaration {
    final nullableSuffix = isNullable ? '?' : '';
    return 'Logic$nullableSuffix $paramName';
  }

  const InputPortInfo({
    required this.paramName,
    required this.inputName,
    this.width,
    this.description,
    this.isNullable = false,
    this.isNamed = false,
    this.isOptionalPositional = false,
  });
}

/// Metadata about an output port collected during code generation
class OutputPortInfo {
  /// Name of the output port
  final String name;

  /// Width specified in @Output annotation, if any
  final int? width;

  /// Description specified in @Output annotation, if any
  final String? description;

  /// Whether this is a conditional output
  final bool isConditional;

  const OutputPortInfo({
    required this.name,
    this.width,
    this.description,
    this.isConditional = false,
  });
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';
    final baseClassName = 'Module';

    // Extract outputs from the annotation
    final outputs = annotation.peek('outputs')?.listValue.map((o) {
          final oConst = ConstantReader(o);
          return OutputPortInfo(
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
    final constructor = classElement.constructors.firstWhere(
      (c) => !c.isFactory && !c.isSynthetic,
      orElse: () =>
          throw Exception('No valid constructor found for $sourceClassName'),
    );

    final inputParams = <InputPortInfo>[];
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

        inputParams.add(InputPortInfo(
          paramName: param.name,
          inputName: inputName ?? param.name,
          width: inputWidth,
          description: inputDesc,
          isNullable: isNullable,
          isNamed: param.isNamed,
          isOptionalPositional: param.isOptionalPositional,
        ));
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate protected fields for inputs
    for (final input in inputParams) {
      buffer.writeln('  @protected');
      final nullableSuffix = input.isNullable ? '?' : '';
      buffer.writeln('  late final Logic$nullableSuffix ${input.paramName};');
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

    const defaultModuleNamedParams = [
      'name',
      'reserveName',
      'definitionName',
      'reserveDefinitionName',
    ];

    if (inputParams
        .any((ip) => defaultModuleNamedParams.contains(ip.paramName))) {
      //TODO: test this
      throw Exception('Cannot have input port args with the same names'
          ' as super module parameters: $defaultModuleNamedParams');
    }

    final namedParams = [
      ...requiredNamedParams,
      ...defaultModuleNamedParams.map((e) => 'super.$e'),
    ];

    final paramList = [
      requiredPositionalParams.join(', '),
      if (optionalPositionalParams.isNotEmpty)
        ',[${optionalPositionalParams.join(', ')}]',
      if (namedParams.isNotEmpty) ',{${namedParams.join(', ')}}',
    ].join(' ');

    buffer.writeln(paramList);
    buffer.writeln('  ) {');

    // Generate addInput calls for annotated parameters
    for (final input in inputParams) {
      final paramName = input.paramName;
      final inputName = input.inputName;
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
}
