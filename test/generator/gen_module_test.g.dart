// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

abstract class _$ExampleModuleWithGen extends Module {
  @visibleForOverriding
  set b(Logic b);

  @protected
  Logic get a => input('a');

  /// The external source for the [a] port.
  Logic get aSource => inputSource('a');

  _$ExampleModuleWithGen(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
    int bWidth = 1,
    int? aWidth,
  }) : super() {
    b = addOutput('b', width: bWidth);

    addInput('a', a, width: aWidth ?? a.width);
  }
}

abstract class _$NonSuperInputMod extends Module {
  @protected
  Logic get a => input('a');

  /// The external source for the [a] port.
  Logic get aSource => inputSource('a');

  _$NonSuperInputMod(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
    int? aWidth,
  }) : super() {
    addInput('a', a, width: aWidth ?? a.width);
  }
}

abstract class _$GenSubMod extends GenBaseMod {
  @visibleForOverriding
  set b(Logic b);

  @protected
  Logic get a => input('a');

  /// The external source for the [a] port.
  Logic get aSource => inputSource('a');

  _$GenSubMod(
    Logic a, {
    required super.myFlag,
    int bWidth = 1,
    int? aWidth,
  }) : super.new() {
    b = addOutput('b', width: bWidth);

    addInput('a', a, width: aWidth ?? a.width);
  }
}

abstract class _$KitchenGenSinkModule extends Module {
  @protected
  @visibleForOverriding
  set topIn(Logic topIn);

  /// The external source for the [topIn] port.
  late final Logic topInSource;

  @visibleForOverriding
  set topOut(Logic topOut);

  @visibleForOverriding
  set topOutCond(Logic? topOutCond);

  @visibleForOverriding
  set topOutWider(Logic topOutWider);

  @visibleForOverriding
  set topOutDynWidth(Logic topOutDynWidth);

  @visibleForOverriding
  set topOutNewName(Logic topOutNewName);

  @visibleForOverriding
  set topOutArray(LogicArray topOutArray);

  @visibleForOverriding
  set topOutArrayUnspecified(LogicArray topOutArrayUnspecified);

  @protected
  @visibleForOverriding
  set topInOut(Logic topInOut);

  /// The external source for the [topInOut] port.
  late final Logic topInOutSource;

  @protected
  Logic get botInPos => input('botInPos');

  /// The external source for the [botInPos] port.
  Logic get botInPosSource => inputSource('botInPos');

  @protected
  Logic? get botInPosNullable => tryInput('botInPosNullable');

  /// The external source for the [botInPosNullable] port.
  Logic? get botInPosNullableSource => tryInputSource('botInPosNullable');

  @protected
  Logic get botInNamed => input('botInNamed');

  /// The external source for the [botInNamed] port.
  Logic get botInNamedSource => inputSource('botInNamed');

  @protected
  Logic? get botInNamedOptional => tryInput('botInNamedOptional');

  /// The external source for the [botInNamedOptional] port.
  Logic? get botInNamedOptionalSource => tryInputSource('botInNamedOptional');

  _$KitchenGenSinkModule(
    Logic botInPos,
    Logic? botInPosNullable, {
    required Logic botInNamed,
    Logic? botInNamedOptional,
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
    required bool topOutCondIsPresent,
    int topInWidth = 1,
    int topOutWidth = 1,
    int topOutCondWidth = 1,
    int topOutDynWidthWidth = 1,
    int topOutNewNameWidth = 1,
    int topOutArrayUnspecifiedElementWidth = 1,
    List<int> topOutArrayUnspecifiedDimensions = const [1],
    int topOutArrayUnspecifiedNumUnpackedDimensions = 0,
    int topInOutWidth = 1,
    int? botInPosWidth,
    int? botInPosNullableWidth,
    int? botInNamedWidth,
    int? botInNamedOptionalWidth,
  }) : super() {
    topInSource =
        Logic(name: 'topIn', width: topInWidth, naming: Naming.mergeable);
    topIn = addInput('topIn', topInSource, width: topInWidth);

    topOut = addOutput('topOut', width: topOutWidth);

    topOutCond = topOutCondIsPresent
        ? addOutput('topOutCond', width: topOutCondWidth)
        : null;

    topOutWider = addOutput('topOutWider', width: 8);

    topOutDynWidth = addOutput('topOutDynWidth', width: topOutDynWidthWidth);

    topOutNewName = addOutput('top_out_new_name', width: topOutNewNameWidth);

    topOutArray = addOutputArray('topOutArray',
        dimensions: const [2, 3], elementWidth: 4, numUnpackedDimensions: 1);

    topOutArrayUnspecified = addOutputArray('topOutArrayUnspecified',
        dimensions: topOutArrayUnspecifiedDimensions,
        elementWidth: topOutArrayUnspecifiedElementWidth,
        numUnpackedDimensions: topOutArrayUnspecifiedNumUnpackedDimensions);

    topInOutSource =
        Logic(name: 'topInOut', width: topInOutWidth, naming: Naming.mergeable);
    topInOut = addInOut('topInOut', topInOutSource, width: topInOutWidth);

    addInput('botInPos', botInPos, width: botInPosWidth ?? botInPos.width);

    if (botInPosNullable != null) {
      addInput('botInPosNullable', botInPosNullable,
          width: botInPosNullableWidth ?? botInPosNullable.width);
    }

    addInput('botInNamed', botInNamed,
        width: botInNamedWidth ?? botInNamed.width);

    if (botInNamedOptional != null) {
      addInput('botInNamedOptional', botInNamedOptional,
          width: botInNamedOptionalWidth ?? botInNamedOptional.width);
    }
  }
}
