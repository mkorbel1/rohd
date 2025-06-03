import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder logicStructureBuilder(BuilderOptions options) {
  return LibraryBuilder(LogicStructureGenerator());
}

class GenLogicStructure {}

class LogicStructureGenerator
    extends GeneratorForAnnotation<GenLogicStructure> {
  @override
  void generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    // TODO: implement generateForAnnotatedElement
    throw UnimplementedError();
  }
}
