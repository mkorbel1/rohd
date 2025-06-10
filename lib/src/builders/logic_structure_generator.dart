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

    buffer.writeln('$genClassName() : super(');
    buffer.writeln('[');
    for (final field in fields) {
      //TODO: what about other types?
      buffer.writeln("Logic(name: '${field.name}'),");
    }
    buffer.writeln('],');
    buffer.writeln("name: '$sourceClassName',"); // TODO: name??
    buffer.writeln(');');

    buffer.writeln('}');

    return buffer.toString();
  }
}
