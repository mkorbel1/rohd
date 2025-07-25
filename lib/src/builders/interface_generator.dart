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

  static Map<String, List<GenInfoExtracted>> _extractPortsFromClass(
      Element element) {
    final ports = <String, List<GenInfoExtracted>>{};
    const annotationType = 'IntfPort';
    if (element is ClassElement) {
      for (final field in element.fields) {
        final genInfo =
            GenInfoExtracted.ofAnnotatedField(field, annotationType);

        if (genInfo != null) {
          final annotation = field.metadata.firstWhere(
            (m) => m.element2?.enclosingElement2?.name3 == annotationType,
          );
          final tagAnnotationConst =
              annotation.computeConstantValue()!.getField('tag')!;

          final tagTypeName = tagAnnotationConst.type!.getDisplayString();
          final tagValueName =
              ConstantReader(tagAnnotationConst.getField('_name')).stringValue;

          final tagType = '$tagTypeName.$tagValueName';

          ports.putIfAbsent(tagType, () => []).add(genInfo);
        }
      }
    }
    return ports;
  }

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

    final ports = _extractPortsFromClass(element);

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

    for (final structPort in ports.values.flattened
        .where((e) => e.logicType == LogicType.struct)) {
      final isOptional = structPort.isConditional ||
          structPort.structDefaultConstructorType! !=
              StructDefaultConstructorType.unusable;

      constructorParams.add(FormalParameter(
        paramType:
            isOptional ? ParamType.namedOptional : ParamType.namedRequired,
        name: structPort.name,
        type: structPort.typeName,
        isNullable: isOptional,
        varLocation: ParamVarLocation.constructor,
      ));
    }

    for (final port in ports.values.flattened) {
      constructorParams.addAll(port.configurationParameters);
    }

    final buffer = StringBuffer();
    buffer.writeln('abstract class $genClassName extends $baseClassName {');
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

    for (final genInfo in ports.values.flattened) {
      var type = genInfo.typeName;

      if (genInfo.isConditional) {
        type += '?';
      }

      buffer.writeln('$type get ${genInfo.name};');
      buffer.writeln('@visibleForOverriding '
          'set ${genInfo.name}(${type} ${genInfo.name});');
    }

    return buffer.toString();
  }

  static String _genConstructorContents(
      Map<String, List<GenInfoExtracted>> ports) {
    final buffer = StringBuffer();

    ports.forEach((group, genLogics) {
      for (final genLogic in genLogics) {
        final String portString;

        final constructorString = genLogic.genConstructorCall();

        if (genLogic.logicType == LogicType.struct) {
          if (constructorString == null) {
            portString = genLogic.name;
          } else {
            portString = '${genLogic.name} ?? $constructorString';
          }
        } else {
          portString = constructorString!;
        }

        //TODO: handle isConditional

        buffer.writeln('this.${genLogic.name} = setPort($portString, '
            'tags: const [$group], '
            "name: '${genLogic.logicName}');");
      }
    });

    return buffer.toString();
  }
}
