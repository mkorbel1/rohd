// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_setters_without_getters, unused_element_parameter

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

abstract class _$ExampleModuleWithGen extends Module {
  @visibleForOverriding
  set b(Logic b);

  @protected
  Logic get a => input('a');

  /// The [inputSource] for the [a] port.
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

  /// The [inputSource] for the [a] port.
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

  /// The [inputSource] for the [a] port.
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

  /// The [inputSource] for the [topIn] port.
  late final Logic topInSource;

  @protected
  @visibleForOverriding
  set topInNewName(Logic topInNewName);

  /// The [inputSource] for the [topInNewName] port.
  late final Logic topInNewNameSource;

  @protected
  @visibleForOverriding
  set topIn8bit(Logic topIn8bit);

  /// The [inputSource] for the [topIn8bit] port.
  late final Logic topIn8bitSource;

  /// top in desc
  @protected
  @visibleForOverriding
  set topInDesc(Logic topInDesc);

  /// The [inputSource] for the [topInDesc] port.
  late final Logic topInDescSource;

  @protected
  @visibleForOverriding
  set topInCond(Logic? topInCond);

  /// The [tryInputSource] for the [topInCond] port.
  late final Logic? topInCondSource;

  @protected
  @visibleForOverriding
  set topInArray(LogicArray topInArray);

  /// The [inputSource] for the [topInArray] port.
  late final LogicArray topInArraySource;

  /// top in array specified
  /// in multiple lines
  ///
  /// with a blank line later too
  @protected
  @visibleForOverriding
  set topInArraySpecd(LogicArray topInArraySpecd);

  /// The [inputSource] for the [topInArraySpecd] port.
  late final LogicArray topInArraySpecdSource;

  @protected
  @visibleForOverriding
  set topInArrayCond(LogicArray? topInArrayCond);

  /// The [tryInputSource] for the [topInArrayCond] port.
  late final LogicArray? topInArrayCondSource;

  @protected
  @visibleForOverriding
  set noArgStruct(NoArgStruct noArgStruct);

  /// The [inputSource] for the [noArgStruct] port.
  late final NoArgStruct noArgStructSource;

  @protected
  @visibleForOverriding
  set namedNameableStruct(NamedNameableStruct namedNameableStruct);

  /// The [inputSource] for the [namedNameableStruct] port.
  late final NamedNameableStruct namedNameableStructSource;

  @protected
  @visibleForOverriding
  set posNameableStruct(PosNameableStruct posNameableStruct);

  /// The [inputSource] for the [posNameableStruct] port.
  late final PosNameableStruct posNameableStructSource;

  @protected
  @visibleForOverriding
  set optPosNameableStruct(OptPosNameableStruct optPosNameableStruct);

  /// The [inputSource] for the [optPosNameableStruct] port.
  late final OptPosNameableStruct optPosNameableStructSource;

  @protected
  @visibleForOverriding
  set optionalNonNameArgsStruct(
      OptionalNonNameArgsStruct optionalNonNameArgsStruct);

  /// The [inputSource] for the [optionalNonNameArgsStruct] port.
  late final OptionalNonNameArgsStruct optionalNonNameArgsStructSource;

  @protected
  @visibleForOverriding
  set requiredNonNameArgsStruct(
      RequiredNonNameArgsStruct requiredNonNameArgsStruct);

  /// The [inputSource] for the [requiredNonNameArgsStruct] port.
  late final RequiredNonNameArgsStruct requiredNonNameArgsStructSource;

  /// specd struct desc
  @protected
  @visibleForOverriding
  set namedNameableStructSpecd(NamedNameableStruct namedNameableStructSpecd);

  /// The [inputSource] for the [namedNameableStructSpecd] port.
  late final NamedNameableStruct namedNameableStructSpecdSource;

  @protected
  @visibleForOverriding
  set topTypedLogicIn(Logic topTypedLogicIn);

  /// The [inputSource] for the [topTypedLogicIn] port.
  late final Logic topTypedLogicInSource;

