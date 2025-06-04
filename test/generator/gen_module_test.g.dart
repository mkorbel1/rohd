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
    this.a, {
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
    this.a, {
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
  _$GenSubMod({
    super.myFlag,
  }) : super.new() {
    this.a = addInput('a', a);
    addOutput('b', width: 1);
  }
}
