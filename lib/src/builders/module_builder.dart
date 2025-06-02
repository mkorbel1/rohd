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
      // ignore: deprecated_member_use
      Element element,
      ConstantReader annotation,
      BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = 'X_\$$sourceClassName';

    final baseClassName = 'Module'; //TODO

    final buffer = StringBuffer();

    buffer.writeln('class $genClassName extends $baseClassName {}');

    return buffer.toString();
  }
}
