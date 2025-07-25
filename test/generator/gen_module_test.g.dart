// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

abstract class _$ExampleModuleWithGen extends Module {
  Logic get b;
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
  }) : super() {
    b = addOutput('b', width: bWidth);

    addInput('a', a, width: aWidth);
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
  }) : super() {
    addInput('a', a, width: aWidth);
  }
}

abstract class _$GenSubMod extends GenBaseMod {
  Logic get b;
  @visibleForOverriding
  set b(Logic b);

  @protected
  Logic get a => input('a');

  /// The external source for the [a] port.
  Logic get aSource => inputSource('a');

  _$GenSubMod(
    Logic a, {
    required super.myFlag,
  }) : super.new() {
    b = addOutput('b', width: bWidth);

    addInput('a', a, width: aWidth);
  }
}

abstract class _$KitchenGenSinkModule extends Module {
  @protected
  Logic get topIn;
  @visibleForOverriding
  set topIn(Logic topIn);

  /// The external source for the [topIn] port.
  late final Logic topInSource;

  Logic get topOut;
  @visibleForOverriding
  set topOut(Logic topOut);

  Logic? get topOutCond;
  @visibleForOverriding
  set topOutCond(Logic? topOutCond);

  Logic get topOutWider;
  @visibleForOverriding
  set topOutWider(Logic topOutWider);

  Logic get topOutDynWidth;
  @visibleForOverriding
  set topOutDynWidth(Logic topOutDynWidth);

  Logic get topOutNewName;
  @visibleForOverriding
  set topOutNewName(Logic topOutNewName);

  LogicArray get topOutArray;
  @visibleForOverriding
  set topOutArray(LogicArray topOutArray);

  @protected
  Logic get topInOut;
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
        elementWidth: 4, dimensions: const [2, 3], numUnpackedDimensions: 1);

    topInOutSource =
        Logic(name: 'topInOut', width: topInOutWidth, naming: Naming.mergeable);
    topInOut = addInOut('topInOut', topInOutSource, width: topInOutWidth);

    addInput('botInPos', botInPos, width: botInPosWidth);

    if (botInPosNullable != null) {
      addInput('botInPosNullable', botInPosNullable,
          width: botInPosNullableWidth);
    }

    addInput('botInNamed', botInNamed, width: botInNamedWidth);

    if (botInNamedOptional != null) {
      addInput('botInNamedOptional', botInNamedOptional,
          width: botInNamedOptionalWidth);
    }
  }
}
