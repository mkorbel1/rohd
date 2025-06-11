import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:rohd/builder.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

class InterfaceGenerator extends GeneratorForAnnotation<GenInterface> {
  static Map<String, List<GenInfoExtracted>> _extractPortsFromAnnotation(
          ConstantReader annotation) =>
      annotation.peek('ports')?.mapValue.map((key, value) {
        final genLogics = value?.toListValue()?.map((o) {
              final oConst = ConstantReader(o);
              return GenInfoExtracted.ofGenLogicConstReader(oConst);
            }).toList() ??
            [];

        final keyTypeName = key!.type!.getDisplayString();
        final keyValueName = ConstantReader(key.getField('_name')).stringValue;

        return MapEntry('$keyTypeName.$keyValueName', genLogics);
      }) ??
      {};

  @override
  String generateForAnnotatedElement(
      // ignore: deprecated_member_use
      Element element,
      ConstantReader annotation,
      BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final superParams = <SuperParameter>[];
    final constructorParams = <FormalParameter>[];

    final ports = _extractPortsFromAnnotation(annotation);

    // for example: "GenInterface<ExampleDir>"
    final annotationTypeString =
        annotation.objectValue.type!.getDisplayString();

    final typeArgMatch = RegExp(r'GenInterface<([A-Za-z0-9_<>., ]+)>')
        .firstMatch(annotationTypeString);
    final extractedTypeArg = typeArgMatch?.group(1);

    final baseConstructor = annotation.peek('baseConstructor')?.objectValue;
    final String baseClassName;
    final String superConstructor;

    if (baseConstructor == null) {
      // no need to tear off Interface.new since it has no args
      baseClassName = [
        'Interface',
        if (extractedTypeArg != null) '<$extractedTypeArg>'
      ].join();
      superConstructor = 'super';
    } else {
      final parsedBaseConstructor = parseBaseConstructor(baseConstructor);
      baseClassName = parsedBaseConstructor.baseClassName;
      superConstructor = parsedBaseConstructor.superConstructor;
      superParams.addAll(parsedBaseConstructor.superParams);
      constructorParams.addAll(parsedBaseConstructor.constructorParams);
    }

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    buffer.write(_genAccessors(ports));

    final constructorContents = _genConstructorContents(ports);
    buffer.write(genConstructor(
        constructorName: genClassName,
        superConstructor: superConstructor,
        constructorParams: constructorParams,
        superParams: superParams,
        contents: constructorContents));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genAccessors(Map<String, List<GenInfoExtracted>> ports) {
    final buffer = StringBuffer();

    for (final genLogic in ports.values.flattened) {
      final type = genLogic.type ?? 'Logic';
      buffer.writeln('$type get ${genLogic.name} => '
          "port('${genLogic.name}') as $type;");
    }

    return buffer.toString();
  }

  static String _genConstructorContents(
      Map<String, List<GenInfoExtracted>> ports) {
    final buffer = StringBuffer();

    ports.forEach((group, genLogics) {
      for (final genLogic in genLogics) {
        buffer.writeln(
            "setPorts([Logic.port('${genLogic.name}', ${genLogic.width})] "
            ',[$group]);');
      }
    });

    return buffer.toString();
  }
}
