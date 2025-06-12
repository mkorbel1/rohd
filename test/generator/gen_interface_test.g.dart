// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_interface_test.dart';

// **************************************************************************
// InterfaceGenerator
// **************************************************************************

class _$ExampleIntfWithGen extends Interface<ExampleDir> {
  Logic get a => port('a') as Logic;
  Logic get b => port('b') as Logic;
  _$ExampleIntfWithGen() : super() {
    setPort(Logic.port('a', 1), tags: const [ExampleDir.dir1], portName: 'a');
    setPort(Logic.port('b', 1), tags: const [ExampleDir.dir2], portName: 'b');
  }
}

class _$GenPairIntf extends PairInterface {
  Logic get fp => port('fp') as Logic;
  Logic get fc => port('fc') as Logic;
  _$GenPairIntf({
    super.commonInOutPorts,
    super.modify,
    super.portsFromConsumer,
    super.portsFromProvider,
    super.sharedInputPorts,
  }) : super.new() {
    setPort(Logic.port('fp', 1),
        tags: const [PairDirection.fromProvider], portName: 'fp');
    setPort(Logic.port('fc', 1),
        tags: const [PairDirection.fromConsumer], portName: 'fc');
  }
}

class _$GenIntfWithFancyStruct extends Interface<ExampleDir> {
  MyFancyStruct get a => port('a') as MyFancyStruct;
  _$GenIntfWithFancyStruct({
    required MyFancyStruct a,
  }) : super() {
    setPort(a, tags: const [ExampleDir.dir1], portName: 'a');
  }
}

class _$GenIntfWithSimpleStruct extends Interface<ExampleDir> {
  MyStruct get a => port('a') as MyStruct;
  _$GenIntfWithSimpleStruct({
    required MyStruct a,
  }) : super() {
    setPort(a, tags: const [ExampleDir.dir1], portName: 'a');
  }
}

class _$GenIntfWithNamedSimpleStruct extends Interface<ExampleDir> {
  MyStructWithName get a => port('a') as MyStructWithName;
  _$GenIntfWithNamedSimpleStruct({
    required MyStructWithName a,
  }) : super() {
    setPort(a, tags: const [ExampleDir.dir1], portName: 'a');
  }
}
