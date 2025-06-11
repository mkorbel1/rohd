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
    setPorts([Logic.port('fp', 1)], [PairDirection.fromProvider]);
    setPorts([Logic.port('fc', 1)], [PairDirection.fromConsumer]);
  }
}
