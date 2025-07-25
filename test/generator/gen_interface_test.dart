import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';

import 'package:test/test.dart';

import '../logic_structure_test.dart';

part 'gen_interface_test.g.dart';

enum ExampleDir {
  dir1,
  dir2;
}

class ExampleIntf extends Interface<ExampleDir> {
  Logic get a => port('a');
  Logic get b => port('b');

  ExampleIntf() {
    setPorts([Logic.port('a')], [ExampleDir.dir1]);
    setPorts([Logic.port('b')], [ExampleDir.dir2]);
  }
}

@GenInterface()
class ExampleIntfWithGen extends _$ExampleIntfWithGen {
  @IntfPort(ExampleDir.dir1)
  late final Logic a;

  @IntfPort(ExampleDir.dir2)
  late final Logic b;
}

@GenInterface(baseConstructor: PairInterface.new)
class GenPairIntf extends _$GenPairIntf {
  @IntfPort(PairDirection.fromProvider)
  late final Logic fp;

  @IntfPort(PairDirection.fromConsumer)
  late final Logic fc;

  GenPairIntf() : super(sharedInputPorts: [Logic.port('si')]);
}

@GenInterface()
class GenIntfWithFancyStruct extends _$GenIntfWithFancyStruct {
  @IntfPort(ExampleDir.dir1)
  late final MyFancyStruct a;

  GenIntfWithFancyStruct() : super(a: MyFancyStruct(busWidth: 8));
}

class MyStructWithNamedName extends LogicStructure {
  final Logic ready;
  final Logic valid;

  factory MyStructWithNamedName({String? name = 'my_struct'}) =>
      MyStructWithNamedName._(
        Logic(name: 'ready'),
        Logic(name: 'valid'),
        name: name,
      );

  MyStructWithNamedName._(this.ready, this.valid, {super.name})
      : super([ready, valid]);

  @override
  MyStructWithNamedName clone({String? name}) =>
      MyStructWithNamedName(name: name);
}

class MyStructWithPosName extends LogicStructure {
  final Logic ready;
  final Logic valid;

  factory MyStructWithPosName(String name) => MyStructWithPosName._(
        Logic(name: 'ready'),
        Logic(name: 'valid'),
        name: name,
      );

  MyStructWithPosName._(this.ready, this.valid, {super.name})
      : super([ready, valid]);

  @override
  MyStructWithNamedName clone({String? name}) =>
      MyStructWithNamedName(name: name);
}

@GenInterface<ExampleDir>()
class GenIntfWithSimpleStruct extends _$GenIntfWithSimpleStruct {
  @IntfPort(ExampleDir.dir1)
  late final MyStruct a;

  @IntfPort(ExampleDir.dir2)
  late final MyStructWithNamedName b;

  @IntfPort(ExampleDir.dir2)
  late final MyStructWithPosName c;

  GenIntfWithSimpleStruct() : super();

  GenIntfWithSimpleStruct.explicit()
      : super(
          a: MyStruct(),
          b: MyStructWithNamedName(name: 'b'),
          c: MyStructWithPosName('c'),
        );
}

class MyStructWithRequiredArgs extends LogicStructure {
  final Logic ready;
  final Logic valid;

  factory MyStructWithRequiredArgs(
    int posRequired, {
    required bool namedRequired,
    String? name = 'reqargs',
  }) =>
      MyStructWithRequiredArgs._(
        Logic(name: 'ready$posRequired'),
        Logic(name: 'valid$namedRequired'),
        name: name,
      );

  MyStructWithRequiredArgs._(this.ready, this.valid, {super.name})
      : super([ready, valid]);

  @override
  MyStructWithNamedName clone({String? name}) =>
      MyStructWithNamedName(name: name);
}

@GenInterface()
class GenIntfWithUnusableStructConstructor
    extends _$GenIntfWithUnusableStructConstructor {
  @IntfPort(ExampleDir.dir1)
  late final MyStructWithRequiredArgs reqarg;

  GenIntfWithUnusableStructConstructor()
      : super(reqarg: MyStructWithRequiredArgs(3, namedRequired: true));
}

void main() {
  group('simple interface', () {
    for (final intfBuilder in <Interface Function()>[
      ExampleIntf.new,
      ExampleIntfWithGen.new
    ]) {
      group(intfBuilder.toString(), () {
        test('constructs, ports available', () {
          final intf = intfBuilder();

          expect(intf.port('a').width, 1);
          expect(intf.port('b').width, 1);
        });
      });
    }
  });

  test('pair intf', () {
    final intf = GenPairIntf();

    expect(intf, isA<PairInterface>());
    expect(intf.fp.width, 1);
    expect(intf.fc.width, 1);
    expect(intf.port('si').width, 1);
  });

  test('interface with fancy struct', () {
    final intf = GenIntfWithFancyStruct();

    expect(intf.a, isA<MyFancyStruct>());
  });

  test('interface with simple struct and constructors', () {
    final basicIntf = GenIntfWithSimpleStruct();
    final explicitIntf = GenIntfWithSimpleStruct.explicit();

    expect(GenIntfWithSimpleStruct(), isA<Interface<ExampleDir>>());

    for (final intf in [basicIntf, explicitIntf]) {
      expect(intf.a, isA<MyStruct>());
      expect(intf.b, isA<MyStructWithNamedName>());
      expect(intf.c, isA<MyStructWithPosName>());

      expect(intf.a.ready.name, 'ready');
      expect(intf.b.valid.name, 'valid');
      expect(intf.c.ready.name, 'ready');

      expect(intf.a.name, 'myStruct');
      expect(intf.b.name, 'b');
      expect(intf.c.name, 'c');
    }
  });

  test('interface with struct with required args', () {
    final intf = GenIntfWithUnusableStructConstructor();

    expect(intf.reqarg, isA<MyStructWithRequiredArgs>());
    expect(intf.reqarg.ready.name, 'ready3');
    expect(intf.reqarg.valid.name, 'validtrue');
  });
}
