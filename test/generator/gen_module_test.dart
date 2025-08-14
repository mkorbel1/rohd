// ignore_for_file: type_init_formals
//TODO: review file ignores

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:test/test.dart';

part 'gen_module_test.g.dart';

class ExampleModule extends Module {
  Logic get b => output('b');
  ExampleModule(Logic a) {
    a = addInput('a', a);
    addOutput('b');
    b <= ~a;
  }
}

@GenModule()
class ExampleModuleWithGen extends _$ExampleModuleWithGen {
  @Output()
  late final Logic b;

  ExampleModuleWithGen(@Input() super.a) {
    b <= ~a;
  }
}

@GenModule()
class NonSuperInputMod extends _$NonSuperInputMod {
  // input is not calling super, but passes it up to the parent class
  NonSuperInputMod(@Input() Logic a) : super(a);
}

class GenBaseMod extends Module {
  final bool myFlag;
  GenBaseMod({required this.myFlag});
}

@GenModule(baseConstructor: GenBaseMod.new)
class GenSubMod extends _$GenSubMod {
  @override
  @Output()
  late final Logic b;

  GenSubMod(@Input() super.a, {required super.myFlag}) {
    b <= ~a;
  }
}

@GenModule()
class KitchenGenSinkModule extends _$KitchenGenSinkModule {
  @Input()
  late final Logic topIn;

  @Input(logicName: 'top_in_new_name')
  late final Logic topInNewName;

  @Input(width: 8)
  late final Logic topIn8bit;

  @Input(description: 'top in desc')
  late final Logic topInDesc;

  @Input()
  late final Logic? topInCond;

  @Output()
  late final Logic topOut;

  @Output(logicName: 'top_out_new_name')
  late final Logic topOutNewName;

  @Output(width: 8)
  late final Logic topOutWider;

  @Output(description: 'top out desc')
  late final Logic topOutDesc;

  @Output()
  late final Logic? topOutCond;

  @Output()
  late final Logic topOutDynWidth;

  @Output.array(dimensions: [2, 3], elementWidth: 4, numUnpackedDimensions: 1)
  late final LogicArray topOutArray;

  @Output()
  late final LogicArray topOutArrayUnspecDims;

  @Output.array()
  late final LogicArray topOutArrayUnspecified;

  //TODO: array with unspecified args needs args passed into super constructor or match?

  @InOut()
  late final Logic topInOut;

  //TODO: structs
  //TODO: enums

  KitchenGenSinkModule(
    @Input() super.botInPos,
    @Input() Logic? super.botInPosNullable, {
    @Input() required super.botInNamed,
    @Input() Logic? super.botInNamedOptional,
    super.topInCondIsPresent = true,
    super.topOutCondIsPresent = true,
  });

  //TODO: also need to test positional optional inputs
}

//TODO: test with Logic instead of super

void main() {
  group('simple module', () {
    for (final modBuilder in [ExampleModule.new, ExampleModuleWithGen.new]) {
      group(modBuilder.toString(), () {
        test('builds, simple test, and generates code', () async {
          final a = Logic();
          final mod = modBuilder(a);
          await mod.build();
          a.put(0);
          expect(mod.output('b').value.toBool(), true);

          final svCode = mod.generateSynth();

          expect(svCode, contains('input logic a'));
          expect(svCode, contains('output logic b'));
          expect(svCode, contains('b = ~a;'));
          expect(svCode, contains('module ExampleModule'));
        });
      });
    }
  });

  test('non-super input arg still generates input', () async {
    final mod = NonSuperInputMod(Logic());
    await mod.build();

    expect(mod.a.isInput, isTrue);
  });

  test('kitchen sink gen module', () async {
    final dut = KitchenGenSinkModule(Logic(), Logic(),
        botInNamed: Logic(), botInNamedOptional: Logic());

    final dutNoConds = KitchenGenSinkModule(
      Logic(),
      Logic(),
      botInNamed: Logic(),
      botInNamedOptional: Logic(),
      topInCondIsPresent: false,
      topOutCondIsPresent: false,
    );

    await dut.build();

    final genFileContents =
        File('test/generator/gen_module_test.g.dart').readAsStringSync();

    expect(dut.topIn.isInput, isTrue);
    expect(dut.topIn.name, 'topIn');
    expect(dut.topIn.width, 1);
    expect(dut.topIn.srcConnection, dut.topInSource);

    expect(dut.topInNewName.isInput, isTrue);
    expect(dut.topInNewName.name, 'top_in_new_name');
    expect(dut.topInNewName.width, 1);
    expect(dut.topInNewName.srcConnection, dut.topInNewNameSource);

    expect(dut.topIn8bit.isInput, isTrue);
    expect(dut.topIn8bit.name, 'topIn8bit');
    expect(dut.topIn8bit.width, 8);
    expect(dut.topIn8bit.srcConnection, dut.topIn8bitSource);

    expect(dut.topInDesc.isInput, isTrue);
    expect(dut.topInDesc.name, 'topInDesc');
    expect(dut.topInDesc.width, 1);
    expect(dut.topInDesc.srcConnection, dut.topInDescSource);
    expect(genFileContents, contains('/// top in desc'));

    expect(dut.topInCond!.isInput, isTrue);
    expect(dut.topInCond!.name, 'topInCond');
    expect(dut.topInCond!.width, 1);
    expect(dut.topInCond!.srcConnection, dut.topInCondSource);

    expect(dutNoConds.topInCond, isNull);
    expect(dutNoConds.topInCondSource, isNull);

    expect(dut.topOut.isOutput, isTrue);
    expect(dut.topOut.name, 'topOut');
    expect(dut.topOut.width, 1);
    // expect(genFileContents, contains('/// This is the top output'));
  });
}
