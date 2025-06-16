// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

class _$ExampleModuleWithGen extends Module {
  Logic get b => output('b');

  @protected
  Logic get a => input('a');

  _$ExampleModuleWithGen(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    addOutput('b');
    addInput('a', a);
  }
}

class _$NonSuperInputMod extends Module {
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

class _$GenSubMod extends GenBaseMod {
  Logic get b => output('b');

  @protected
  Logic get a => input('a');

  _$GenSubMod(
    Logic a, {
    required super.myFlag,
  }) : super.new() {
    addOutput('b');
    addInput('a', a);
  }
}

class _$KitchenGenSinkModule extends Module {
  @protected
  Logic get topIn => input('topIn');

  /// This is the top output
  Logic get topOut => output('topOut');

  Logic? get topOutCond => tryOutput('topOutCond');

  /// This is a wider output.
  ///
  /// It has a multi-line description, as well.
  Logic get topOutWider => output('topOutWider');

  Logic get topOutDynWidth => output('topOutDynWidth');

  Logic get topOutNewName => output('top_out_new_name');

  Logic get topOutArray => output('topOutArray');

  @protected
  Logic get topInOut => inOut('topInOut');

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
    addInput('topIn', topIn);
    addOutput('topOut');
    if (topOutCondIsPresent) {
      addOutput('topOutCond');
    }
    addOutput('topOutWider', width: 8);
    addOutput('topOutDynWidth');
    addOutput('top_out_new_name');
    addOutput('topOutArray', width: 4);
    addInOut('topInOut', topInOut);
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
