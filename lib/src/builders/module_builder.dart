import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:source_gen/source_gen.dart';

Builder rohdBuilder(BuilderOptions options) {
  return SharedPartBuilder([ModuleGenerator()], 'rohd');
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final baseClassName = 'Module'; //TODO

    final buffer = StringBuffer();

    buffer.writeln('class $genClassName extends $baseClassName {}');

    return buffer.toString();
  }
}
