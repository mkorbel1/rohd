enum ParamType {
  requiredPositional(isRequired: true, isPositional: true),
  optionalPositional(isPositional: true),
  namedOptional,
  namedRequired(isRequired: true);

  final bool isRequired;
  final bool isPositional;
  bool get isNamed => !isPositional;
  const ParamType({this.isRequired = false, this.isPositional = false});
}

enum ParamVarLocation {
  constructor,
  super_,
  this_,
}

/// A parameter of the generated class's constructor.
class FormalParameter {
  ParamType paramType;

  String name;

  String? type;

  bool isNullable;

  String? defaultValue;

  ParamVarLocation varLocation;

  FormalParameter({
    required this.paramType,
    required this.name,
    required this.varLocation,
    required this.type,
    this.isNullable = false,
    this.defaultValue,
  }) {
    if (paramType.isRequired && defaultValue != null) {
      throw ArgumentError(
          'Required positional parameters cannot have a default value');
    }
    if (varLocation == ParamVarLocation.constructor && type == null) {
      throw ArgumentError('Constructor parameters must have a type specified');
    }
  }

  @override
  String toString() {
    final requiredPrefix =
        paramType == ParamType.namedRequired ? 'required ' : '';

    final defaultSuffix = defaultValue != null ? ' = $defaultValue' : '';

    switch (varLocation) {
      case ParamVarLocation.super_:
        return '${requiredPrefix}super.$name$defaultSuffix';

      case ParamVarLocation.this_:
        return 'this.$name$defaultSuffix';

      case ParamVarLocation.constructor:
        final nullableSuffix = isNullable ? '?' : '';

        return '$requiredPrefix $type $nullableSuffix $name$defaultSuffix';
    }
  }
}

/// A parameter passed to the generated class's super constructor.
class SuperParameter {
  final String name;
  final ParamType type;
  String? value;

  SuperParameter({required this.name, required this.type, this.value});

  @override
  String toString() {
    final valString = value ?? name;
    if (type.isPositional) {
      return valString;
    } else {
      return '$name: $valString';
    }
  }
}
