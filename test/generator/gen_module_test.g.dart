// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_setters_without_getters, unused_element_parameter, unnecessary_this, lines_longer_than_80_chars

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
    int? aWidth,
    int bWidth = 1,
    super.definitionName,
    super.name = 'ExampleModuleWithGen_inst',
    super.reserveDefinitionName,
    super.reserveName,
  }) : super() {
    this.b = addOutput('b', width: bWidth);

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
    int? aWidth,
    super.definitionName,
    super.name = 'NonSuperInputMod_inst',
    super.reserveDefinitionName,
    super.reserveName,
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
    int? aWidth,
    int bWidth = 1,
  }) : super.new() {
    this.b = addOutput('b', width: bWidth);

    addInput('a', a, width: aWidth ?? a.width);
  }
}

abstract class _$MultiConstructorMod extends Module {
  @protected
  Logic get a => input('a');

  /// The [inputSource] for the [a] port.
  Logic get aSource => inputSource('a');

  @protected
  Logic? get b => tryInput('b');

  /// The [tryInputSource] for the [b] port.
  Logic? get bSource => tryInputSource('b');

  _$MultiConstructorMod(
    Logic? b, {
    required Logic a,
    int? aWidth,
    int? bWidth,
    super.definitionName,
    super.name = 'MultiConstructorMod_inst',
    super.reserveDefinitionName,
    super.reserveName,
  }) : super() {
    addInput('a', a, width: aWidth ?? a.width);

    if (b != null) {
      addInput('b', b, width: bWidth ?? b.width);
    }
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
  set namedNameableStructCond(NamedNameableStruct? namedNameableStructCond);

  /// The [tryInputSource] for the [namedNameableStructCond] port.
  late final NamedNameableStruct? namedNameableStructCondSource;

  @protected
  @visibleForOverriding
  set requiredNonNameArgsStructCond(
      RequiredNonNameArgsStruct? requiredNonNameArgsStructCond);

  /// The [tryInputSource] for the [requiredNonNameArgsStructCond] port.
  late final RequiredNonNameArgsStruct? requiredNonNameArgsStructCondSource;

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

  @visibleForOverriding
  set topOutStruct(NamedNameableStruct topOutStruct);

  @visibleForOverriding
  set topOutStructCond(NamedNameableStruct? topOutStructCond);

  @visibleForOverriding
  set topOutRequiredNonNameArgsStruct(
      RequiredNonNameArgsStruct topOutRequiredNonNameArgsStruct);

  @visibleForOverriding
  set topOutRequiredNonNameArgsStructCond(
      RequiredNonNameArgsStruct? topOutRequiredNonNameArgsStructCond);

  /// top in out desc
  @protected
  @visibleForOverriding
  set topInOut(LogicNet topInOut);

  /// The [inOutSource] for the [topInOut] port.
  late final LogicNet topInOutSource;

  @protected
  @visibleForOverriding
  set topInOutCond(LogicNet? topInOutCond);

  /// The [tryInOutSource] for the [topInOutCond] port.
  late final LogicNet? topInOutCondSource;

  /// top in out arr desc
  @protected
  @visibleForOverriding
  set topInOutArray(LogicArray topInOutArray);

  /// The [inOutSource] for the [topInOutArray] port.
  late final LogicArray topInOutArraySource;

  @protected
  @visibleForOverriding
  set topInOutArrayUnspecified(LogicArray topInOutArrayUnspecified);

  /// The [inOutSource] for the [topInOutArrayUnspecified] port.
  late final LogicArray topInOutArrayUnspecifiedSource;

  @protected
  @visibleForOverriding
  set topInOutArrayCond(LogicArray? topInOutArrayCond);

  /// The [tryInOutSource] for the [topInOutArrayCond] port.
  late final LogicArray? topInOutArrayCondSource;

  /// top in out struct desc
  @protected
  @visibleForOverriding
  set topInOutStruct(InOutStruct topInOutStruct);

  /// The [inOutSource] for the [topInOutStruct] port.
  late final InOutStruct topInOutStructSource;

  @protected
  @visibleForOverriding
  set topInOutStructCond(InOutStruct? topInOutStructCond);

  /// The [tryInOutSource] for the [topInOutStructCond] port.
  late final InOutStruct? topInOutStructCondSource;

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

  /// bot in named renamed desc
  @protected
  Logic get botInNamedRenamed => input('bot_in_named_renamed');

  /// The [inputSource] for the [botInNamedRenamed] port.
  Logic get botInNamedRenamedSource => inputSource('bot_in_named_renamed');

  @protected
  Logic get botTypedInput => input('botTypedInput');

  /// The [inputSource] for the [botTypedInput] port.
  Logic get botTypedInputSource => inputSource('botTypedInput');

  @protected
  LogicArray get botInArrayUnspec => input('botInArrayUnspec') as LogicArray;

  /// The [inputSource] for the [botInArrayUnspec] port.
  LogicArray get botInArrayUnspecSource =>
      inputSource('botInArrayUnspec') as LogicArray;

  /// bot in array specd desc
  @protected
  LogicArray get botInArraySpecd => input('bot_in_array_specd') as LogicArray;

  /// The [inputSource] for the [botInArraySpecd] port.
  LogicArray get botInArraySpecdSource =>
      inputSource('bot_in_array_specd') as LogicArray;

  @protected
  NamedNameableStruct? get botInSpecificStructCond =>
      tryInput('botInSpecificStructCond') as NamedNameableStruct?;

  /// The [tryInputSource] for the [botInSpecificStructCond] port.
  NamedNameableStruct? get botInSpecificStructCondSource =>
      tryInputSource('botInSpecificStructCond') as NamedNameableStruct?;

  /// bot in out desc
  @protected
  Logic get botInOut => inOut('botInOut');

  /// The [inOutSource] for the [botInOut] port.
  Logic get botInOutSource => inOutSource('botInOut');

  @protected
  LogicArray? get botInOutArray => tryInOut('botInOutArray') as LogicArray?;

  /// The [tryInOutSource] for the [botInOutArray] port.
  LogicArray? get botInOutArraySource =>
      tryInOutSource('botInOutArray') as LogicArray?;

  @protected
  InOutStruct get botInOutStruct => inOut('bot_in_out_struct') as InOutStruct;

  /// The [inOutSource] for the [botInOutStruct] port.
  InOutStruct get botInOutStructSource =>
      inOutSource('bot_in_out_struct') as InOutStruct;

  Logic get botOut => output('botOut');

  Logic? get botOutCond => tryOutput('bot_out_cond');

  LogicArray get botOutArr => output('botOutArr') as LogicArray;

  /// bot out struct
  NamedNameableStruct get botOutStruct =>
      output('botOutStruct') as NamedNameableStruct;

  NamedNameableStruct? get botOutStructCond =>
      tryOutput('botOutStructCond') as NamedNameableStruct?;

  _$KitchenGenSinkModule(
    Logic botInPos,
    Logic botInPosWidthed,
    Logic? botInPosNullable, {
    required LogicArray botInArraySpecd,
    required LogicArray botInArrayUnspec,
    required Logic botInNamed,
    required Logic botInNamedRenamed,
    required Logic botInOut,
    required InOutStruct botInOutStruct,
    required Logic botOut,
    required LogicArray botOutArr,
    required NamedNameableStruct botOutStruct,
    required Logic botTypedInput,
    required RequiredNonNameArgsStruct requiredNonNameArgsStruct,
    required RequiredNonNameArgsStruct requiredNonNameArgsStructCond,
    required RequiredNonNameArgsStruct Function({String? name})
        topOutRequiredNonNameArgsStructCondGenerator,
    required RequiredNonNameArgsStruct Function({String? name})
        topOutRequiredNonNameArgsStructGenerator,
    required LogicArray topTypedLogicArrayIn,
    List<int>? botInArrayUnspecDimensions,
    int? botInArrayUnspecElementWidth,
    int? botInArrayUnspecNumUnpackedDimensions,
    Logic? botInNamedOptional,
    int? botInNamedOptionalWidth,
    int? botInNamedRenamedWidth,
    int? botInNamedWidth,
    LogicArray? botInOutArray,
    int? botInOutArrayElementWidth,
    int? botInOutArrayNumUnpackedDimensions,
    int? botInOutWidth,
    int? botInPosNullableWidth,
    int? botInPosWidth,
    NamedNameableStruct? botInSpecificStructCond,
    List<int>? botOutArrDimensions,
    int? botOutArrNumUnpackedDimensions,
    Logic? botOutCond,
    int? botOutCondWidth,
    NamedNameableStruct? botOutStructCond,
    int? botOutWidth,
    super.definitionName,
    super.name = 'KitchenGenSinkModule_inst',
    NamedNameableStruct? namedNameableStruct,
    NamedNameableStruct? namedNameableStructCond,
    bool? namedNameableStructCondIsPresent,
    NamedNameableStruct? namedNameableStructSpecd,
    NoArgStruct? noArgStruct,
    OptPosNameableStruct? optPosNameableStruct,
    OptionalNonNameArgsStruct? optionalNonNameArgsStruct,
    PosNameableStruct? posNameableStruct,
    bool requiredNonNameArgsStructCondIsPresent = true,
    super.reserveDefinitionName,
    super.reserveName,
    List<int> topInArrayCondDimensions = const [1],
    int topInArrayCondElementWidth = 1,
    bool topInArrayCondIsPresent = true,
    int topInArrayCondNumUnpackedDimensions = 0,
    List<int> topInArrayDimensions = const [1],
    int topInArrayElementWidth = 1,
    int topInArrayNumUnpackedDimensions = 0,
    bool topInCondIsPresent = true,
    int topInCondWidth = 1,
    int topInDescWidth = 1,
    int topInNewNameWidth = 1,
    List<int> topInOutArrayCondDimensions = const [1],
    int topInOutArrayCondElementWidth = 1,
    bool topInOutArrayCondIsPresent = true,
    int topInOutArrayCondNumUnpackedDimensions = 0,
    List<int> topInOutArrayUnspecifiedDimensions = const [1],
    int topInOutArrayUnspecifiedElementWidth = 1,
    int topInOutArrayUnspecifiedNumUnpackedDimensions = 0,
    bool topInOutCondIsPresent = true,
    int topInOutCondWidth = 1,
    InOutStruct? topInOutStruct,
    InOutStruct? topInOutStructCond,
    bool? topInOutStructCondIsPresent,
    int topInWidth = 1,
    List<int> topOutArrayUnspecifiedDimensions = const [1],
    int topOutArrayUnspecifiedElementWidth = 1,
    int topOutArrayUnspecifiedNumUnpackedDimensions = 0,
    bool topOutCondIsPresent = true,
    int topOutCondWidth = 1,
    int topOutDescWidth = 1,
    int topOutNewNameWidth = 1,
    bool topOutRequiredNonNameArgsStructCondIsPresent = true,
    NamedNameableStruct Function({String? name})? topOutStructCondGenerator,
    bool? topOutStructCondIsPresent,
    NamedNameableStruct Function({String? name})? topOutStructGenerator,
    int topOutWidth = 1,
    Logic? topTypedLogicIn,
  }) : super() {
    topInSource =
        Logic(name: 'topIn', width: topInWidth, naming: Naming.mergeable);
    this.topIn = addInput('topIn', topInSource, width: topInWidth);

    topInNewNameSource = Logic(
        name: 'top_in_new_name',
        width: topInNewNameWidth,
        naming: Naming.mergeable);
    this.topInNewName = addInput('top_in_new_name', topInNewNameSource,
        width: topInNewNameWidth);

    topIn8bitSource =
        Logic(name: 'topIn8bit', width: 8, naming: Naming.mergeable);
    this.topIn8bit = addInput('topIn8bit', topIn8bitSource, width: 8);

    topInDescSource = Logic(
        name: 'topInDesc', width: topInDescWidth, naming: Naming.mergeable);
    this.topInDesc =
        addInput('topInDesc', topInDescSource, width: topInDescWidth);

    topInCondSource = topInCondIsPresent
        ? Logic(
            name: 'topInCond', width: topInCondWidth, naming: Naming.mergeable)
        : null;
    this.topInCond = topInCondIsPresent
        ? addInput('topInCond', topInCondSource!, width: topInCondWidth)
        : null;

    topInArraySource = LogicArray(
        name: 'topInArray',
        topInArrayDimensions,
        topInArrayElementWidth,
        numUnpackedDimensions: topInArrayNumUnpackedDimensions,
        naming: Naming.mergeable);
    this.topInArray = addInputArray('topInArray', topInArraySource,
        dimensions: topInArrayDimensions,
        elementWidth: topInArrayElementWidth,
        numUnpackedDimensions: topInArrayNumUnpackedDimensions);

    topInArraySpecdSource = LogicArray(
        name: 'top_in_array_specd',
        const [7, 6],
        4,
        numUnpackedDimensions: 1,
        naming: Naming.mergeable);
    this.topInArraySpecd = addInputArray(
        'top_in_array_specd', topInArraySpecdSource,
        dimensions: const [7, 6], elementWidth: 4, numUnpackedDimensions: 1);

    topInArrayCondSource = topInArrayCondIsPresent
        ? LogicArray(
            name: 'topInArrayCond',
            topInArrayCondDimensions,
            topInArrayCondElementWidth,
            numUnpackedDimensions: topInArrayCondNumUnpackedDimensions,
            naming: Naming.mergeable)
        : null;
    this.topInArrayCond = topInArrayCondIsPresent
        ? addInputArray('topInArrayCond', topInArrayCondSource!,
            dimensions: topInArrayCondDimensions,
            elementWidth: topInArrayCondElementWidth,
            numUnpackedDimensions: topInArrayCondNumUnpackedDimensions)
        : null;

    this.noArgStructSource = noArgStruct ?? (NoArgStruct());
    this.noArgStruct = addTypedInput('noArgStruct', this.noArgStructSource);

    this.namedNameableStructSource =
        namedNameableStruct ?? (NamedNameableStruct('namedNameableStruct'));
    this.namedNameableStruct =
        addTypedInput('namedNameableStruct', this.namedNameableStructSource);

    this.posNameableStructSource =
        posNameableStruct ?? (PosNameableStruct(name: 'posNameableStruct'));
    this.posNameableStruct =
        addTypedInput('posNameableStruct', this.posNameableStructSource);

    this.optPosNameableStructSource =
        optPosNameableStruct ?? (OptPosNameableStruct('optPosNameableStruct'));
    this.optPosNameableStruct =
        addTypedInput('optPosNameableStruct', this.optPosNameableStructSource);

    this.optionalNonNameArgsStructSource = optionalNonNameArgsStruct ??
        (OptionalNonNameArgsStruct(name: 'optionalNonNameArgsStruct'));
    this.optionalNonNameArgsStruct = addTypedInput(
        'optionalNonNameArgsStruct', this.optionalNonNameArgsStructSource);

    this.requiredNonNameArgsStructSource = requiredNonNameArgsStruct;
    this.requiredNonNameArgsStruct = addTypedInput(
        'requiredNonNameArgsStruct', requiredNonNameArgsStructSource);

    this.namedNameableStructSpecdSource =
        namedNameableStructSpecd ?? (NamedNameableStruct('specd_struct'));
    this.namedNameableStructSpecd =
        addTypedInput('specd_struct', this.namedNameableStructSpecdSource);

    namedNameableStructCondIsPresent ??= namedNameableStructCond != null;
    this.namedNameableStructCondSource = namedNameableStructCondIsPresent
        ? namedNameableStructCond ??
            (NamedNameableStruct('named_nameable_struct_cond'))
        : null;
    this.namedNameableStructCond = namedNameableStructCondIsPresent
        ? addTypedInput(
            'named_nameable_struct_cond', this.namedNameableStructCondSource!)
        : null;

    this.requiredNonNameArgsStructCondSource = requiredNonNameArgsStructCond;
    this.requiredNonNameArgsStructCond = requiredNonNameArgsStructCondIsPresent
        ? addTypedInput('requiredNonNameArgsStructCond',
            requiredNonNameArgsStructCondSource!)
        : null;

    this.topTypedLogicInSource =
        topTypedLogicIn ?? (Logic(name: 'topTypedLogicIn'));
    this.topTypedLogicIn =
        addTypedInput('topTypedLogicIn', this.topTypedLogicInSource);

    this.topTypedLogicArrayInSource = topTypedLogicArrayIn;
    this.topTypedLogicArrayIn =
        addTypedInput('topTypedLogicArrayIn', topTypedLogicArrayInSource);

    this.topOut = addOutput('topOut', width: topOutWidth);

    this.topOutNewName =
        addOutput('top_out_new_name', width: topOutNewNameWidth);

    this.topOutWider = addOutput('topOutWider', width: 8);

    this.topOutDesc = addOutput('topOutDesc', width: topOutDescWidth);

    this.topOutCond = topOutCondIsPresent
        ? addOutput('topOutCond', width: topOutCondWidth)
        : null;

    this.topOutArray = addOutputArray('topOutArray',
        dimensions: const [2, 3], elementWidth: 4, numUnpackedDimensions: 1);

    this.topOutArrayUnspecified = addOutputArray('topOutArrayUnspecified',
        dimensions: topOutArrayUnspecifiedDimensions,
        elementWidth: topOutArrayUnspecifiedElementWidth,
        numUnpackedDimensions: topOutArrayUnspecifiedNumUnpackedDimensions);

    topOutStructGenerator = topOutStructGenerator ??
        (topOutStructGenerator ??
            (({String? name}) =>
                NamedNameableStruct(name ?? 'top_out_struct')));
    this.topOutStruct = addTypedOutput('top_out_struct', topOutStructGenerator);

    topOutStructCondIsPresent ??= topOutStructCondGenerator != null;
    topOutStructCondGenerator = topOutStructCondGenerator ??
        (topOutStructCondIsPresent
            ? topOutStructCondGenerator ??
                (({String? name}) =>
                    NamedNameableStruct(name ?? 'topOutStructCond'))
            : null);
    this.topOutStructCond = topOutStructCondIsPresent
        ? addTypedOutput('topOutStructCond', topOutStructCondGenerator!)
        : null;

    this.topOutRequiredNonNameArgsStruct = addTypedOutput(
        'topOutRequiredNonNameArgsStruct',
        topOutRequiredNonNameArgsStructGenerator);

    this.topOutRequiredNonNameArgsStructCond =
        topOutRequiredNonNameArgsStructCondIsPresent
            ? addTypedOutput('topOutRequiredNonNameArgsStructCond',
                topOutRequiredNonNameArgsStructCondGenerator)
            : null;

    topInOutSource =
        LogicNet(name: 'top_in_out', width: 3, naming: Naming.mergeable);
    this.topInOut = addInOut('top_in_out', topInOutSource, width: 3);

    topInOutCondSource = topInOutCondIsPresent
        ? LogicNet(
            name: 'topInOutCond',
            width: topInOutCondWidth,
            naming: Naming.mergeable)
        : null;
    this.topInOutCond = topInOutCondIsPresent
        ? addInOut('topInOutCond', topInOutCondSource!,
            width: topInOutCondWidth)
        : null;

    topInOutArraySource = LogicArray.net(
        name: 'top_in_out_arr',
        const [2, 3],
        4,
        numUnpackedDimensions: 1,
        naming: Naming.mergeable);
    this.topInOutArray = addInOutArray('top_in_out_arr', topInOutArraySource,
        dimensions: const [2, 3], elementWidth: 4, numUnpackedDimensions: 1);

    topInOutArrayUnspecifiedSource = LogicArray.net(
        name: 'topInOutArrayUnspecified',
        topInOutArrayUnspecifiedDimensions,
        topInOutArrayUnspecifiedElementWidth,
        numUnpackedDimensions: topInOutArrayUnspecifiedNumUnpackedDimensions,
        naming: Naming.mergeable);
    this.topInOutArrayUnspecified = addInOutArray(
        'topInOutArrayUnspecified', topInOutArrayUnspecifiedSource,
        dimensions: topInOutArrayUnspecifiedDimensions,
        elementWidth: topInOutArrayUnspecifiedElementWidth,
        numUnpackedDimensions: topInOutArrayUnspecifiedNumUnpackedDimensions);

    topInOutArrayCondSource = topInOutArrayCondIsPresent
        ? LogicArray.net(
            name: 'topInOutArrayCond',
            topInOutArrayCondDimensions,
            topInOutArrayCondElementWidth,
            numUnpackedDimensions: topInOutArrayCondNumUnpackedDimensions,
            naming: Naming.mergeable)
        : null;
    this.topInOutArrayCond = topInOutArrayCondIsPresent
        ? addInOutArray('topInOutArrayCond', topInOutArrayCondSource!,
            dimensions: topInOutArrayCondDimensions,
            elementWidth: topInOutArrayCondElementWidth,
            numUnpackedDimensions: topInOutArrayCondNumUnpackedDimensions)
        : null;

    this.topInOutStructSource =
        topInOutStruct ?? (InOutStruct(name: 'top_in_out_struct'));
    this.topInOutStruct =
        addTypedInOut('top_in_out_struct', this.topInOutStructSource);

    topInOutStructCondIsPresent ??= topInOutStructCond != null;
    this.topInOutStructCondSource = topInOutStructCondIsPresent
        ? topInOutStructCond ?? (InOutStruct(name: 'topInOutStructCond'))
        : null;
    this.topInOutStructCond = topInOutStructCondIsPresent
        ? addTypedInOut('topInOutStructCond', this.topInOutStructCondSource!)
        : null;

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

    addInput('bot_in_named_renamed', botInNamedRenamed,
        width: botInNamedRenamedWidth ?? botInNamedRenamed.width);

    addTypedInput('botTypedInput', botTypedInput);

    addInputArray('botInArrayUnspec', botInArrayUnspec,
        dimensions: botInArrayUnspecDimensions ?? botInArrayUnspec.dimensions,
        elementWidth:
            botInArrayUnspecElementWidth ?? botInArrayUnspec.elementWidth,
        numUnpackedDimensions: botInArrayUnspecNumUnpackedDimensions ??
            botInArrayUnspec.numUnpackedDimensions);

    addInputArray('bot_in_array_specd', botInArraySpecd,
        dimensions: const [3, 5], elementWidth: 9, numUnpackedDimensions: 1);

    if (botInSpecificStructCond != null) {
      addTypedInput('botInSpecificStructCond', botInSpecificStructCond);
    }

    addInOut('botInOut', botInOut, width: botInOutWidth ?? botInOut.width);

    if (botInOutArray != null) {
      addInOutArray('botInOutArray', botInOutArray,
          dimensions: const [3, 4],
          elementWidth: botInOutArrayElementWidth ?? botInOutArray.elementWidth,
          numUnpackedDimensions: botInOutArrayNumUnpackedDimensions ??
              botInOutArray.numUnpackedDimensions);
    }

    addTypedInOut('bot_in_out_struct', botInOutStruct);

    addOutput('botOut', width: botOutWidth ?? botOut.width);
    botOut <= this.botOut;

    if (botOutCond != null) {
      addOutput('bot_out_cond', width: botOutCondWidth ?? botOutCond.width);
      botOutCond <= this.botOutCond!;
    }

    addOutputArray('botOutArr',
        dimensions: botOutArrDimensions ?? botOutArr.dimensions,
        elementWidth: 12,
        numUnpackedDimensions:
            botOutArrNumUnpackedDimensions ?? botOutArr.numUnpackedDimensions);
    botOutArr <= this.botOutArr;

    addTypedOutput('botOutStruct', botOutStruct.clone);
    botOutStruct <= this.botOutStruct;

    if (botOutStructCond != null) {
      addTypedOutput('botOutStructCond', botOutStructCond.clone);
      botOutStructCond <= this.botOutStructCond!;
    }
  }
}

abstract class _$OptionalPositionalModule extends Module {
  @protected
  Logic? get optPosIn => tryInput('optPosIn');

  /// The [tryInputSource] for the [optPosIn] port.
  Logic? get optPosInSource => tryInputSource('optPosIn');

  _$OptionalPositionalModule([
    Logic? optPosIn,
    String name = 'OptionalPositionalModule_inst',
    bool reserveName = false,
    String? definitionName,
    bool reserveDefinitionName = false,
    int? optPosInWidth,
  ]) : super(
            name: name,
            reserveName: reserveName,
            definitionName: definitionName,
            reserveDefinitionName: reserveDefinitionName) {
    if (optPosIn != null) {
      addInput('optPosIn', optPosIn, width: optPosInWidth ?? optPosIn.width);
    }
  }
}
