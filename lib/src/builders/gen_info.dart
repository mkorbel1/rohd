import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:collection/collection.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/generator_utils.dart';
import 'package:rohd/src/builders/parameters.dart';
import 'package:source_gen/source_gen.dart';

enum LogicType {
  /// a simple [Logic]
  logic,

  /// a [LogicArray]
  array,

  /// a [LogicStructure], or some other derivative class
  typed;

  static LogicType fromTypeName(String typeName) {
    switch (typeName) {
      case 'Logic':
      case 'LogicNet':
        return LogicType.logic;
      case 'LogicArray':
        return LogicType.array;
      default:
        return LogicType.typed;
    }
  }

  String? toConstructorName({required bool isNet}) {
    switch (this) {
      case LogicType.logic:
        return isNet ? 'LogicNet' : 'Logic';
      case LogicType.array:
        return isNet ? 'LogicArray.net' : 'LogicArray';
      case LogicType.typed:
        return null; // Structs don't have a specific type name
    }
  }
}

class GenInfo {
  //TODO: should run sanitizer on the name?

  /// The name to use for the [Logic].
  final String? logicName;

  final String? description; //TODO: test multi-line descriptions

  final LogicType logicType;

  // plain logic specific
  final int? width;

  // array-specific
  final List<int>? dimensions;
  final int? numUnpackedDimensions;

  final bool? isNet;

  const GenInfo({
    required this.logicType,
    String? name,
    this.width,
    this.dimensions,
    this.numUnpackedDimensions,
    this.description,
    required this.isNet,
  }) : logicName = name;
}

class GenInfoExtracted extends GenInfo {
  /// Type of parameter, or null if it is not an argument to the constructor.
  final ParamType? paramType;

  /// A string like 'Logic' representing the name of the type.
  final String typeName;

  final String annotationName;

  final String name;

  final bool isConditional;

  final bool isInitialized;

  /// If provided, the name of a reference variable that can be used for
  /// construction of [widthString], etc.
  final String? referenceName;

  @override
  String get logicName => super.logicName ?? name;

  @override
  bool get isNet => super.isNet!;

  factory GenInfoExtracted.ofAnnotationConst(
    DartObject annotationConst, {
    required String name,
    required String annotationName,
    required String typeName,
    required StructDefaultConstructorType? structDefaultConstructorType,
    required String? referenceName,
    required bool isInitialized,
    required ParamType? paramType,
    required bool isConditional,
  }) {
    var logicName = annotationConst.getField('logicName')!.isNull
        ? null
        : annotationConst.getField('logicName')!.toStringValue();

    logicName ??= name;

    final width = annotationConst.getField('width')!.isNull
        ? null
        : annotationConst.getField('width')!.toIntValue();

    final description = annotationConst.getField('description')!.isNull
        ? null
        : annotationConst.getField('description')!.toStringValue();

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

    var isNet = annotationConst.getField('isNet')!.isNull
        ? null
        : annotationConst.getField('isNet')!.toBoolValue();

    if (typeName == 'LogicNet') {
      isNet = true;
    }

    // if we have no remaining indication that it's a net, its probably not
    isNet ??= false;

    return GenInfoExtracted(
        name: name,
        logicName: logicName,
        paramType: paramType,
        width: width,
        description: description,
        isConditional: isConditional,
        dimensions: dimensions,
        numUnpackedDimensions: numUnpackedDimensions,
        isNet: isNet,
        annotationName: annotationName,
        typeName: typeName,
        structDefaultConstructorType: structDefaultConstructorType,
        referenceName: referenceName,
        isInitialized: isInitialized);
  }

  GenInfoExtracted({
    required this.name,
    required String? logicName,
    required this.paramType,
    required super.width,
    required super.description,
    required this.isConditional,
    required super.dimensions,
    required super.numUnpackedDimensions,
    required bool super.isNet,
    required this.annotationName,
    required this.typeName,
    required this.structDefaultConstructorType,
    required this.referenceName,
    required this.isInitialized,
  }) : super(
          logicType: LogicType.fromTypeName(typeName),
          name: logicName,
        );

