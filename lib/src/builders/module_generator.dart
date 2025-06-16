import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';

import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/interface_generator.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

enum _PortDirection {
  input(forInternalUsage: true),
  output(),
  inOut(forInternalUsage: true);

  final bool forInternalUsage;

  const _PortDirection({this.forInternalUsage = false});

  String get moduleAccessorName => name;

  static _PortDirection ofAnnotationName(String annotationName) {
    switch (annotationName) {
      case 'Input':
        return _PortDirection.input;
      case 'Output':
        return _PortDirection.output;
      case 'InOut':
        return _PortDirection.inOut;
      default:
        throw ArgumentError(
            'Unknown port direction annotation name: $annotationName');
    }
  }
}

enum _PortInfoOrigin {
  constructorArgAnnotation,
  classAnnotation,
}

class _PortInfo {
  final _PortDirection direction;
  final _PortInfoOrigin origin;
  final GenInfoExtracted genInfo;

  _PortInfo({
    required this.genInfo,
    required this.direction,
    required this.origin,
  });

  String get createConditionName => genInfo.isConditional
      ? '${genInfo.name}IsPresent'
      : throw Exception('Should not be called for non-conditional ports');

  String get sourceName => switch (origin) {
        _PortInfoOrigin.classAnnotation => '${genInfo.name}Source',
        _PortInfoOrigin.constructorArgAnnotation => genInfo.name
      };

  String moduleAccessor() {
    // TODO: handle structs
    var accessorFunction = switch (direction) {
      _PortDirection.input => 'input',
      _PortDirection.output => 'output',
      _PortDirection.inOut => 'inOut'
    };

    final buffer = StringBuffer();

    if (genInfo.description != null) {
      buffer.writeln(genMultilineDocComment(genInfo.description!));
    }
    if (direction.forInternalUsage) {
      buffer.writeln('@protected');
    }

    var type = genInfo.typeName;

    if (genInfo.isConditional) {
      final capsVersion =
          accessorFunction[0].toUpperCase() + accessorFunction.substring(1);
      accessorFunction = 'try$capsVersion';

      type += '?';
    }

    var castStr = '';
    if (genInfo.isArray) {
      castStr = ' as $type';
    }

    buffer.writeln('$type get ${genInfo.name} =>'
        " $accessorFunction('${genInfo.logicName}')$castStr;");

    if (origin == _PortInfoOrigin.classAnnotation &&
        (direction == _PortDirection.input ||
            direction == _PortDirection.inOut)) {
      // we need to declare the source variable
      buffer.writeln('/// The external source for the [${genInfo.name}] port.');

      //TODO: what about when struct can't be made?
      final constructorCall =
          genInfo.genConstructorCall(naming: Naming.mergeable);

      buffer.writeln('final $type $sourceName = $constructorCall;');
    }

    return buffer.toString();
  }

  String modulePortCreator() {
    final creator = switch (direction) {
      _PortDirection.input => 'addInput',
      _PortDirection.output => 'addOutput',
      _PortDirection.inOut => 'addInOut'
    };

    final sourceStr = switch (direction) {
      _PortDirection.input || _PortDirection.inOut => ', $sourceName',
      _PortDirection.output => '',
    };

    final widthString = genInfo.width != null && genInfo.width != 1
        ? ', width: ${genInfo.width}'
        : '';

    final portCreationString =
        "$creator('${genInfo.logicName}' $sourceStr $widthString);";

    if (genInfo.isConditional) {
      final condition = switch (origin) {
        _PortInfoOrigin.classAnnotation => createConditionName,
        _PortInfoOrigin.constructorArgAnnotation => '${genInfo.name} != null',
      };
      return 'if($condition) { $portCreationString }';
    } else {
      return portCreationString;
    }
  }

  static _PortInfo? ofAnnotatedParameter(ParameterElement param) {
    final genInfo = GenInfoExtracted.ofAnnotatedParameter(param);
    if (genInfo == null) {
      return null;
    }

    return _PortInfo(
      genInfo: genInfo,
      direction: _PortDirection.ofAnnotationName(genInfo.annotationName!),
      origin: _PortInfoOrigin.constructorArgAnnotation,
    );
  }

  static _PortInfo ofGenLogicConstReader(
      ConstantReader oConst, _PortDirection direction) {
    final genInfo = GenInfoExtracted.ofGenLogicConstReader(oConst);

    return _PortInfo(
      genInfo: genInfo,
      direction: direction,
      origin: _PortInfoOrigin.classAnnotation,
    );
  }
}

