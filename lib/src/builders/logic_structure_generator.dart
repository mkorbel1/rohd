import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/builder.dart';
import 'package:source_gen/source_gen.dart';

Builder logicStructureBuilder(BuilderOptions options) {
  return LibraryBuilder(LogicStructureGenerator());
}

class LogicStructureGenerator extends GeneratorForAnnotation<GenStruct> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // TODO: implement generateForAnnotatedElement
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    const baseClassName = 'LogicStructure'; //TODO: grab from constructor

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    buffer.writeln('}');

    return buffer.toString();
  }
}
