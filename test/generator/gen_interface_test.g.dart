// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gen_interface_test.dart';

// **************************************************************************
// InterfaceGenerator
// **************************************************************************

abstract class _$ExampleIntfWithGen extends Interface<Enum> {
  Logic get a;
  @visibleForOverriding
  set a(Logic a);
  Logic get b;
  @visibleForOverriding
  set b(Logic b);
  _$ExampleIntfWithGen({
    int aWidth = 1,
    int bWidth = 1,
  }) : super() {
    this.a = setPort(Logic(name: 'a', width: aWidth),
        tags: const [ExampleDir.dir1], name: 'a');
    this.b = setPort(Logic(name: 'b', width: bWidth),
        tags: const [ExampleDir.dir2], name: 'b');
  }
}

abstract class _$GenPairIntf extends PairInterface {
  Logic get fp;
  @visibleForOverriding
  set fp(Logic fp);
  Logic get fc;
  @visibleForOverriding
  set fc(Logic fc);
  _$GenPairIntf({
    super.commonInOutPorts,
    super.modify,
    super.portsFromConsumer,
    super.portsFromProvider,
    super.sharedInputPorts,
    int fpWidth = 1,
    int fcWidth = 1,
  }) : super.new() {
    this.fp = setPort(Logic(name: 'fp', width: fpWidth),
        tags: const [PairDirection.fromProvider], name: 'fp');
    this.fc = setPort(Logic(name: 'fc', width: fcWidth),
        tags: const [PairDirection.fromConsumer], name: 'fc');
  }
}

abstract class _$GenIntfWithFancyStruct extends Interface<Enum> {
  MyFancyStruct get a;
  @visibleForOverriding
  set a(MyFancyStruct a);
  _$GenIntfWithFancyStruct({
    MyFancyStruct? a,
  }) : super() {
    this.a = setPort(a ?? MyFancyStruct(name: 'a'),
        tags: const [ExampleDir.dir1], name: 'a');
  }
}

abstract class _$GenIntfWithSimpleStruct extends Interface<ExampleDir> {
  MyUnrenameableStruct get a;
  @visibleForOverriding
  set a(MyUnrenameableStruct a);
  MyStructWithNamedName get b;
  @visibleForOverriding
  set b(MyStructWithNamedName b);
  MyStructWithPosName get c;
  @visibleForOverriding
  set c(MyStructWithPosName c);
  _$GenIntfWithSimpleStruct({
    MyUnrenameableStruct? a,
    MyStructWithNamedName? b,
    MyStructWithPosName? c,
  }) : super() {
    this.a = setPort(a ?? MyUnrenameableStruct(),
        tags: const [ExampleDir.dir1], name: 'a');
    this.b = setPort(b ?? MyStructWithNamedName(name: 'b'),
        tags: const [ExampleDir.dir2], name: 'b');
    this.c = setPort(c ?? MyStructWithPosName('c'),
        tags: const [ExampleDir.dir2], name: 'c');
  }
}

abstract class _$GenIntfWithUnusableStructConstructor extends Interface<Enum> {
  MyStructWithRequiredArgs get reqarg;
  @visibleForOverriding
  set reqarg(MyStructWithRequiredArgs reqarg);
  _$GenIntfWithUnusableStructConstructor({
    required MyStructWithRequiredArgs reqarg,
  }) : super() {
    this.reqarg =
        setPort(reqarg, tags: const [ExampleDir.dir1], name: 'reqarg');
  }
}
