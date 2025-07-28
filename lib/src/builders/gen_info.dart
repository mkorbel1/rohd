import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:collection/collection.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

enum LogicType {
  /// a simple [Logic]
  logic,

  /// a [LogicArray]
  array,

  /// a [LogicStructure], or some other derivative class
  struct;

  static LogicType fromTypeName(String typeName) {
    switch (typeName) {
      case 'Logic':
      case 'LogicNet':
        return LogicType.logic;
      case 'LogicArray':
        return LogicType.array;
      default:
        return LogicType.struct;
    }
  }

  String? toTypeName() {
    switch (this) {
      case LogicType.logic:
        return 'Logic';
      case LogicType.array:
        return 'LogicArray';
      case LogicType.struct:
        return null; // Structs don't have a specific type name
    }
  }
}

class GenInfo {
  //TODO: should run sanitizer on the name?

  /// The name to use for the [Logic], if different from the variable [name].
  final String? logicName;

  final String? description; //TODO: test multi-line descriptions

  final LogicType logicType;

  // plain logic specific
  final int? width;

  // array-specific
  final List<int>? dimensions;
  final int? numUnpackedDimensions;

  // final bool isNet; //TODO: need this?

  const GenInfo({
    required this.logicType,
    this.logicName,
    this.width,
    this.dimensions,
    this.numUnpackedDimensions,
    this.description,
    // this.isNet = false,
  });
}

class GenInfoExtracted extends GenInfo {
  /// Type of parameter, or null if it is not an argument to the constructor.
  final ParamType? paramType;

  final String typeName;

  final String? annotationName;

  final String name;

  final bool isConditional;

  /// If provided, the name of a reference variable that can be used for
  /// construction of [widthString], etc.
  final String? referenceName;

  @override
  String get logicName => super.logicName ?? name;

  GenInfoExtracted({
    required this.name,
    required super.logicName,
    required this.paramType,
    super.width,
    super.description,
    this.isConditional = false,
    super.dimensions,
    super.numUnpackedDimensions,
    this.typeName = 'Logic',
    this.annotationName,
    this.structDefaultConstructorType,
    required this.referenceName,
  }) : super(logicType: LogicType.fromTypeName(typeName));

  /// The `width` or `elementWidth` argument, if any, passed in from the
  /// module's constructor.
  String? get widthName => switch (logicType) {
        LogicType.logic => width != null ? null : '${name}Width',
        LogicType.array => width != null ? null : '${name}ElementWidth',
        LogicType.struct => null, // structs don't have width
      };

  String? get numUnpackedDimensionsName => switch (logicType) {
        LogicType.logic => null, // logic doesn't have dimensions
        LogicType.array =>
          numUnpackedDimensions == null ? '${name}NumUnpackedDimensions' : null,
        LogicType.struct => null, // structs don't have dimensions
      };

  String? get dimensionsName => switch (logicType) {
        LogicType.logic => null, // logic doesn't have dimensions
        LogicType.array => dimensions == null ? '${name}Dimensions' : null,
        LogicType.struct => null, // structs don't have dimensions
      };

  String _referenceWidthAdjustment(String widthArgName) {
    if (referenceName == null) {
      return '';
    }

    return '?? $referenceName.$widthArgName';
  }

  String _widthSettingWithReferenceAdjustment(
          String widthArgName, String widthVarName,
          {required bool isNamed}) =>
      [
        ',',
        if (isNamed) ' $widthArgName:',
        ' $widthVarName${_referenceWidthAdjustment(widthArgName)}',
      ].join();

  /// Returns a string representation of the width configuration.
  ///
  /// If [isLogicConstructor], then it will match for a construction of that
  /// [Logic] type. Otherwise, will match for creation of a port.
  String widthString({required bool isLogicConstructor}) => switch (logicType) {
        LogicType.logic => switch (width) {
            null => _widthSettingWithReferenceAdjustment('width', widthName!,
                isNamed: true),
            1 => '',
            _ => ', width: $width',
          },
        LogicType.array => switch (dimensions) {
              null => _widthSettingWithReferenceAdjustment(
                  'dimensions', dimensionsName!,
                  isNamed: !isLogicConstructor),
              _ => ', dimensions: const $dimensions',
            } +
            switch (width) {
              null => _widthSettingWithReferenceAdjustment(
                  'elementWidth', widthName!,
                  isNamed: !isLogicConstructor),
              1 => '',
              _ => ', elementWidth: $width',
            } +
            switch (numUnpackedDimensions) {
              null => _widthSettingWithReferenceAdjustment(
                  'numUnpackedDimensions', numUnpackedDimensionsName!,
                  isNamed: true),
              0 => '',
              _ => ', numUnpackedDimensions: $numUnpackedDimensions',
            },
        LogicType.struct => '',
      };

