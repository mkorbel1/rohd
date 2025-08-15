// ignore_for_file: type_init_formals
//TODO: review file ignores

import 'dart:io';

import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:test/test.dart';

part 'gen_module_test.g.dart';

class NoArgStruct extends LogicStructure {
  NoArgStruct() : super([Logic(name: 'a')]);

  NoArgStruct._({super.name}) : super([Logic(name: 'a')]);

  @override
  NoArgStruct clone({String? name}) => NoArgStruct._(name: name);
}

class NamedNameableStruct extends LogicStructure {
  NamedNameableStruct(String name) : super([Logic(name: 'a')], name: name);

  @override
  NamedNameableStruct clone({String? name}) =>
      NamedNameableStruct(name ?? this.name);
}

class PosNameableStruct extends LogicStructure {
  PosNameableStruct({super.name}) : super([Logic(name: 'a')]);

  @override
  PosNameableStruct clone({String? name}) =>
      PosNameableStruct(name: name ?? this.name);
}

class OptPosNameableStruct extends LogicStructure {
  OptPosNameableStruct([String? name]) : super([Logic(name: 'a')], name: name);

  @override
  OptPosNameableStruct clone({String? name}) =>
      OptPosNameableStruct(name ?? this.name);
}

class OptionalNonNameArgsStruct extends LogicStructure {
  OptionalNonNameArgsStruct({super.name, int aWidth = 5})
      : super([Logic(name: 'a', width: aWidth)]);

  @override
  OptionalNonNameArgsStruct clone({String? name}) => OptionalNonNameArgsStruct(
      name: name ?? this.name, aWidth: elements.first.width);
}

class RequiredNonNameArgsStruct extends LogicStructure {
  RequiredNonNameArgsStruct({super.name, required int aWidth})
      : super([Logic(name: 'a', width: aWidth)]);

  @override
  RequiredNonNameArgsStruct clone({String? name}) => RequiredNonNameArgsStruct(
      name: name ?? this.name, aWidth: elements.first.width);
}

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

  @Input(name: 'top_in_new_name')
  late final Logic topInNewName;

  @Input(width: 8)
  late final Logic topIn8bit;

  @Input(description: 'top in desc')
  late final Logic topInDesc;

  @Input()
  late final Logic? topInCond;

  @Input.array()
  late final LogicArray topInArray;

  @Input.array(
      name: 'top_in_array_specd',
      elementWidth: 4,
      dimensions: [7, 6],
      numUnpackedDimensions: 1,
      description: '''
top in array specified
in multiple lines

with a blank line later too
''')
  late final LogicArray topInArraySpecd;

  @Input.array()
  late final LogicArray? topInArrayCond;

  @Input.typed()
  late final NoArgStruct noArgStruct;

  @Input.typed()
  late final NamedNameableStruct namedNameableStruct;

  @Input.typed()
  late final PosNameableStruct posNameableStruct;

  @Input.typed()
  late final OptPosNameableStruct optPosNameableStruct;

  @Input.typed()
  late final OptionalNonNameArgsStruct optionalNonNameArgsStruct;

  @Input.typed()
  late final RequiredNonNameArgsStruct requiredNonNameArgsStruct;

  @Input.typed(name: 'specd_struct', description: 'specd struct desc')
  late final NamedNameableStruct namedNameableStructSpecd;

  @Input.typed()
  late final Logic topTypedLogicIn;

  @Input.typed()
  late final LogicArray topTypedLogicArrayIn;

  @Output()
  late final Logic topOut;

  @Output(name: 'top_out_new_name')
  late final Logic topOutNewName;

  @Output(width: 8)
  late final Logic topOutWider;

  @Output(description: 'top out desc')
  late final Logic topOutDesc;

  @Output()
  late final Logic? topOutCond;

  @Output.array(dimensions: [2, 3], elementWidth: 4, numUnpackedDimensions: 1)
  late final LogicArray topOutArray;

  @Output.array()
  late final LogicArray topOutArrayUnspecified;

  //TODO: array with unspecified args needs args passed into super constructor or match?

  @InOut()
  late final Logic topInOut;

  //TODO: structs
  //TODO: enums

  KitchenGenSinkModule(
    @Input() super.botInPos,
    @Input(width: 7) super.botInPosWidthed,
    @Input() Logic? super.botInPosNullable, {
    @Input() required super.botInNamed,
    @Input() Logic? super.botInNamedOptional,
    super.topInCondIsPresent = true,
    super.topInArrayCondIsPresent = true,
    super.topOutCondIsPresent = true,
    super.topInWidth,
    super.topInArrayElementWidth,
    super.topInArrayDimensions,
    super.topInArrayNumUnpackedDimensions,
    super.name,
    super.reserveName,
    super.reserveDefinitionName,
    super.definitionName,
    super.botInPosWidth,
    super.namedNameableStructSource,
    super.topOutWidth,
    super.topOutArrayUnspecifiedElementWidth,
    super.topOutArrayUnspecifiedDimensions,
    super.topOutArrayUnspecifiedNumUnpackedDimensions,
  }) : super(
          requiredNonNameArgsStructSource: RequiredNonNameArgsStruct(
              aWidth: 9, name: 'specified_super_name'),
          topTypedLogicInWidth: 4,
          topTypedLogicArrayInElementWidth: 5,
        );

  //TODO: also need to test positional optional inputs
}

