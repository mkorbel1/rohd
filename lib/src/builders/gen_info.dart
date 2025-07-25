import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:collection/collection.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

class GenInfo {
  //TODO: should run sanitizer on the name?

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

  // final bool isNet; //TODO: need this?

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

  @override
  String get logicName => super.logicName ?? name;

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
    this.structDefaultConstructorType,
  });

  /// Returns `null` if the field does not have any annotation.
  static GenInfoExtracted? ofAnnotatedField(
      FieldElement field, String annotationName) {
    final annotation = field.metadata.firstWhereOrNull(
      (m) => m.element2?.enclosingElement2?.name3 == annotationName,
    );

    if (annotation == null) {
      return null;
    }

    final name = field.name;
    final isNullable =
        field.type.nullabilitySuffix == NullabilitySuffix.question;

    final annotationConst =
        annotation.computeConstantValue()!.getField('(super)')!;

    final logicName = annotationConst.getField('logicName')!.isNull
        ? null
        : annotationConst.getField('logicName')!.toStringValue();

    final width = annotationConst.getField('width')!.isNull
        ? null
        : annotationConst.getField('width')!.toIntValue();

    final typeName = field.type.getDisplayString().replaceAll('?', '');

    final dimensions = annotationConst.getField('dimensions')!.isNull
        ? null
        : annotationConst
            .getField('dimensions')!
            .toListValue()!
            .map((e) => e.toIntValue()!)
            .toList();

    final numUnpackedDimensions =
        annotationConst.getField('numUnpackedDimensions')!.isNull
            ? null
            : annotationConst.getField('numUnpackedDimensions')!.toIntValue();

    return GenInfoExtracted(
      name: name,
      logicName: logicName ?? name,
      paramType: null,
      width: width,
      isConditional: isNullable,
      typeName: typeName,
      dimensions: dimensions,
      numUnpackedDimensions: numUnpackedDimensions,
      //TODO rest of the fields
    );
  }

  /// Returns `null` if the parameter does not have any port annotation.
  static GenInfoExtracted? ofAnnotatedParameter(ParameterElement param) {
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

    final name = param.name;
    final isNullable =
        param.type.nullabilitySuffix == NullabilitySuffix.question;

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
      isConditional: isNullable,
      width: width,
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

    var typeName = oConst.read('type').isNull
        ? 'Logic'
        : oConst.read('type').typeValue.getDisplayString();

    // Attempt to extract constructor arguments from the type, if available
    StructDefaultConstructorType? structDefaultConstructorType;
    if (typeName != 'Logic' &&
        typeName != 'LogicArray' &&
        !oConst.read('type').isNull) {
      final typeObj = oConst.read('type').typeValue;
      final element = typeObj.element3;
      if (element is ClassElement2) {
        final defaultConstructor =
            element.constructors2.firstWhereOrNull((c) => c.name3 == 'new');
        if (defaultConstructor != null) {
          var hasNamedName = false;
          var hasPositionalName = false;
          var hasNonNameRequiredArgs = false;

          for (final formalParam in defaultConstructor.formalParameters) {
            if (formalParam.name3 == 'name') {
              if (formalParam.isPositional) {
                hasPositionalName = true;
              } else {
                hasNamedName = true;
              }
            } else if (formalParam.isRequired) {
              hasNonNameRequiredArgs = true;
            }
          }

          assert(!(hasNamedName && hasPositionalName),
              'Should not be possible to have both');

          if (hasNonNameRequiredArgs) {
            structDefaultConstructorType =
                StructDefaultConstructorType.unusable;
          } else if (hasNamedName) {
            structDefaultConstructorType =
                StructDefaultConstructorType.nameNamed;
          } else if (hasPositionalName) {
            structDefaultConstructorType =
                StructDefaultConstructorType.namePositional;
          } else {
            structDefaultConstructorType = StructDefaultConstructorType.none;
          }
        }
      }
    }

    if (dimensions != null) {
      typeName = 'LogicArray';
    }

    return GenInfoExtracted(
      name: name,
      logicName: logicName,
      width: width,
      description: description,
      isConditional: isConditional,
      paramType: null, // Not a constructor parameter
      dimensions: dimensions,
      typeName: typeName,
      structDefaultConstructorType: structDefaultConstructorType,
    );
  }

  /// If [isStruct], the type of default constructor available, else `null`.
  StructDefaultConstructorType? structDefaultConstructorType;

  /// If possible, a string that constructs an instance of this signal.
  ///
  /// If it is not possible, it will return `null`, signalling an implementation
  /// must be provided.
  String? genConstructorCall({Naming? naming}) {
    if (isStruct) {
      return _genStructConstructorCall();
    }

    // TODO: what about nets?

    final namingStr = naming == null ? '' : ', naming: $naming';

    if (isArray) {
      return "LogicArray(name: '$name', "
          'dimensions: $dimensions, '
          'elementWidth: $width, '
          'numUnpackedDimensions: $numUnpackedDimensions $namingStr)';
    } else {
      return "Logic(name: '$name', width: $width $namingStr)";
    }
  }

  String? _genStructConstructorCall() {
    assert(isStruct,
        'Cannot generate struct constructor call for non-struct type: $typeName');

    switch (structDefaultConstructorType!) {
      case StructDefaultConstructorType.unusable:
        return null; // No usable constructor
      case StructDefaultConstructorType.none:
        return '$typeName()';
      case StructDefaultConstructorType.namePositional:
        return "$typeName('$logicName')";
      case StructDefaultConstructorType.nameNamed:
        return "$typeName(name: '$logicName')";
    }
  }

  @override
  bool get isStruct => typeName != 'Logic' && typeName != 'LogicArray';

  @override
  bool get isArray => dimensions != null && typeName == 'LogicArray';
}

enum StructDefaultConstructorType {
  /// The default, we can't infer anything special to construct the struct
  /// automatically.
  unusable,

  /// The struct has a default constructor that can be used to construct it,
  /// with no arguments passed.
  none,

  /// The struct has a default constructor that can be used to construct it,
  /// with positional `name` passed as the first argument.
  namePositional,

  /// The struct has a default constructor that can be used to construct it,
  /// with named `name` passed as an argument.
  nameNamed;
}
