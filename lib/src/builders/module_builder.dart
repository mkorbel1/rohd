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
        // width: o.getField('width')?.toIntValue(),
        // description: o.getField('description')?.toStringValue(),
        // isConditional: o.getField('isConditional')?.toBoolValue() ?? false,
      );
    });

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    for (final o in outputs) {
      buffer.write("Logic get ${o.name} => output('${o.name}');\n");
    }

    buffer.writeln('$genClassName(Logic a){');
    buffer.writeln('a = addInput(\'a\', a);');
    for (final o in outputs) {
      buffer.writeln("addOutput('${o.name}', width: ${o.width ?? 1});");
    }
    buffer.writeln('}');
    buffer.writeln('}');

    return buffer.toString();
  }
}
