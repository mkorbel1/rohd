import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/interfaces/interfaces.dart';
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

@GenInterface({
  ExampleDir.dir1: [GenLogic('a')],
  ExampleDir.dir2: [GenLogic('b')],
})
class ExampleIntfWithGen extends _$ExampleIntfWithGen {}

@GenInterface({
  PairDirection.fromProvider: [GenLogic('fp')],
  PairDirection.fromConsumer: [GenLogic('fc')],
}, baseConstructor: PairInterface.new)
class GenPairIntf extends _$GenPairIntf {
  GenPairIntf() : super(sharedInputPorts: [Logic.port('si')]);
}

@GenInterface({
  ExampleDir.dir1: [GenLogic.struct('a', type: MyFancyStruct)],
})
class GenIntfWithFancyStruct extends _$GenIntfWithFancyStruct {
  GenIntfWithFancyStruct() : super(a: MyFancyStruct(busWidth: 8));
}

class MyStructWithName extends LogicStructure {
  final Logic ready;
  final Logic valid;

  factory MyStructWithName({String? name = 'my_struct'}) => MyStructWithName._(
        Logic(name: 'ready'),
        Logic(name: 'valid'),
        name: name,
      );

  MyStructWithName._(this.ready, this.valid, {super.name})
      : super([ready, valid]);

  @override
  MyStructWithName clone({String? name}) => MyStructWithName(name: name);
}

@GenInterface({
  ExampleDir.dir1: [GenLogic.struct('a', type: MyStruct)],
  ExampleDir.dir2: [GenLogic.struct('b', type: MyStructWithName)],
})
class GenIntfWithSimpleStruct extends _$GenIntfWithSimpleStruct {
  GenIntfWithSimpleStruct() : super();
}

void main() {
  group('simple interface', () {
    for (final intfBuilder in [ExampleIntf.new, ExampleIntfWithGen.new]) {
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

  test('interface with struct', () {
    final intf = GenIntfWithFancyStruct();

    expect(intf.a, isA<MyFancyStruct>());
  });
}
