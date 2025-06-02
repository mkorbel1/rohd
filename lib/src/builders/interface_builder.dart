import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/builder.dart';
import 'package:source_gen/source_gen.dart';

// Builder interfaceBuilder(BuilderOptions options) {
//   // return LibraryBuilder(InterfaceBuilder());
//   return SharedPartBuilder([InterfaceBuilder()], 'rohd_intf_builder');
// }

class InterfaceBuilder extends GeneratorForAnnotation<GenInterface> {
  @override
  String generateForAnnotatedElement(
      // ignore: deprecated_member_use
      Element element,
      ConstantReader annotation,
      BuildStep buildStep) {
    return '// this will be intf builder stuff';
  }
}
