// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_interface_test.dart';

// **************************************************************************
// InterfaceGenerator
// **************************************************************************

class _$ExampleIntfWithGen extends Interface<ExampleDir> {
  Logic get a => port('a') as Logic;
  Logic get b => port('b') as Logic;
  _$ExampleIntfWithGen() : super() {
    setPort(Logic(name: 'a', width: 1),
        tags: const [ExampleDir.dir1], name: 'a');
    setPort(Logic(name: 'b', width: 1),
        tags: const [ExampleDir.dir2], name: 'b');
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
    setPort(Logic(name: 'fp', width: 1),
        tags: const [PairDirection.fromProvider], name: 'fp');
    setPort(Logic(name: 'fc', width: 1),
        tags: const [PairDirection.fromConsumer], name: 'fc');
  }
}

class _$GenIntfWithFancyStruct extends Interface<ExampleDir> {
  MyFancyStruct get a => port('a') as MyFancyStruct;
  _$GenIntfWithFancyStruct({
    MyFancyStruct? a,
  }) : super() {
    setPort(a ?? MyFancyStruct(), tags: const [ExampleDir.dir1], name: 'a');
  }
}

class _$GenIntfWithSimpleStruct extends Interface<ExampleDir> {
  MyStruct get a => port('a') as MyStruct;
  MyStructWithNamedName get b => port('b') as MyStructWithNamedName;
  MyStructWithPosName get c => port('c') as MyStructWithPosName;
  _$GenIntfWithSimpleStruct({
    MyStruct? a,
    MyStructWithNamedName? b,
    MyStructWithPosName? c,
  }) : super() {
    setPort(a ?? MyStruct(), tags: const [ExampleDir.dir1], name: 'a');
    setPort(b ?? MyStructWithNamedName(name: b),
        tags: const [ExampleDir.dir2], name: 'b');
    setPort(c ?? MyStructWithPosName(c),
        tags: const [ExampleDir.dir2], name: 'c');
  }
}

class _$GenIntfWithUnusableStructConstructor extends Interface<ExampleDir> {
  MyStructWithRequiredArgs get reqarg =>
      port('reqarg') as MyStructWithRequiredArgs;
  _$GenIntfWithUnusableStructConstructor({
    required MyStructWithRequiredArgs reqarg,
  }) : super() {
    setPort(reqarg, tags: const [ExampleDir.dir1], name: 'reqarg');
  }
}
