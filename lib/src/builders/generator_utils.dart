import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
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

ElementAnnotation? extractAnnotation(
        Annotatable field, String annotationName) =>
    field.metadata2.annotations.firstWhereOrNull(
        (a) => a.element2?.enclosingElement2?.displayName == annotationName);

/// Creates a string to put into the constructor args.
String _constructorArguments(List<FormalParameter> params) {
  if (params.map((e) => e.name).toSet().length != params.length) {
    throw ArgumentError('Duplicate parameter names found in constructor');
  }

  final requiredPositionalArgs = params
      .where((p) => p.paramType == ParamType.requiredPositional)
      .map((p) => '$p,')
      .join();

  final optionalPositionalArgs = params
      .where((p) => p.paramType == ParamType.optionalPositional)
      .map((p) => '$p,')
      .join();

  final namedArgs = (params.where((p) => p.paramType.isNamed).toList()..sort())
      .map((p) => '$p,')
      .join();

  if (namedArgs.isNotEmpty && optionalPositionalArgs.isNotEmpty) {
    throw ArgumentError(
        'Cannot have both optional positional and named arguments');
  }

  return [
    requiredPositionalArgs,
    if (optionalPositionalArgs.isNotEmpty) '[$optionalPositionalArgs]',
    if (namedArgs.isNotEmpty) '{$namedArgs}',
  ].join();
}

/// Creates a string to put into the super call.
String _superArguments(List<SuperParameter> params) {
  if (params.map((e) => e.name).toSet().length != params.length) {
    throw ArgumentError('Duplicate parameter names found in constructor');
  }

  final positionalArgs = params.where((p) => p.type.isPositional);

  final namedArgs = params.where((p) => p.type.isNamed);

  return [
    if (positionalArgs.isNotEmpty) positionalArgs.join(','),
    if (namedArgs.isNotEmpty) '{${namedArgs.join(',')}}',
  ].join();
}

/// Creates the constructor with given [contents].
String genConstructor({
  required String constructorName,
  required String superConstructor,
  required List<FormalParameter> constructorParams,
  required List<SuperParameter> superParams,
  required String contents,
}) {
  final buffer = StringBuffer();
  buffer.writeln('  $constructorName(');

  buffer.writeln(_constructorArguments(constructorParams));

  buffer.writeln(')');

  buffer.writeln(' : $superConstructor(${_superArguments(superParams)}) {');

  buffer.writeln(contents);

  buffer.writeln('  }');
  return buffer.toString();
}

/// Takes a [content] string and makes it print so that all new lines are
/// prepended with `///`.
String genMultilineDocComment(String content) =>
    content.trim().split('\n').map((e) => '/// $e').join('\n');
