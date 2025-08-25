import 'package:meta/meta.dart';

enum ParamPosition {
  positional,
  named;

  static ParamPosition of({required bool isPositional}) =>
      isPositional ? ParamPosition.positional : ParamPosition.named;

  ParamType toParamType({required bool isRequired}) {
    switch (this) {
      case ParamPosition.positional:
        return isRequired
            ? ParamType.requiredPositional
            : ParamType.optionalPositional;
      case ParamPosition.named:
        return isRequired ? ParamType.namedRequired : ParamType.namedOptional;
    }
  }
}

enum ParamType {
  requiredPositional._(
      isRequired: true, paramPosition: ParamPosition.positional),
  optionalPositional._(paramPosition: ParamPosition.positional),
  namedOptional._(),
  namedRequired._(isRequired: true);

  final bool isRequired;

  final ParamPosition paramPosition;

  bool get isNamed => paramPosition == ParamPosition.named;
  bool get isPositional => paramPosition == ParamPosition.positional;

  const ParamType._(
      {this.isRequired = false, this.paramPosition = ParamPosition.named});

  static ParamType of(
      {required bool isRequired, required ParamPosition paramPosition}) {
    switch (paramPosition) {
      case ParamPosition.positional:
        return isRequired ? requiredPositional : optionalPositional;
      case ParamPosition.named:
        return isRequired ? namedRequired : namedOptional;
    }
  }
}

enum ParamVarLocation {
  constructor,
  super_,
  this_,
}

/// A parameter of the generated class's constructor.
@immutable
class FormalParameter implements Comparable<FormalParameter> {
  final ParamType paramType;

  final String name;

  final String? type;

  final bool isNullable;

  final String? defaultValue;

  final ParamVarLocation varLocation;

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
        return '${requiredPrefix}this.$name$defaultSuffix';

      case ParamVarLocation.constructor:
        final nullableSuffix = isNullable ? '?' : '';

        return '$requiredPrefix $type $nullableSuffix $name$defaultSuffix';
    }
  }

  @override
  int compareTo(FormalParameter other) {
    // Sort by required first (required before non-required)
    if (paramType.isRequired != other.paramType.isRequired) {
      return other.paramType.isRequired ? 1 : -1;
    }
    // Then sort by name
    return name.compareTo(other.name);
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
