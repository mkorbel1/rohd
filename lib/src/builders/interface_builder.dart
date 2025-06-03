import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/builder.dart';
import 'package:source_gen/source_gen.dart';

class InterfaceGenerator extends GeneratorForAnnotation<GenInterface> {
  @override
  String generateForAnnotatedElement(
      // ignore: deprecated_member_use
      Element element,
      ConstantReader annotation,
      BuildStep buildStep) {
    return '// this will be intf builder stuff';
  }
}
