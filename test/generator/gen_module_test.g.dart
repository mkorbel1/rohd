// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

abstract class _$ExampleModuleWithGen extends Module {
  Logic get b;
  set b(Logic b);

  @protected
  Logic get a => input('a');

  _$ExampleModuleWithGen(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    b = addOutput('b');
    addInput('a', a);
  }
}

abstract class _$NonSuperInputMod extends Module {
  @protected
  Logic get a => input('a');

  _$NonSuperInputMod(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    addInput('a', a);
  }
}

abstract class _$GenSubMod extends GenBaseMod {
  Logic get b;
  set b(Logic b);

  @protected
  Logic get a => input('a');

  _$GenSubMod(
    Logic a, {
    required super.myFlag,
  }) : super.new() {
    b = addOutput('b');
    addInput('a', a);
  }
}

abstract class _$KitchenGenSinkModule extends Module {
  @protected
  Logic get topIn;
  set topIn(Logic topIn);

  Logic get topOut;
  set topOut(Logic topOut);

  Logic? get topOutCond;
  set topOutCond(Logic? topOutCond);

  Logic get topOutWider;
  set topOutWider(Logic topOutWider);

  Logic get topOutDynWidth;
  set topOutDynWidth(Logic topOutDynWidth);

  Logic get topOutNewName;
  set topOutNewName(Logic topOutNewName);

  LogicArray get topOutArray;
  set topOutArray(LogicArray topOutArray);

  @protected
  Logic get topInOut;
  set topInOut(Logic topInOut);

  @protected
  Logic get botInPos => input('botInPos');

  @protected
  Logic? get botInPosNullable => tryInput('botInPosNullable');

  @protected
  Logic get botInNamed => input('botInNamed');

  @protected
  Logic? get botInNamedOptional => tryInput('botInNamedOptional');

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
    topIn = addInput('topIn', topIn);
    topOut = addOutput('topOut');
    topOutCond = topOutCondIsPresent ? addOutput('topOutCond') : null;
    topOutWider = addOutput('topOutWider', width: 8);
    topOutDynWidth = addOutput('topOutDynWidth');
    topOutNewName = addOutput('top_out_new_name');
    topOutArray = addOutput('topOutArray', width: 4);
    topInOut = addInOut('topInOut', topInOut);
    addInput('botInPos', botInPos);
    if (botInPosNullable != null) {
      addInput('botInPosNullable', botInPosNullable);
    }
    addInput('botInNamed', botInNamed);
    if (botInNamedOptional != null) {
      addInput('botInNamedOptional', botInNamedOptional);
    }
  }
}
