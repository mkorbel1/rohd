// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_logic_structure_test.dart';

// **************************************************************************
// LogicStructureGenerator
// **************************************************************************

abstract class _$ExampleStructWithGen extends LogicStructure {
  set b(Logic b);
  set a(Logic a);

  _$ExampleStructWithGen({
    super.name = 'ExampleStructWithGen',
    int bWidth = 1,
    int aWidth = 1,
  }) : super([
          Logic(name: 'b', width: bWidth, naming: Naming.mergeable),
          Logic(name: 'a', width: aWidth, naming: Naming.mergeable)
        ]) {
    this.b = elements[0] as Logic;
    this.a = elements[1] as Logic;
  }

  @override
  // This clone method does not properly rename the clone.
  @mustBeOverridden
  ExampleStructWithGen clone({String? name}) => ExampleStructWithGen();
}

abstract class _$KitchenSinkStruct extends LogicStructure {
  set basic(Logic basic);

  _$KitchenSinkStruct({
    super.name = 'KitchenSinkStruct',
    int basicWidth = 1,
  }) : super([
          Logic(name: 'basic', width: basicWidth, naming: Naming.mergeable)
        ]) {
    this.basic = elements[0] as Logic;
  }

  @override
  KitchenSinkStruct clone({String? name}) =>
      KitchenSinkStruct(name: 'KitchenSinkStruct');
}
