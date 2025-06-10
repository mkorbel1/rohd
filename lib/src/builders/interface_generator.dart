import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:rohd/builder.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:source_gen/source_gen.dart';

class InterfaceGenerator extends GeneratorForAnnotation<GenInterface> {
  @override
  String generateForAnnotatedElement(
      // ignore: deprecated_member_use
      Element element,
      ConstantReader annotation,
      BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final ports = annotation.peek('ports')?.mapValue.map((key, value) {
          final genLogics = value?.toListValue()?.map((o) {
                final oConst = ConstantReader(o);
                return GenInfoExtracted.ofGenLogicConstReader(oConst);
              }).toList() ??
              [];

          final keyTypeName = key!.type!.getDisplayString();
          final keyValueName =
              ConstantReader(key.getField('_name')).stringValue;

          return MapEntry('$keyTypeName.$keyValueName', genLogics);
        }) ??
        {};

    // for example: "GenInterface<ExampleDir>"
    final annotationTypeString =
        annotation.objectValue.type!.getDisplayString();

    final typeArgMatch = RegExp(r'GenInterface<([A-Za-z0-9_<>., ]+)>')
        .firstMatch(annotationTypeString);
    final extractedTypeArg = typeArgMatch?.group(1);

    final baseClassName = [
      'Interface',
      if (extractedTypeArg != null) '<$extractedTypeArg>'
    ].join(); //TODO: grab from constructor

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    buffer.write(_genAccessors(ports));

    buffer.write(_genConstructor(ports, constructorName: genClassName));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genAccessors(Map<String, List<GenInfoExtracted>> ports) {
    final buffer = StringBuffer();

    for (final genLogic in ports.values.flattened) {
      buffer.writeln('Logic get ${genLogic.name} => '
          "port('${genLogic.name}');");
    }

    return buffer.toString();
  }

  static String _genConstructor(Map<String, List<GenInfoExtracted>> ports,
      {required String constructorName}) {
    final buffer = StringBuffer();

    buffer.writeln('$constructorName() {');

    ports.forEach((group, genLogics) {
      for (final genLogic in genLogics) {
        buffer.writeln("setPorts([Logic.port('${genLogic.name}')],[$group]);");
      }
    });

    buffer.writeln('}');

    return buffer.toString();
  }
}
