import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

//TODO: support lists of things?

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

    final superParams = <SuperParameter>[];
    final constructorParams = <FormalParameter>[];

    const baseConstructor = null;
    final String baseClassName;
    final String superConstructor;

    // reverse so that first declared fields are most significant
    final fields = _extractFieldsFromClass(element).reversed.toList();

    // no need to tear off Interface.new since it has no args
    baseClassName = 'LogicStructure';
    superConstructor = 'super';

    final elementsValue = [
      '[',
      fields
          .map((field) => field.genConstructorCall(naming: Naming.mergeable))
          .join(','),
      ']',
    ].join();

    // add all the elements as positional arg to super
    superParams.add(SuperParameter(
      name: 'elements',
      type: ParamType.requiredPositional,
      value: elementsValue,
    ));

    constructorParams.add(FormalParameter(
      paramType: ParamType.namedOptional,
      name: 'name',
      varLocation: ParamVarLocation.super_,
      type: 'String',
      defaultValue: "'$sourceClassName'",
    ));

    final buffer = StringBuffer();
    buffer.writeln('abstract class $genClassName extends $baseClassName {');

    buffer.writeln(_genAccessors(fields));

    // TODO: what about struct field creation if not available?

    for (final field in fields) {
      constructorParams.addAll(field.configurationParameters);
    }

    final contents = _genConstructorContents(fields);
    buffer.writeln(genConstructor(
      constructorName: genClassName,
      superConstructor: superConstructor,
      constructorParams: constructorParams,
      superParams: superParams,
      contents: contents,
    ));

    buffer.writeln(_genClone(
      element as ClassElement,
      sourceClassName: sourceClassName,
    ));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genConstructorContents(List<GenInfoExtracted> fields) =>
      _genFieldAssignments(fields);

  static String _genClone(ClassElement annotatedClassElement,
      {required String sourceClassName}) {
    final buffer = StringBuffer();

    buffer.writeln('@override');

    final defaultConstructorInfo =
        GenInfoExtracted.extractStructDefaultConstructorTypeForCloning(
            annotatedClassElement);

    final constructorCall = GenInfoExtracted.genStructConstructorCall(
        defaultConstructorInfo.structDefaultConstructorType,
        typeName: annotatedClassElement.name,
        logicName: annotatedClassElement.name);

    //TODO: if it only has super and this arguments in the base constructor, can we still just generate it?

    if (constructorCall == null || defaultConstructorInfo.anyOthers) {
      // we can't reliably generate a clone for this class which carries the
      // name, just return super and warn that they need to make it themselves
      buffer
          .writeln('  // This clone method does not create the matching type.');
      buffer.writeln('@mustBeOverridden');
      buffer.writeln(
          'LogicStructure clone({String? name}) => super.clone(name: name);');
    } else if (defaultConstructorInfo.structDefaultConstructorType ==
        StructDefaultConstructorType.none) {
      buffer.writeln(
          '  // This clone method does not properly rename the clone.');
      buffer.writeln('@mustBeOverridden');
      buffer.writeln(
          '$sourceClassName clone({String? name}) => $constructorCall;');
    } else {
      buffer.writeln(
          '$sourceClassName clone({String? name}) => $constructorCall;');
    }

    // buffer.writeln('$genClassName clone({String? name}) => $genClassName

    return buffer.toString();
  }

  static String _genFieldAssignments(List<GenInfoExtracted> fields) {
    final buffer = StringBuffer();

    var elementIdx = 0;
    for (final field in fields) {
      buffer.writeln(
          'this.${field.name} = elements[$elementIdx] as ${field.typeName};');

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
      buffer.writeln('set ${field.name}(${field.typeName} ${field.name});');
    }

    return buffer.toString();
  }
}
