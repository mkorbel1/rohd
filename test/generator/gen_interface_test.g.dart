// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_setters_without_getters, unused_element_parameter, unnecessary_this, lines_longer_than_80_chars

part of 'gen_interface_test.dart';

// **************************************************************************
// InterfaceGenerator
// **************************************************************************

abstract class _$ExampleIntfWithGen extends Interface<Enum> {
  @visibleForOverriding
  set a(Logic a);
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
  @visibleForOverriding
  set fp(Logic fp);
  @visibleForOverriding
  set fc(Logic fc);
  _$GenPairIntf({
    super.commonInOutPorts,
    int fcWidth = 1,
    int fpWidth = 1,
    super.modify,
    super.portsFromConsumer,
    super.portsFromProvider,
    super.sharedInputPorts,
  }) : super.new() {
    this.fp = setPort(Logic(name: 'fp', width: fpWidth),
        tags: const [PairDirection.fromProvider], name: 'fp');
    this.fc = setPort(Logic(name: 'fc', width: fcWidth),
        tags: const [PairDirection.fromConsumer], name: 'fc');
  }
}

abstract class _$GenIntfWithFancyStruct extends Interface<Enum> {
  @visibleForOverriding
  set a(MyFancyStruct a);
  _$GenIntfWithFancyStruct({
    int aWidth = 1,
  }) : super() {
    this.a = setPort(Logic(name: 'a', width: aWidth),
        tags: const [ExampleDir.dir1], name: 'a');
  }
}

abstract class _$GenIntfWithSimpleStruct extends Interface<ExampleDir> {
  @visibleForOverriding
  set a(MyUnrenameableStruct a);
  @visibleForOverriding
  set b(MyStructWithNamedName b);
  @visibleForOverriding
  set c(MyStructWithPosName c);
  _$GenIntfWithSimpleStruct({
    int aWidth = 1,
    int bWidth = 1,
    int cWidth = 1,
  }) : super() {
    this.a = setPort(Logic(name: 'a', width: aWidth),
        tags: const [ExampleDir.dir1], name: 'a');
    this.b = setPort(Logic(name: 'b', width: bWidth),
        tags: const [ExampleDir.dir2], name: 'b');
    this.c = setPort(Logic(name: 'c', width: cWidth),
        tags: const [ExampleDir.dir2], name: 'c');
  }
}

abstract class _$GenIntfWithUnusableStructConstructor extends Interface<Enum> {
  @visibleForOverriding
  set reqarg(MyStructWithRequiredArgs reqarg);
  _$GenIntfWithUnusableStructConstructor({
    int reqargWidth = 1,
  }) : super() {
    this.reqarg = setPort(Logic(name: 'reqarg', width: reqargWidth),
        tags: const [ExampleDir.dir1], name: 'reqarg');
  }
}