  List<FormalParameter> get configurationParameters {
    final isNullable = referenceName != null;

    return <FormalParameter>[
      if (widthName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: ParamType.namedOptional,
          isNullable: isNullable,
          name: widthName!,
          type: 'int',
          defaultValue: isNullable ? null : '1',
        ),
      if (dimensionsName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: ParamType.namedOptional,
          isNullable: isNullable,
          name: dimensionsName!,
          type: 'List<int>',
          defaultValue: isNullable ? null : 'const [1]',
        ),
      if (numUnpackedDimensionsName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: ParamType.namedOptional,
          isNullable: isNullable,
          name: numUnpackedDimensionsName!,
          type: 'int',
          defaultValue: isNullable ? null : '0',
        ),
    ];
  }

  //TODO: what if the type of a field/port is a parameterized type of the class?

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

    StructDefaultConstructorType? structDefaultConstructorType;
    if (typeName != 'Logic' && typeName != 'LogicArray') {
      final element = field.type.element3;

      if (element is ClassElement2) {
        structDefaultConstructorType =
            extractStructDefaultConstructorType(element);
      }
    }

    return GenInfoExtracted(
      name: name,
      logicName: logicName ?? name,
      paramType: null,
      width: width,
      isConditional: isNullable,
      typeName: typeName,
      dimensions: dimensions,
      numUnpackedDimensions: numUnpackedDimensions,
      referenceName: null,
      structDefaultConstructorType: structDefaultConstructorType,
      //TODO rest of the fields
    );
  }

  static StructDefaultConstructorType extractStructDefaultConstructorType(
      ClassElement2 element) {
    final defaultConstructor =
        element.constructors2.firstWhereOrNull((c) => c.name3 == 'new');
    if (defaultConstructor == null) {
      return StructDefaultConstructorType.unusable;
    }

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
      return StructDefaultConstructorType.unusable;
    } else if (hasNamedName) {
      return StructDefaultConstructorType.nameNamed;
    } else if (hasPositionalName) {
      return StructDefaultConstructorType.namePositional;
    } else {
      return StructDefaultConstructorType.none;
    }
  }

  static ({
    StructDefaultConstructorType structDefaultConstructorType,
    bool anyOthers
  }) extractStructDefaultConstructorTypeForCloning(ClassElement element) {
    final defaultConstructor =
        element.constructors.firstWhereOrNull((c) => c.name == 'new');

    if (defaultConstructor == null) {
      return (
        structDefaultConstructorType: StructDefaultConstructorType.unusable,
        anyOthers: true
      );
    }

    var anyOthers = false;
    if (element.constructors.length > 1) {
      // if there's another way to construct it, also need to avoid
      anyOthers = true;
    }

    var hasNamedName = false;
    var hasPositionalName = false;
    var hasNonNameRequiredArgs = false;

    for (final formalParam in defaultConstructor.parameters) {
      if (formalParam.name == 'name') {
        if (formalParam.isPositional) {
          hasPositionalName = true;
        } else {
          hasNamedName = true;
        }
      } else {
        anyOthers = true;
        if (formalParam.isRequired) {
          hasNonNameRequiredArgs = true;
        }
      }
    }

    assert(!(hasNamedName && hasPositionalName),
        'Should not be possible to have both');

    final StructDefaultConstructorType structDefaultConstructorType;
    if (hasNonNameRequiredArgs) {
      structDefaultConstructorType = StructDefaultConstructorType.unusable;
    } else if (hasNamedName) {
      structDefaultConstructorType = StructDefaultConstructorType.nameNamed;
    } else if (hasPositionalName) {
      structDefaultConstructorType =
          StructDefaultConstructorType.namePositional;
    } else {
      structDefaultConstructorType = StructDefaultConstructorType.none;
    }

    return (
      structDefaultConstructorType: structDefaultConstructorType,
      anyOthers: anyOthers
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
      referenceName: name,
    );
  }

  // TODO: delete this whole thing?
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
        structDefaultConstructorType =
            extractStructDefaultConstructorType(element);
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
      referenceName: null,
    );
  }

  /// If [logicType] is [LogicType.struct], the type of default constructor
  /// available, else `null`.
  StructDefaultConstructorType? structDefaultConstructorType;

  /// If possible, a string that constructs an instance of this signal.
  ///
  /// If it is not possible, it will return `null`, signalling an implementation
  /// must be provided.
  String? genConstructorCall({Naming? naming}) {
    switch (logicType) {
      case LogicType.struct:
        return genStructConstructorCall(
          structDefaultConstructorType!,
          typeName: typeName,
          logicName: logicName,
        );
      case LogicType.logic || LogicType.array:
        final namingStr = naming == null ? '' : ', naming: $naming';
        return "${logicType.toTypeName()}(name: '$name'"
            ' ${widthString(isLogicConstructor: true)} $namingStr)';
    }
  }

  static String? genStructConstructorCall(
    StructDefaultConstructorType structDefaultConstructorType, {
    required String typeName,
    required String logicName,
  }) {
    switch (structDefaultConstructorType) {
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
