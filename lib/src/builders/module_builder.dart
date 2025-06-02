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

    final inputParams = <String>[];
    for (final param in constructor.parameters) {
      final hasInputAnnotation = param.metadata.any(
        (meta) => meta.element?.displayName == 'Input',
      );
      if (hasInputAnnotation) {
        inputParams.add(param.name);
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate output getters
    for (final o in outputs) {
      buffer.write("  Logic get ${o.name} => output('${o.name}');\n");
    }

    // Generate constructor
    buffer.writeln('  $genClassName(');

    // Generate constructor parameters
    final paramList = inputParams.map((name) => 'Logic $name').join(', ');
    buffer.writeln('    $paramList,');
    buffer.writeln('  ) : super(name: "simple_module") {');

    // Generate addInput calls for annotated parameters
    for (final param in inputParams) {
      buffer.writeln('    $param = addInput(\'$param\', $param);');
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
