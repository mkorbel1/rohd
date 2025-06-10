import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:rohd/builder.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:source_gen/source_gen.dart';

class LogicStructureGenerator extends GeneratorForAnnotation<GenStruct> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    const baseClassName = 'LogicStructure';

    final fields = annotation.peek('fields')?.listValue.map((o) {
          final oConst = ConstantReader(o);
          return GenInfoExtracted.ofGenLogicConstReader(oConst);
        }).toList() ??
        [];

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    buffer.writeln(_genAccessors(fields));

    buffer.writeln(_genConstructor(fields, constructorName: genClassName));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genConstructor(List<GenInfoExtracted> fields,
      {required String constructorName}) {
    final buffer = StringBuffer();

    buffer.writeln('$constructorName() : super(');
    buffer.writeln('[');
    for (final field in fields) {
      //TODO: what about other types?
      buffer.writeln("Logic(name: '${field.name}', width: ${field.width}),");
    }
    buffer.writeln('],');
    buffer.writeln("name: '$constructorName',"); // TODO: name??
    buffer.writeln(');');

    return buffer.toString();
  }

  /// The [fields] should be provided in the same order as they are passed to
  /// the super constructor for `LogicStructure`.
  static String _genAccessors(List<GenInfoExtracted> fields) {
    final buffer = StringBuffer();

    var elementIdx = 0;
    for (final field in fields.reversed) {
      // go backwards so that the first field is at the top

      if (field.description != null) {
        buffer.writeln('/// ${field.description}');
      }
      buffer.writeln('late final ${field.typeName} ${field.name}'
          ' = elements[$elementIdx];');

      elementIdx++;
    }

    return buffer.toString();
  }
}