  @protected
  @visibleForOverriding
  set topTypedLogicArrayIn(LogicArray topTypedLogicArrayIn);

  /// The [inputSource] for the [topTypedLogicArrayIn] port.
  late final LogicArray topTypedLogicArrayInSource;

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
  set topOutArray(LogicArray topOutArray);

  @visibleForOverriding
  set topOutArrayUnspecified(LogicArray topOutArrayUnspecified);

  @protected
  @visibleForOverriding
  set topInOut(Logic topInOut);

  /// The [inOutSource] for the [topInOut] port.
  late final Logic topInOutSource;

  @protected
  Logic get botInPos => input('botInPos');

  /// The [inputSource] for the [botInPos] port.
  Logic get botInPosSource => inputSource('botInPos');

  @protected
  Logic get botInPosWidthed => input('botInPosWidthed');

  /// The [inputSource] for the [botInPosWidthed] port.
  Logic get botInPosWidthedSource => inputSource('botInPosWidthed');

  @protected
  Logic? get botInPosNullable => tryInput('botInPosNullable');

  /// The [tryInputSource] for the [botInPosNullable] port.
  Logic? get botInPosNullableSource => tryInputSource('botInPosNullable');

  @protected
  Logic get botInNamed => input('botInNamed');

  /// The [inputSource] for the [botInNamed] port.
  Logic get botInNamedSource => inputSource('botInNamed');

  @protected
  Logic? get botInNamedOptional => tryInput('botInNamedOptional');

  /// The [tryInputSource] for the [botInNamedOptional] port.
  Logic? get botInNamedOptionalSource => tryInputSource('botInNamedOptional');