class ModuleGenerator extends GeneratorForAnnotation<GenModule> {
  static List<_PortInfo> _extractPortsFromConstructor(
      ConstructorElement constructor) {
    final portInfos = <_PortInfo>[];
    for (final param in constructor.parameters) {
      final portInfo = _PortInfo.ofAnnotatedParameter(param);
      if (portInfo != null) {
        portInfos.add(portInfo);
      }
    }
    return portInfos;
  }

  static List<_PortInfo> _extractPortsFromAnnotation(
      ConstantReader annotation) {
    final portInfos = <_PortInfo>[];

    final annotationFieldToDirection = {
      'inputs': _PortDirection.input,
      'outputs': _PortDirection.output,
      'inOuts': _PortDirection.inOut,
    };

    for (final MapEntry(key: field, value: direction)
        in annotationFieldToDirection.entries) {
      final dirPortInfos = annotation.peek(field)?.listValue.map((o) {
            final oConst = ConstantReader(o);
            return _PortInfo.ofGenLogicConstReader(oConst, direction);
          }).toList() ??
          [];

      portInfos.addAll(dirPortInfos);
    }

    return portInfos;
  }

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final sourceClassName = element.name!;
    final genClassName = '_\$$sourceClassName';

    final superParams = <SuperParameter>[];
    final constructorParams = <FormalParameter>[];

    final portInfos = <_PortInfo>[
      ..._extractPortsFromAnnotation(annotation),
    ];

    final classElement = element as ClassElement;

    for (final constructor in classElement.constructors
        .where((c) => !c.isFactory && !c.isSynthetic)) {
      portInfos.addAll(_extractPortsFromConstructor(constructor));
    }

    // any constructor args need to be listed as parameters in the constructor
    for (final portInfo in portInfos
        .where((p) => p.origin == _PortInfoOrigin.constructorArgAnnotation)) {
      constructorParams.add(FormalParameter(
        paramType: portInfo.genInfo.paramType!,
        name: portInfo.genInfo.name,
        varLocation: ParamVarLocation.constructor,
        type: portInfo.genInfo.typeName,
        isNullable: portInfo.genInfo.isConditional,
      ));
    }

    // Extract baseConstructor from the annotation
    final baseConstructor = annotation.peek('baseConstructor')?.objectValue;
    final String baseClassName;
    final String superConstructor;

    if (baseConstructor == null) {
      // can't tear-off `Module.new` since it's abstract, so set up manually
      baseClassName = 'Module';
      superConstructor = 'super';
      const moduleBaseParams = [
        'name',
        'reserveName',
        'definitionName',
        'reserveDefinitionName',
      ];
      constructorParams.addAll(moduleBaseParams.map(
        (name) => FormalParameter(
          paramType: ParamType.namedOptional,
          name: name,
          varLocation: ParamVarLocation.super_,
          type: null,
        ),
      ));
    } else {
      final parsedBaseConstructor = parseBaseConstructor(baseConstructor);
      baseClassName = parsedBaseConstructor.baseClassName;
      superConstructor = parsedBaseConstructor.superConstructor;
      superParams.addAll(parsedBaseConstructor.superParams);
      constructorParams.addAll(parsedBaseConstructor.constructorParams);
    }

    // Add arguments for all the optional presence of ports
    for (final portInfo in portInfos
        .where((p) => p.origin == _PortInfoOrigin.classAnnotation)) {
      if (portInfo.genInfo.isConditional) {
        constructorParams.add(FormalParameter(
          paramType: ParamType.namedRequired,
          name: portInfo.createConditionName,
          varLocation: ParamVarLocation.constructor,
          type: 'bool',
        ));
      }
    }

    final buffer = StringBuffer();
    buffer.writeln('class $genClassName extends $baseClassName {');

    // Generate module accessors
    buffer.writeln(_genAccessors(portInfos));

    final constructorContents = _genConstructorContents(portInfos);

    buffer.writeln(genConstructor(
      constructorName: genClassName,
      contents: constructorContents,
      superConstructor: superConstructor,
      constructorParams: constructorParams,
      superParams: superParams,
    ));

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _genAccessors(List<_PortInfo> portInfos) {
    final buffer = StringBuffer();

    for (final p in portInfos) {
      buffer.writeln(p.moduleAccessor());
    }

    return buffer.toString();
  }

  static String _genConstructorContents(List<_PortInfo> portInfos) {
    final buffer = StringBuffer();

    for (final port in portInfos) {
      buffer.writeln(port.modulePortCreator());
    }

    return buffer.toString();
  }
}
