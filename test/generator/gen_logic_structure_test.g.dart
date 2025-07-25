// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_logic_structure_test.dart';

// **************************************************************************
// LogicStructureGenerator
// **************************************************************************

abstract class _$ExampleStructWithGen extends LogicStructure {
  Logic get b;
  set b(Logic b);
  Logic get a;
  set a(Logic a);

  _$ExampleStructWithGen({super.name = 'ExampleStructWithGen'})
      : super(
          [
            Logic(name: 'b', naming: Naming.mergeable),
            Logic(name: 'a', naming: Naming.mergeable)
          ],
        ) {
    b = elements[0];
    a = elements[1];
  }

  @override
// This clone method does not create the matching type.
  @mustBeOverridden
  LogicStructure clone({String? name}) => super.clone(name: name);
}

abstract class _$KitchenSinkStruct extends LogicStructure {
  ExampleStructWithGen get struct;
  set struct(ExampleStructWithGen struct);
  LogicArray get array;
  set array(LogicArray array);
  Logic get basic;
  set basic(Logic basic);

  _$KitchenSinkStruct({super.name = 'KitchenSinkStruct'})
      : super(
          [
            struct(),
            LogicArray(
                name: 'array',
                elementWidth: arrayElementWidth,
                dimensions: arrayDimensions,
                numUnpackedDimensions: arrayNumUnpackedDimensions,
                naming: Naming.mergeable),
            Logic(name: 'basic', naming: Naming.mergeable)
          ],
        ) {
    struct = elements[0];
    array = elements[1];
    basic = elements[2];
  }

  @override
// This clone method does not create the matching type.
  @mustBeOverridden
  LogicStructure clone({String? name}) => super.clone(name: name);
}