  _$KitchenGenSinkModule(
    Logic botInPos,
    Logic botInPosWidthed,
    Logic? botInPosNullable, {
    required Logic botInNamed,
    required bool topOutCondIsPresent,
    required bool topInArrayCondIsPresent,
    required bool topInCondIsPresent,
    required this.requiredNonNameArgsStructSource,
    OptionalNonNameArgsStruct? optionalNonNameArgsStructSource,
    Logic? botInNamedOptional,
    super.name,
    super.reserveName,
    NoArgStruct? noArgStructSource,
    NamedNameableStruct? namedNameableStructSource,
    PosNameableStruct? posNameableStructSource,
    OptPosNameableStruct? optPosNameableStructSource,
    super.definitionName,
    super.reserveDefinitionName,
    NamedNameableStruct? namedNameableStructSpecdSource,
    int topInWidth = 1,
    int topInNewNameWidth = 1,
    int topInDescWidth = 1,
    int topInCondWidth = 1,
    int topInArrayElementWidth = 1,
    List<int> topInArrayDimensions = const [1],
    int topInArrayNumUnpackedDimensions = 0,
    int topInArrayCondElementWidth = 1,
    List<int> topInArrayCondDimensions = const [1],
    int topInArrayCondNumUnpackedDimensions = 0,
    int topTypedLogicInWidth = 1,
    int? botInNamedOptionalWidth,
    List<int> topTypedLogicArrayInDimensions = const [1],
    int topTypedLogicArrayInNumUnpackedDimensions = 0,
    int topOutWidth = 1,
    int topOutNewNameWidth = 1,
    int topOutDescWidth = 1,
    int topOutCondWidth = 1,
    int topOutArrayUnspecifiedElementWidth = 1,
    List<int> topOutArrayUnspecifiedDimensions = const [1],
    int topOutArrayUnspecifiedNumUnpackedDimensions = 0,
    int topInOutWidth = 1,
    int? botInPosWidth,
    int? botInPosNullableWidth,
    int? botInNamedWidth,
    int topTypedLogicArrayInElementWidth = 1,
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

    topInArraySource = LogicArray(
        name: 'topInArray',
        topInArrayDimensions,
        topInArrayElementWidth,
        numUnpackedDimensions: topInArrayNumUnpackedDimensions,
        naming: Naming.mergeable);
    topInArray = addInputArray('topInArray', topInArraySource,
        dimensions: topInArrayDimensions,
        elementWidth: topInArrayElementWidth,
        numUnpackedDimensions: topInArrayNumUnpackedDimensions);

    topInArraySpecdSource = LogicArray(
        name: 'topInArraySpecd',
        const [7, 6],
        4,
        numUnpackedDimensions: 1,
        naming: Naming.mergeable);
    topInArraySpecd = addInputArray('top_in_array_specd', topInArraySpecdSource,
        dimensions: const [7, 6], elementWidth: 4, numUnpackedDimensions: 1);

    topInArrayCondSource = topInArrayCondIsPresent
        ? LogicArray(
            name: 'topInArrayCond',
            topInArrayCondDimensions,
            topInArrayCondElementWidth,
            numUnpackedDimensions: topInArrayCondNumUnpackedDimensions,
            naming: Naming.mergeable)
        : null;
    topInArrayCond = topInArrayCondIsPresent
        ? addInputArray('topInArrayCond', topInArrayCondSource!,
            dimensions: topInArrayCondDimensions,
            elementWidth: topInArrayCondElementWidth,
            numUnpackedDimensions: topInArrayCondNumUnpackedDimensions)
        : null;

    this.noArgStructSource = noArgStructSource ?? (NoArgStruct());
    noArgStruct = addTypedInput('noArgStruct', this.noArgStructSource);

    this.namedNameableStructSource = namedNameableStructSource ??
        (NamedNameableStruct('namedNameableStruct'));
    namedNameableStruct =
        addTypedInput('namedNameableStruct', this.namedNameableStructSource);

    this.posNameableStructSource = posNameableStructSource ??
        (PosNameableStruct(name: 'posNameableStruct'));
    posNameableStruct =
        addTypedInput('posNameableStruct', this.posNameableStructSource);

    this.optPosNameableStructSource = optPosNameableStructSource ??
        (OptPosNameableStruct('optPosNameableStruct'));
    optPosNameableStruct =
        addTypedInput('optPosNameableStruct', this.optPosNameableStructSource);

    this.optionalNonNameArgsStructSource = optionalNonNameArgsStructSource ??
        (OptionalNonNameArgsStruct(name: 'optionalNonNameArgsStruct'));
    optionalNonNameArgsStruct = addTypedInput(
        'optionalNonNameArgsStruct', this.optionalNonNameArgsStructSource);

    requiredNonNameArgsStruct = addTypedInput(
        'requiredNonNameArgsStruct', requiredNonNameArgsStructSource);

    this.namedNameableStructSpecdSource =
        namedNameableStructSpecdSource ?? (NamedNameableStruct('specd_struct'));
    namedNameableStructSpecd =
        addTypedInput('specd_struct', this.namedNameableStructSpecdSource);

    topTypedLogicInSource = Logic(
        name: 'topTypedLogicIn',
        width: topTypedLogicInWidth,
        naming: Naming.mergeable);
    topTypedLogicIn = addInput('topTypedLogicIn', topTypedLogicInSource,
        width: topTypedLogicInWidth);

    topTypedLogicArrayInSource = LogicArray(
        name: 'topTypedLogicArrayIn',
        topTypedLogicArrayInDimensions,
        topTypedLogicArrayInElementWidth,
        numUnpackedDimensions: topTypedLogicArrayInNumUnpackedDimensions,
        naming: Naming.mergeable);
    topTypedLogicArrayIn = addInputArray(
        'topTypedLogicArrayIn', topTypedLogicArrayInSource,
        dimensions: topTypedLogicArrayInDimensions,
        elementWidth: topTypedLogicArrayInElementWidth,
        numUnpackedDimensions: topTypedLogicArrayInNumUnpackedDimensions);

    topOut = addOutput('topOut', width: topOutWidth);

    topOutNewName = addOutput('top_out_new_name', width: topOutNewNameWidth);

    topOutWider = addOutput('topOutWider', width: 8);

    topOutDesc = addOutput('topOutDesc', width: topOutDescWidth);

    topOutCond = topOutCondIsPresent
        ? addOutput('topOutCond', width: topOutCondWidth)
        : null;

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
