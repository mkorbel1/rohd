import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:collection/collection.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

class GenInfo {
  final String? name;

  /// The name to use for the [Logic], if different from the variable [name].
  final String? logicName;

  final int? width;
  final String? description; //TODO: test multi-line descriptions
  final bool isConditional;

  final List<int>? dimensions;
  bool get isArray => dimensions != null;

  final int? numUnpackedDimensions;

  final Type? type;
  bool get isStruct => type != null;

  // final bool isNet;

  const GenInfo({
    this.name,
    this.logicName,
    this.width,
    this.dimensions,
    this.numUnpackedDimensions,
    this.description,
    this.type,
    this.isConditional = false,
    // this.isNet = false,
  });
}

class GenInfoExtracted extends GenInfo {
  /// Type of parameter, or null if it is not an argument to the constructor.
  final ParamType? paramType;

  final String typeName;

  final String? annotationName;

  @override
  String get name => super.name!;

  GenInfoExtracted({
    required String super.name,
    required super.logicName,
    required this.paramType,
    super.width,
    super.description,
    super.isConditional,
    super.dimensions,
    super.numUnpackedDimensions,
    this.typeName = 'Logic',
    this.annotationName,
  });

  /// Returns `null` if the parameter does not have any port annotation.
  static GenInfoExtracted? ofAnnotatedParameter(ParameterElement param) {
    final name = param.name;
    final isNullable =
        param.type.nullabilitySuffix == NullabilitySuffix.question;

    final annotation = param.metadata.firstWhereOrNull(
      //TODO: make this look at class instead??
      (meta) => meta.element?.displayName == 'Input',
    );

    if (annotation == null) {
      return null;
    }

    if (param.hasDefaultValue) {
      throw Exception('Cannot have a default value for a port argument.');
    }

    final ParamType paramType;
    if (param.isOptionalPositional) {
      paramType = ParamType.optionalPositional;
    } else if (param.isOptionalNamed) {
      paramType = ParamType.namedOptional;
    } else if (param.isRequiredNamed) {
      paramType = ParamType.namedRequired;
    } else if (param.isRequiredPositional) {
      paramType = ParamType.requiredPositional;
    } else {
      throw ArgumentError('Parameter $name has an unknown type');
    }

    final annotationConst =
        annotation.computeConstantValue()!.getField('(super)')!;

    final logicName = annotationConst.getField('logicName')!.isNull
        ? null
        : annotationConst.getField('logicName')!.toStringValue();

    final width = annotationConst.getField('width')!.isNull
        ? null
        : annotationConst.getField('width')!.toIntValue();

    //TODO: rest of the fields

    return GenInfoExtracted(
      name: name,
      logicName: logicName ?? name,
      paramType: paramType,
      annotationName: 'Input', //TODO: for other types
    );
  }

  factory GenInfoExtracted.ofGenLogicConstReader(ConstantReader oConst) {
    final name =
        oConst.read('name').isNull ? null : oConst.read('name').stringValue;

    if (name == null) {
      throw ArgumentError('Port name cannot be null');
    }

    final logicName = oConst.read('logicName').isNull
        ? name
        : oConst.read('logicName').stringValue;

    final width =
        oConst.read('width').isNull ? null : oConst.read('width').intValue;
    final description = oConst.read('description').isNull
        ? null
        : oConst.read('description').stringValue;
    final isConditional = oConst.read('isConditional').boolValue;
    // final isNullable = oConst.read('isNullable').boolValue;
    final dimensions = oConst.read('dimensions').isNull
        ? null
        : oConst
            .read('dimensions')
            .listValue
            .map((e) => e.toIntValue()!)
            .toList();

    var type =
        oConst.read('type').isNull ? 'Logic' : oConst.read('type').stringValue;
    if (dimensions != null) {
      type = 'LogicArray';
    }

    return GenInfoExtracted(
      name: name,
      logicName: logicName,
      width: width,
      description: description,
      isConditional: isConditional,
      paramType: null, // Not a constructor parameter
      dimensions: dimensions,
      typeName: type,
    );
  }
}