  /// The `width` or `elementWidth` argument, if any, passed in from the
  /// module's constructor.
  String? get widthName => switch (logicType) {
        LogicType.logic => width != null ? null : '${name}Width',
        LogicType.array => width != null ? null : '${name}ElementWidth',
        LogicType.typed => null, // structs don't have width
      };

  String? get numUnpackedDimensionsName => switch (logicType) {
        LogicType.logic => null, // logic doesn't have dimensions
        LogicType.array =>
          numUnpackedDimensions == null ? '${name}NumUnpackedDimensions' : null,
        LogicType.typed => null, // structs don't have dimensions
      };

  String? get dimensionsName => switch (logicType) {
        LogicType.logic => null, // logic doesn't have dimensions
        LogicType.array => dimensions == null ? '${name}Dimensions' : null,
        LogicType.typed => null, // structs don't have dimensions
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
        LogicType.array => _widthSettingWithReferenceAdjustment(
              'dimensions',
              dimensions == null ? dimensionsName! : 'const $dimensions',
              isNamed: !isLogicConstructor,
            ) +
            switch (width) {
              1 => '',
              _ => _widthSettingWithReferenceAdjustment(
                  'elementWidth',
                  width == null ? widthName! : '$width',
                  isNamed: !isLogicConstructor,
                ),
            } +
            switch (numUnpackedDimensions) {
              0 => '',
              _ => _widthSettingWithReferenceAdjustment(
                  'numUnpackedDimensions',
                  numUnpackedDimensions == null
                      ? numUnpackedDimensionsName!
                      : '$numUnpackedDimensions',
                  isNamed: true,
                ),
            },
        LogicType.typed => '',
      };

