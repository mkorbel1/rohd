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
  // This clone method does not create the matching type.
  @mustBeOverridden
  LogicStructure clone({String? name}) => super.clone(name: name);
}

abstract class _$KitchenSinkStruct extends LogicStructure {
  set struct(ExampleStructWithGen struct);
  set array(LogicArray array);
  set basic(Logic basic);

  _$KitchenSinkStruct({
    super.name = 'KitchenSinkStruct',
    int arrayElementWidth = 1,
    List<int> arrayDimensions = const [1],
    int arrayNumUnpackedDimensions = 0,
    int basicWidth = 1,
  }) : super([
          ExampleStructWithGen(),
          LogicArray(
              name: 'array',
              arrayDimensions,
              arrayElementWidth,
              numUnpackedDimensions: arrayNumUnpackedDimensions,
              naming: Naming.mergeable),
          Logic(name: 'basic', width: basicWidth, naming: Naming.mergeable)
        ]) {
    this.struct = elements[0] as ExampleStructWithGen;
    this.array = elements[1] as LogicArray;
    this.basic = elements[2] as Logic;
  }

  @override
  // This clone method does not create the matching type.
  @mustBeOverridden
  LogicStructure clone({String? name}) => super.clone(name: name);
}
