import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/interface_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder rohdBuilder(BuilderOptions options) {
  // return LibraryBuilder(ModuleGenerator());
  return SharedPartBuilder(
      [ModuleGenerator(), InterfaceBuilder()], 'rohd_builder');
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';
    final baseClassName = 'Module';

    // Extract outputs from the annotation
    final outputs = annotation.read('outputs').listValue.map((o) {
      final oConst = ConstantReader(o);
      return Output(
        oConst.read('name').stringValue,
        width:
            oConst.read('width').isNull ? null : oConst.read('width').intValue,
        description: oConst.read('description').isNull
            ? null
            : oConst.read('description').stringValue,
        isConditional: oConst.read('isConditional').isNull
            ? false
            : oConst.read('isConditional').boolValue,
      );
    }).toList();

    // Find constructor and look for @Input annotations
    final classElement = element as ClassElement;
    final constructor = classElement.constructors.firstWhere(
      (c) => !c.isFactory && !c.isSynthetic,
      orElse: () =>
          throw Exception('No valid constructor found for $sourceClassName'),
    );

    final inputParams = <Map<String, dynamic>>[];
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

        inputParams.add({
          'paramName': param.name,
          'inputName': inputName ?? param.name,
          'width': inputWidth,
          'description': inputDesc,
        });
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate protected fields for inputs
    for (final input in inputParams) {
      buffer.writeln('  @protected');
      buffer.writeln('  late final Logic ${input['paramName']};');
    }

    // Generate output getters
    for (final o in outputs) {
      buffer.write("  Logic get ${o.name} => output('${o.name}');\n");
    }

    // Generate constructor
    buffer.writeln('  $genClassName(');

    // Generate constructor parameters
    final paramList =
        inputParams.map((input) => 'Logic ${input['paramName']}').join(', ');
    buffer.writeln('    $paramList,');
    buffer.writeln('  ) : super(name: "simple_module") {');

    // Generate addInput calls for annotated parameters
    for (final input in inputParams) {
      final paramName = input['paramName'];
      final inputName = input['inputName'];
      buffer.writeln(
          '    this.$paramName = addInput(\'$inputName\', $paramName);');
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
}