  List<FormalParameter> configurationParameters(ParamPosition extraPosition) {
    final isNullable = referenceName != null;

    return <FormalParameter>[
      if (widthName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: extraPosition.toParamType(isRequired: false),
          isNullable: isNullable,
          name: widthName!,
          type: 'int',
          defaultValue: isNullable ? null : '1',
        ),
      if (dimensionsName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: extraPosition.toParamType(isRequired: false),
          isNullable: isNullable,
          name: dimensionsName!,
          type: 'List<int>',
          defaultValue: isNullable ? null : 'const [1]',
        ),
      if (numUnpackedDimensionsName != null)
        FormalParameter(
          varLocation: ParamVarLocation.constructor,
          paramType: extraPosition.toParamType(isRequired: false),
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
      FieldElement2 field, String annotationName) {
    final annotation = extractAnnotation(field, annotationName);

    if (annotation == null) {
      return null;
    }

    final name = field.name3!;
    final isNullable =
        field.type.nullabilitySuffix == NullabilitySuffix.question;

    final annotationConst =
        annotation.computeConstantValue()!.getField('(super)')!;

    final typeName = field.type.getDisplayString().replaceAll('?', '');

    StructDefaultConstructorType? structDefaultConstructorType;
    if (typeName != 'Logic' &&
        typeName != 'LogicArray' &&
        typeName != 'LogicNet') {
      final element = field.type.element3;

      if (element is ClassElement2) {
        structDefaultConstructorType =
            extractStructDefaultConstructorType(element);
      }
    }

    return GenInfoExtracted.ofAnnotationConst(
      annotationConst,
      name: name,
      paramType: null,
      isConditional: isNullable,
      typeName: typeName,
      referenceName: null,
      structDefaultConstructorType: structDefaultConstructorType,
      isInitialized: field.hasInitializer,
      annotationName: annotationName,
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
      return StructDefaultConstructorType.noName;
    }
  }

  static ({
    StructDefaultConstructorType structDefaultConstructorType,
    bool anyOthers
  }) extractStructDefaultConstructorTypeForCloning(ClassElement2 element) {
    final defaultConstructor =
        element.constructors2.firstWhereOrNull((c) => c.name3 == 'new');

    if (defaultConstructor == null) {
      return (
        structDefaultConstructorType: StructDefaultConstructorType.unusable,
        anyOthers: true
      );
    }

    var anyOthers = false;
    if (element.constructors2.length > 1) {
      // if there's another way to construct it, also need to avoid
      anyOthers = true;
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
      structDefaultConstructorType = StructDefaultConstructorType.noName;
    }

    return (
      structDefaultConstructorType: structDefaultConstructorType,
      anyOthers: anyOthers
    );
  }

  /// Returns `null` if the parameter does not have any port annotation.
  static GenInfoExtracted? ofAnnotatedParameter(
      FormalParameterElement param, String annotationName) {
    final annotation = extractAnnotation(param, annotationName);

    if (annotation == null) {
      return null;
    }

    if (param.hasDefaultValue) {
      throw Exception('Cannot have a default value for a port argument.');
    }

    final name = param.name3!;
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

    var typeName = param.type.getDisplayString().replaceAll('?', '');

    if (typeName.trim().isEmpty || typeName == 'dynamic') {
      // assume it's a normal `Logic` if not specified on a parameter
      typeName = 'Logic';
    }

    return GenInfoExtracted.ofAnnotationConst(
      annotationConst,
      name: name,
      paramType: paramType,
      annotationName: annotationName,
      isConditional: isNullable,
      referenceName: name,
      isInitialized: true, // since it's always provided
      typeName: typeName,
      structDefaultConstructorType: null, // since we can clone
    );
  }

  /// If [logicType] is [LogicType.typed], the type of default constructor
  /// available, else `null`.
  StructDefaultConstructorType? structDefaultConstructorType;

  /// If possible, a string that constructs an instance of this signal.
  ///
  /// If it is not possible, it will return `null`, signalling an implementation
  /// must be provided.
  ///
  /// If a [nameVariable] is provided, then it will use that instead of [name].
  String? genConstructorCall({Naming? naming, String? nameVariable}) {
    switch (logicType) {
      case LogicType.typed:
        return genStructConstructorCall(
          structDefaultConstructorType,
          typeName: typeName,
          logicName: logicName,
          nameVariable: nameVariable,
        );
      case LogicType.logic || LogicType.array:
        final namingStr = naming == null ? '' : ', naming: $naming';
        final nameStr = nameVariable ?? "'$logicName'";
        return '${logicType.toConstructorName(isNet: isNet)}(name: $nameStr'
            ' ${widthString(isLogicConstructor: true)} $namingStr)';
    }
  }

  static String? genStructConstructorCall(
    StructDefaultConstructorType? structDefaultConstructorType, {
    required String typeName,
    required String logicName,
    String? nameVariable,
  }) {
    if (structDefaultConstructorType == null) {
      return null;
    }

    final name = nameVariable ?? "'$logicName'";

    switch (structDefaultConstructorType) {
      case StructDefaultConstructorType.unusable:
        return null; // No usable constructor
      case StructDefaultConstructorType.noName:
        return '$typeName()';
      case StructDefaultConstructorType.namePositional:
        return '$typeName($name)';
      case StructDefaultConstructorType.nameNamed:
        return '$typeName(name: $name)';
    }
  }
}

enum StructDefaultConstructorType {
  /// The default, we can't infer anything special to construct the struct
  /// automatically.
  unusable,

  /// The struct has a default constructor that can be used to construct it,
  /// with no arguments passed.  A `name` argument is not available.
  noName,

  /// The struct has a default constructor that can be used to construct it,
  /// with positional `name` passed as the first argument.
  namePositional,

  /// The struct has a default constructor that can be used to construct it,
  /// with named `name` passed as an argument.
  nameNamed;
}
