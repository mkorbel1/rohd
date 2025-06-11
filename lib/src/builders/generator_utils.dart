import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:rohd/src/builders/parameters.dart';

({
  String baseClassName,
  String superConstructor,
  List<SuperParameter> superParams,
  List<FormalParameter> constructorParams
}) parseBaseConstructor(DartObject baseConstructor) {
  final superParams = <SuperParameter>[];
  final constructorParams = <FormalParameter>[];
  final String baseClassName;
  final String superConstructor;

  if (baseConstructor.type is FunctionType) {
    final func = baseConstructor.type! as FunctionType;
    final returnType = func.returnType;

    final parameters = func.formalParameters;

    baseClassName = returnType.getDisplayString();

    // e.g. "GenBaseMod Function({required bool myFlag}) (new)"
    final constructorString = baseConstructor.toString();
    final namedConstructorMatch =
        RegExp(r'\((\w+)\)$').firstMatch(constructorString);
    final namedConstructor = namedConstructorMatch?.group(1);
    if (namedConstructor == null) {
      throw Exception('Could not deduce the name of the'
          ' base constructor from $constructorString');
    }
    superConstructor = 'super.$namedConstructor';

    for (final param in parameters) {
      final paramName = param.displayName;
      final paramType = param.type.getDisplayString();
      final paramDefault = param.defaultValueCode;
      final paramIsNullable =
          param.type.nullabilitySuffix == NullabilitySuffix.question;

      if (param.isPositional) {
        // for positional arguments, we need to transform them into named
        // arguments

        // keep the order the same
        superParams.add(
          SuperParameter(name: paramName, type: ParamType.requiredPositional),
        );

        constructorParams.add(
          FormalParameter(
            paramType: paramDefault == null
                ? ParamType.namedRequired
                : ParamType.namedOptional,
            name: paramName,
            isNullable: paramIsNullable,
            defaultValue: paramDefault,
            varLocation: ParamVarLocation.constructor,
            type: paramType,
          ),
        );
      } else {
        constructorParams.add(
          FormalParameter(
            paramType: param.isRequired
                ? ParamType.namedRequired
                : ParamType.namedOptional,
            name: paramName,
            isNullable: paramIsNullable,
            varLocation: ParamVarLocation.super_,
            type: null,
          ),
        );
      }
    }
  } else {
    throw Exception('`baseConstructor` must be a function type.');
  }

  return (
    baseClassName: baseClassName,
    superConstructor: superConstructor,
    superParams: superParams,
    constructorParams: constructorParams,
  );
}
