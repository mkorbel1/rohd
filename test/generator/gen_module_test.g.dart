// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_setters_without_getters

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

  @protected
  @visibleForOverriding
  set topInNewName(Logic topInNewName);

  /// The external source for the [topInNewName] port.
  late final Logic topInNewNameSource;

  @protected
  @visibleForOverriding
  set topIn8bit(Logic topIn8bit);

  /// The external source for the [topIn8bit] port.
  late final Logic topIn8bitSource;

  /// top in desc
  @protected
  @visibleForOverriding
  set topInDesc(Logic topInDesc);

  /// The external source for the [topInDesc] port.
  late final Logic topInDescSource;

  @protected
  @visibleForOverriding
  set topInCond(Logic? topInCond);

  /// The external source for the [topInCond] port.
  late final Logic? topInCondSource;

  @visibleForOverriding
  set topOut(Logic topOut);

  @visibleForOverriding
  set topOutNewName(Logic topOutNewName);

  @visibleForOverriding
  set topOutWider(Logic topOutWider);

  /// top out desc
  @visibleForOverriding
  set topOutDesc(Logic topOutDesc);

  @visibleForOverriding
  set topOutCond(Logic? topOutCond);

  @visibleForOverriding
  set topOutDynWidth(Logic topOutDynWidth);

  @visibleForOverriding
  set topOutArrayUnspecDims(LogicArray topOutArrayUnspecDims);

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
  Logic get botInPosWidthed => input('botInPosWidthed');

  /// The external source for the [botInPosWidthed] port.
  Logic get botInPosWidthedSource => inputSource('botInPosWidthed');

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
    Logic botInPosWidthed,
    Logic? botInPosNullable, {
    required Logic botInNamed,
    Logic? botInNamedOptional,
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
    required bool topInCondIsPresent,
    required bool topOutCondIsPresent,
    int topInWidth = 1,
    int topInNewNameWidth = 1,
    int topInDescWidth = 1,
    int topInCondWidth = 1,
    int topOutWidth = 1,
    int topOutNewNameWidth = 1,
    int topOutDescWidth = 1,
    int topOutCondWidth = 1,
    int topOutDynWidthWidth = 1,
    int topOutArrayUnspecDimsElementWidth = 1,
    List<int> topOutArrayUnspecDimsDimensions = const [1],
    int topOutArrayUnspecDimsNumUnpackedDimensions = 0,
    int topInOutWidth = 1,
    int? botInPosWidth,
    int? botInPosNullableWidth,
    int? botInNamedWidth,
    int? botInNamedOptionalWidth,
  }) : super() {
    topInSource =
        Logic(name: 'topIn', width: topInWidth, naming: Naming.mergeable);
    topIn = addInput('topIn', topInSource, width: topInWidth);

    topInNewNameSource = Logic(
        name: 'topInNewName',
        width: topInNewNameWidth,
        naming: Naming.mergeable);
    topInNewName = addInput('top_in_new_name', topInNewNameSource,
        width: topInNewNameWidth);

    topIn8bitSource =
        Logic(name: 'topIn8bit', width: 8, naming: Naming.mergeable);
    topIn8bit = addInput('topIn8bit', topIn8bitSource, width: 8);

    topInDescSource = Logic(
        name: 'topInDesc', width: topInDescWidth, naming: Naming.mergeable);
    topInDesc = addInput('topInDesc', topInDescSource, width: topInDescWidth);

    topInCondSource = topInCondIsPresent
        ? Logic(
            name: 'topInCond', width: topInCondWidth, naming: Naming.mergeable)
        : null;
    topInCond = topInCondIsPresent
        ? addInput('topInCond', topInCondSource!, width: topInCondWidth)
        : null;

    topOut = addOutput('topOut', width: topOutWidth);

    topOutNewName = addOutput('top_out_new_name', width: topOutNewNameWidth);

    topOutWider = addOutput('topOutWider', width: 8);

    topOutDesc = addOutput('topOutDesc', width: topOutDescWidth);

    topOutCond = topOutCondIsPresent
        ? addOutput('topOutCond', width: topOutCondWidth)
        : null;

    topOutDynWidth = addOutput('topOutDynWidth', width: topOutDynWidthWidth);

    topOutArrayUnspecDims = addOutputArray('topOutArrayUnspecDims',
        dimensions: topOutArrayUnspecDimsDimensions,
        elementWidth: topOutArrayUnspecDimsElementWidth,
        numUnpackedDimensions: topOutArrayUnspecDimsNumUnpackedDimensions);

    topInOutSource =
        Logic(name: 'topInOut', width: topInOutWidth, naming: Naming.mergeable);
    topInOut = addInOut('topInOut', topInOutSource, width: topInOutWidth);

    addInput('botInPos', botInPos, width: botInPosWidth ?? botInPos.width);

    addInput('botInPosWidthed', botInPosWidthed, width: 7);

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
