// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_module_test.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

class _$ExampleModuleWithGen extends Module {
  @protected
  late final Logic a;
  Logic get b => output('b');
  _$ExampleModuleWithGen(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    this.a = addInput('a', a);
    addOutput('b', width: 1);
  }
}

class _$NonSuperInputMod extends Module {
  @protected
  late final Logic a;
  _$NonSuperInputMod(
    Logic a, {
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    this.a = addInput('a', a);
  }
}

class _$GenSubMod extends GenBaseMod {
  @protected
  late final Logic a;
  Logic get b => output('b');
  _$GenSubMod(
    Logic a, {
    required super.myFlag,
  }) : super.new() {
    this.a = addInput('a', a);
    addOutput('b', width: 1);
  }
}

class _$KitchenGenSinkModule extends Module {
  @protected
  late final Logic topIn;
  @protected
  late final Logic botInPos;
  @protected
  late final Logic botInNamed;
  @protected
  late final Logic topInOut;

  /// This is the top output
  Logic get topOut => output('topOut');
  Logic get topOutCond => output('topOutCond');
  Logic get topOutWider => output('topOutWider');
  Logic get topOutDynWidth => output('topOutDynWidth');
  Logic get topOutNewName => output('topOutNewName');
  Logic get topOutNet => output('topOutNet');
  Logic get topOutArray => output('topOutArray');
  _$KitchenGenSinkModule(
    Logic botInPos, {
    required Logic botInNamed,
    super.name,
    super.reserveName,
    super.definitionName,
    super.reserveDefinitionName,
  }) : super() {
    this.topIn = addInput('topIn', topIn, width: 1);
    this.botInPos = addInput('botInPos', botInPos);
    this.botInNamed = addInput('botInNamed', botInNamed);
    addOutput('topOut', width: 1);
    addOutput('topOutCond', width: 1);
    addOutput('topOutWider', width: 8);
    addOutput('topOutDynWidth', width: 1);
    addOutput('topOutNewName', width: 1);
    addOutput('topOutNet', width: 1);
    addOutput('topOutArray', width: 4);
  }
}
