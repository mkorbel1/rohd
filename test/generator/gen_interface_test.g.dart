// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_interface_test.dart';

// **************************************************************************
// InterfaceGenerator
// **************************************************************************

class _$ExampleIntfWithGen extends Interface<ExampleDir> {
  Logic get a => port('a') as Logic;
  Logic get b => port('b') as Logic;
  _$ExampleIntfWithGen() : super() {
    setPorts([Logic.port('a', 1)], [ExampleDir.dir1]);
    setPorts([Logic.port('b', 1)], [ExampleDir.dir2]);
  }
}