//TODO: test with Logic instead of super

//TODO: what happens with multiple constructors?

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
    final dut = KitchenGenSinkModule(
      Logic(width: 5),
      Logic(width: 7),
      Logic(),
      botInNamed: Logic(),
      botInNamedOptional: Logic(),
    );

    final dutAdjusted = KitchenGenSinkModule(
      Logic(width: 12),
      botInPosWidth: 12,
      Logic(width: 7),
      Logic(),
      botInNamed: Logic(),
      botInNamedOptional: Logic(),
      topInCondIsPresent: false,
      topOutCondIsPresent: false,
      topInArrayCondIsPresent: false,
      topInWidth: 16,
      topInArrayElementWidth: 4,
      topInArrayDimensions: const [5, 6],
      topInArrayNumUnpackedDimensions: 1,
      name: 'adjusted',
      reserveName: true,
      definitionName: 'adjusted_definition',
      reserveDefinitionName: true,
      namedNameableStructSource: NamedNameableStruct('adjusted_named_named'),
      topOutWidth: 7,
      topOutArrayUnspecifiedElementWidth: 18,
      topOutArrayUnspecifiedDimensions: [7, 8, 9],
      topOutArrayUnspecifiedNumUnpackedDimensions: 2,
    );

    await dut.build();

    final genFileContents =
        File('test/generator/gen_module_test.g.dart').readAsStringSync();

    expect(dutAdjusted.name, 'adjusted');
    expect(dutAdjusted.reserveName, isTrue);
    expect(dutAdjusted.definitionName, 'adjusted_definition');
    expect(dutAdjusted.reserveDefinitionName, isTrue);

    expect(dut.topIn.isInput, isTrue);
    expect(dut.topIn.name, 'topIn');
    expect(dut.topIn.width, 1);
    expect(dut.topIn.srcConnection, dut.topInSource);

    expect(dutAdjusted.topIn.width, 16);

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

    expect(dutAdjusted.topInCond, isNull);
    expect(dutAdjusted.topInCondSource, isNull);

    expect(dut.topInArray.isInput, isTrue);
    expect(dut.topInArray.name, 'topInArray');
    expect(dut.topInArray.width, 1);
    expect(dut.topInArray.elementWidth, 1);
    expect(dut.topInArray.dimensions, const [1]);
    expect(dut.topInArray.numUnpackedDimensions, 0);
    expect(dut.topInArray.srcConnections.first,
        dut.topInArraySource.elements.first);

    expect(dutAdjusted.topInArray.elementWidth, 4);
    expect(dutAdjusted.topInArray.dimensions, const [5, 6]);
    expect(dutAdjusted.topInArray.numUnpackedDimensions, 1);

    expect(dut.topInArraySpecd.isInput, isTrue);
    expect(dut.topInArraySpecd.name, 'top_in_array_specd');
    expect(dut.topInArraySpecd.elementWidth, 4);
    expect(dut.topInArraySpecd.dimensions, const [7, 6]);
    expect(dut.topInArraySpecd.numUnpackedDimensions, 1);
    expect(dut.topInArraySpecd.srcConnections.first,
        dut.topInArraySpecdSource.leafElements.first);
    expect(genFileContents, contains('/// top in array specified'));
    expect(genFileContents, contains('/// in multiple lines'));
    expect(genFileContents, contains('/// with a blank line later too'));

    expect(dut.topInArrayCond, isNotNull);
    expect(dut.topInArrayCondSource, isNotNull);
    expect(dut.topInArrayCond!.isInput, isTrue);
    expect(dut.topInArrayCond!.srcConnections.first,
        dut.topInArrayCondSource!.leafElements.first);

    expect(dutAdjusted.topInArrayCond, isNull);
    expect(dutAdjusted.topInArrayCondSource, isNull);

    expect(dut.noArgStruct.isInput, isTrue);
    expect(dut.noArgStruct, isA<NoArgStruct>());
    expect(dut.noArgStruct.elements.first.srcConnection,
        dut.noArgStructSource.elements.first);

    expect(dut.namedNameableStruct.isInput, isTrue);
    expect(dut.namedNameableStruct, isA<NamedNameableStruct>());
    expect(dut.namedNameableStruct.elements.first.srcConnection,
        dut.namedNameableStructSource.elements.first);
    expect(dut.namedNameableStruct.name, 'namedNameableStruct');
    expect(dut.namedNameableStructSource.name, 'namedNameableStruct');

    expect(dut.posNameableStruct.isInput, isTrue);
    expect(dut.posNameableStruct, isA<PosNameableStruct>());
    expect(dut.posNameableStruct.elements.first.srcConnection,
        dut.posNameableStructSource.elements.first);
    expect(dut.posNameableStruct.name, 'posNameableStruct');
    expect(dut.posNameableStructSource.name, 'posNameableStruct');

    expect(dut.optPosNameableStruct.isInput, isTrue);
    expect(dut.optPosNameableStruct, isA<OptPosNameableStruct>());
    expect(dut.optPosNameableStruct.elements.first.srcConnection,
        dut.optPosNameableStructSource.elements.first);
    expect(dut.optPosNameableStruct.name, 'optPosNameableStruct');
    expect(dut.optPosNameableStructSource.name, 'optPosNameableStruct');

    expect(dut.optionalNonNameArgsStruct.isInput, isTrue);
    expect(dut.optionalNonNameArgsStruct, isA<OptionalNonNameArgsStruct>());
    expect(dut.optionalNonNameArgsStruct.elements.first.srcConnection,
        dut.optionalNonNameArgsStructSource.elements.first);
    expect(dut.optionalNonNameArgsStruct.name, 'optionalNonNameArgsStruct');
    expect(
        dut.optionalNonNameArgsStructSource.name, 'optionalNonNameArgsStruct');

    expect(dut.requiredNonNameArgsStruct.isInput, isTrue);
    expect(dut.requiredNonNameArgsStruct.width, 9);
    expect(dut.requiredNonNameArgsStruct, isA<RequiredNonNameArgsStruct>());
    expect(dut.requiredNonNameArgsStruct.name, 'requiredNonNameArgsStruct');
    expect(dut.requiredNonNameArgsStructSource.name, 'specified_super_name');

    expect(dut.namedNameableStructSpecd.name, 'specd_struct');
    expect(dut.namedNameableStructSpecdSource.name, 'specd_struct');
    expect(genFileContents, contains('/// specd struct desc'));

    expect(dutAdjusted.namedNameableStructSource.name, 'adjusted_named_named');

    expect(dut.topTypedLogicIn.isInput, isTrue);
    expect(dut.topTypedLogicIn.width, 4);
    expect(dut.topTypedLogicIn, isA<Logic>());

    expect(dut.topTypedLogicArrayIn.isInput, isTrue);
    expect(dut.topTypedLogicArrayIn.elementWidth, 5);
    expect(dut.topTypedLogicArrayIn, isA<LogicArray>());

    expect(dut.topOut.isOutput, isTrue);
    expect(dut.topOut.name, 'topOut');
    expect(dut.topOut.width, 1);

    expect(dutAdjusted.topOut.width, 7);

    expect(dut.topOutNewName.isOutput, isTrue);
    expect(dut.topOutNewName.name, 'top_out_new_name');

    expect(dut.topOutWider.isOutput, isTrue);
    expect(dut.topOutWider.width, 8);

    expect(dut.topOutDesc.isOutput, isTrue);
    expect(genFileContents, contains('/// top out desc'));

    expect(dut.topOutCond!.isOutput, isTrue);
    expect(dutAdjusted.topOutCond, isNull);

    expect(dut.topOutArray.isOutput, isTrue);
    expect(dut.topOutArray.dimensions, [2, 3]);
    expect(dut.topOutArray.elementWidth, 4);
    expect(dut.topOutArray.numUnpackedDimensions, 1);

    expect(dut.topOutArrayUnspecified.isOutput, isTrue);
    expect(dut.topOutArrayUnspecified.dimensions, [1]);
    expect(dut.topOutArrayUnspecified.elementWidth, 1);
    expect(dut.topOutArrayUnspecified.numUnpackedDimensions, 0);

    expect(dutAdjusted.topOutArrayUnspecified.isOutput, isTrue);
    expect(dutAdjusted.topOutArrayUnspecified.dimensions, [7, 8, 9]);
    expect(dutAdjusted.topOutArrayUnspecified.elementWidth, 18);
    expect(dutAdjusted.topOutArrayUnspecified.numUnpackedDimensions, 2);

    expect(dut.botInPos.isInput, isTrue);
    expect(dut.botInPos.width, 5);

    expect(dutAdjusted.botInPos.width, 12);

    expect(dut.botInPosWidthed.isInput, isTrue);
    expect(dut.botInPosWidthed.width, 7);
  });
}
