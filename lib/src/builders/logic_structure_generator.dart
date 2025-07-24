import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:source_gen/source_gen.dart';

class LogicStructureGenerator extends GeneratorForAnnotation<GenStruct> {
  static List<GenInfoExtracted> _extractFieldsFromClass(Element element) {
    final fields = <GenInfoExtracted>[];
    if (element is ClassElement) {
      for (final field in element.fields) {
        final genInfo = GenInfoExtracted.ofAnnotatedField(field, 'StructField');

        if (genInfo != null) {
          fields.add(genInfo);
        }
      }
    }
    return fields;
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    const baseClassName = 'LogicStructure';

    // reverse so that first declared fields are most significant
    final fields = _extractFieldsFromClass(element).reversed.toList();

    final buffer = StringBuffer();
    buffer.writeln('abstract class $genClassName extends $baseClassName {');

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
    buffer.writeln(fields
        .map((field) => field.genConstructorCall(naming: Naming.mergeable))
        .join(','));
    buffer.writeln('],');
    buffer.writeln("name: '$constructorName',"); // TODO: name??
    buffer.writeln(') {');
    buffer.writeln(_genFieldAssignments(fields));
    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genFieldAssignments(List<GenInfoExtracted> fields) {
    final buffer = StringBuffer();

    var elementIdx = 0;
    for (final field in fields) {
      buffer.writeln('${field.name} = elements[$elementIdx];');

      elementIdx++;
    }

    return buffer.toString();
  }

  /// The [fields] should be provided in the same order as they are passed to
  /// the super constructor for `LogicStructure`.
  static String _genAccessors(List<GenInfoExtracted> fields) {
    final buffer = StringBuffer();

    for (final field in fields) {
      if (field.description != null) {
        buffer.writeln('/// ${field.description}');
      }
      buffer.writeln('${field.typeName} get ${field.name};');
      buffer.writeln('set ${field.name}(${field.typeName} ${field.name});');
    }

    return buffer.toString();
  }
}
