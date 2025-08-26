// ignore_for_file: type_init_formals, always_put_required_named_parameters_first
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
  RequiredNonNameArgsStruct({required int aWidth, super.name})
      : super([Logic(name: 'a', width: aWidth)]);

  @override
  RequiredNonNameArgsStruct clone({String? name}) => RequiredNonNameArgsStruct(
      name: name ?? this.name, aWidth: elements.first.width);
}

class InOutStruct extends LogicStructure {
  InOutStruct({super.name}) : super([LogicNet(name: 'a')]);

  @override
  InOutStruct clone({String? name}) => InOutStruct(name: name ?? this.name);
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
  // ignore: use_super_parameters
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

  @Input.typed(name: 'named_nameable_struct_cond')
  late final NamedNameableStruct? namedNameableStructCond;

  @Input.typed()
  late final RequiredNonNameArgsStruct? requiredNonNameArgsStructCond;

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

  @Output.typed(name: 'top_out_struct')
  late final NamedNameableStruct topOutStruct;

  @Output.typed()
  late final NamedNameableStruct? topOutStructCond;

  @Output.typed()
  late final RequiredNonNameArgsStruct topOutRequiredNonNameArgsStruct;

  @Output.typed()
  late final RequiredNonNameArgsStruct? topOutRequiredNonNameArgsStructCond;

  //TODO: also test output struct typed with name override

  @InOut(name: 'top_in_out', description: 'top in out desc', width: 3)
  late final LogicNet topInOut;

  @InOut()
  late final LogicNet? topInOutCond;

  @InOut.array(
      name: 'top_in_out_arr',
      description: 'top in out arr desc',
      elementWidth: 4,
      dimensions: [2, 3],
      numUnpackedDimensions: 1)
  late final LogicArray topInOutArray;

  @InOut()
  late final LogicArray topInOutArrayUnspecified;

  @InOut.array()
  late final LogicArray? topInOutArrayCond;

  @InOut.typed(name: 'top_in_out_struct', description: 'top in out struct desc')
  late final InOutStruct topInOutStruct;

  @InOut.typed()
  late final InOutStruct? topInOutStructCond;

  //TODO: test typed annotated arg (in all cases top and bottom, incl on Logic, Array, etc.)

  //TODO: test output and inouts in annotated arguments

  //TODO: test parameterized type for typed port

  KitchenGenSinkModule(
    @Input() super.botInPos,
    @Input(width: 7) super.botInPosWidthed,
    @Input() Logic? super.botInPosNullable, {
    @Input() required super.botInNamed,
    @Input() Logic? super.botInNamedOptional,
    @Input(
      name: 'bot_in_named_renamed',
      description: 'bot in named renamed desc',
    )
    required super.botInNamedRenamed,
    @Input.typed() required super.botTypedInput,
    super.topInCondIsPresent = true,
    super.topInArrayCondIsPresent = true,
    super.topOutCondIsPresent = true,
    super.topOutStructCondIsPresent = true,
    super.namedNameableStructCondIsPresent = true,
    super.requiredNonNameArgsStructCondIsPresent = true,
    super.topOutRequiredNonNameArgsStructCondIsPresent = true,
    super.topInWidth,
    super.topInArrayElementWidth,
    super.topInArrayDimensions,
    super.topInArrayNumUnpackedDimensions,
    super.name,
    super.reserveName,
    super.reserveDefinitionName,
    super.definitionName,
    super.botInPosWidth,
    super.namedNameableStruct,
    super.topOutWidth,
    super.topOutArrayUnspecifiedElementWidth,
    super.topOutArrayUnspecifiedDimensions,
    super.topOutArrayUnspecifiedNumUnpackedDimensions,
    super.topInOutCondIsPresent,
    super.topInOutArrayUnspecifiedElementWidth,
    super.topInOutArrayUnspecifiedDimensions,
    super.topInOutArrayUnspecifiedNumUnpackedDimensions,
    super.topInOutArrayCondIsPresent = true,
    super.topInOutStructCondIsPresent = true,
  }) : super(
          requiredNonNameArgsStruct: RequiredNonNameArgsStruct(
              aWidth: 9, name: 'specified_super_name'),
          topTypedLogicArrayIn: LogicArray([1], 5),
          topTypedLogicIn: Logic(width: 4),
          requiredNonNameArgsStructCond: RequiredNonNameArgsStruct(
              aWidth: 9, name: 'specified_super_name'),
          topOutRequiredNonNameArgsStructCondGenerator:
              RequiredNonNameArgsStruct(aWidth: 9, name: 'specified_super_name')
                  .clone,
          topOutRequiredNonNameArgsStructGenerator:
              RequiredNonNameArgsStruct(aWidth: 9, name: 'specified_super_name')
                  .clone,
        );
}

@GenModule()
class OptionalPositionalModule extends _$OptionalPositionalModule {
  OptionalPositionalModule([@Input() Logic? optPosIn, int? optPosInWidth])
      : super(optPosIn, 'renamedOptPos', true, 'renamedOptPosDef', true,
            optPosInWidth);
}

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
    final botInNamedRenamed = Logic();
    final dut = KitchenGenSinkModule(
      Logic(width: 5),
      Logic(width: 7),
      Logic(),
      botInNamed: Logic(),
      botInNamedOptional: Logic(),
      botInNamedRenamed: botInNamedRenamed,
      botTypedInput: NoArgStruct(),
    );

    final dutAdjusted = KitchenGenSinkModule(
      Logic(width: 12),
      botInPosWidth: 12,
      Logic(width: 7),
      Logic(),
      botInNamed: Logic(),
      botInNamedOptional: Logic(),
      botInNamedRenamed: Logic(width: 5),
      botTypedInput: LogicArray([4, 3], 2),
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
      namedNameableStruct: NamedNameableStruct('adjusted_named_named'),
      topOutWidth: 7,
      topOutArrayUnspecifiedElementWidth: 18,
      topOutArrayUnspecifiedDimensions: [7, 8, 9],
      topOutArrayUnspecifiedNumUnpackedDimensions: 2,
      topOutRequiredNonNameArgsStructCondIsPresent: false,
      topOutStructCondIsPresent: false,
      namedNameableStructCondIsPresent: false,
      requiredNonNameArgsStructCondIsPresent: false,
      topInOutCondIsPresent: false,
      topInOutArrayCondIsPresent: false,
      topInOutStructCondIsPresent: false,
      topInOutArrayUnspecifiedElementWidth: 15,
      topInOutArrayUnspecifiedDimensions: [8, 9],
      topInOutArrayUnspecifiedNumUnpackedDimensions: 1,
    );

    await dut.build();
    await dutAdjusted.build();

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

    expect(dut.namedNameableStructCond!.isInput, isTrue);
    expect(dut.namedNameableStructCond!.name, 'named_nameable_struct_cond');
    expect(dutAdjusted.namedNameableStructCond, isNull);

    expect(dut.requiredNonNameArgsStructCond!.isInput, isTrue);
    expect(dutAdjusted.requiredNonNameArgsStructCond, isNull);

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

    expect(dut.topOutStruct.isOutput, isTrue);
    expect(dut.topOutStruct.name, 'top_out_struct');

    expect(dut.topOutStructCond!.isOutput, isTrue);
    expect(dut.topOutStructCond!.name, 'topOutStructCond');
    expect(dutAdjusted.topOutStructCond, isNull);

    expect(dut.topOutRequiredNonNameArgsStruct.isOutput, isTrue);
    expect(dut.topOutRequiredNonNameArgsStruct.name,
        'topOutRequiredNonNameArgsStruct');

    expect(dut.topOutRequiredNonNameArgsStructCond!.isOutput, isTrue);
    expect(dut.topOutRequiredNonNameArgsStructCond!.name,
        'topOutRequiredNonNameArgsStructCond');
    expect(dutAdjusted.topOutRequiredNonNameArgsStructCond, isNull);

    expect(dut.topInOut.isInOut, isTrue);
    expect(dut.topInOut, isA<LogicNet>());
    expect(dut.topInOut.isNet, isTrue);
    expect(dut.topInOut.name, 'top_in_out');
    expect(dut.topInOut.width, 3);
    expect(dut.topInOut.srcConnections.first, dut.topInOutSource);
    expect(dut.topInOutSource, isA<LogicNet>());
    expect(dut.topInOutSource.isNet, isTrue);
    expect(genFileContents, contains('/// top in out desc'));

    expect(dut.topInOutCond!.isInOut, isTrue);
    expect(dut.topInOutCond!.name, 'topInOutCond');
    expect(dut.topInOutCond!.srcConnections.first, dut.topInOutCondSource);
    expect(dut.topInOutCondSource, isA<LogicNet>());
    expect(dut.topInOutCondSource!.isNet, isTrue);
    expect(dutAdjusted.topInOutCond, isNull);
    expect(dutAdjusted.topInOutCondSource, isNull);

    expect(dut.topInOutArray.isInOut, isTrue);
    expect(dut.topInOutArray.name, 'top_in_out_arr');
    expect(dut.topInOutArray.elementWidth, 4);
    expect(dut.topInOutArray.dimensions, [2, 3]);
    expect(dut.topInOutArray.numUnpackedDimensions, 1);
    expect(genFileContents, contains('/// top in out arr desc'));
    expect(dut.topInOutArray.srcConnections.first,
        dut.topInOutArraySource.leafElements.first);
    expect(dut.topInOutArraySource, isA<LogicArray>());
    expect(dut.topInOutArraySource.isNet, isTrue);

    expect(dut.topInOutArrayUnspecified.isInOut, isTrue);
    expect(dut.topInOutArrayUnspecified.name, 'topInOutArrayUnspecified');
    expect(dut.topInOutArrayUnspecified.elementWidth, 1);
    expect(dut.topInOutArrayUnspecified.dimensions, [1]);
    expect(dut.topInOutArrayUnspecified.numUnpackedDimensions, 0);
    expect(dut.topInOutArrayUnspecified.srcConnections.first,
        dut.topInOutArrayUnspecifiedSource.leafElements.first);
    expect(dut.topInOutArrayUnspecifiedSource, isA<LogicArray>());
    expect(dut.topInOutArrayUnspecifiedSource.isNet, isTrue);
    expect(dutAdjusted.topInOutArrayUnspecified.isInOut, isTrue);
    expect(dutAdjusted.topInOutArrayUnspecified.elementWidth, 15);
    expect(dutAdjusted.topInOutArrayUnspecified.dimensions, [8, 9]);
    expect(dutAdjusted.topInOutArrayUnspecified.numUnpackedDimensions, 1);

    expect(dut.topInOutArrayCond, isNotNull);
    expect(dut.topInOutArrayCondSource, isNotNull);
    expect(dut.topInOutArrayCond!.isInOut, isTrue);
    expect(dut.topInOutArrayCond!.isNet, isTrue);
    expect(dut.topInOutArrayCond!.name, 'topInOutArrayCond');
    expect(dut.topInOutArrayCond!.srcConnections.first,
        dut.topInOutArrayCondSource!.leafElements.first);
    expect(dut.topInOutArrayCondSource, isA<LogicArray>());
    expect(dut.topInOutArrayCondSource!.isNet, isTrue);

    expect(dutAdjusted.topInOutArrayCond, isNull);
    expect(dutAdjusted.topInOutArrayCondSource, isNull);

    expect(dut.topInOutStruct.isInOut, isTrue);
    expect(dut.topInOutStruct.isNet, isTrue);
    expect(dut.topInOutStruct, isA<InOutStruct>());
    expect(dut.topInOutStruct.name, 'top_in_out_struct');
    expect(dut.topInOutStruct.elements.first.srcConnections.first,
        dut.topInOutStructSource.leafElements.first);
    expect(dut.topInOutStructSource, isA<InOutStruct>());
    expect(dut.topInOutStructSource.isNet, isTrue);
    expect(genFileContents, contains('/// top in out struct desc'));

    expect(dut.topInOutStructCond!.isInOut, isTrue);
    expect(dut.topInOutStructCond, isA<InOutStruct>());
    expect(dut.topInOutStructCond!.name, 'topInOutStructCond');
    expect(dut.topInOutStructCond!.elements.first.srcConnections.first,
        dut.topInOutStructCondSource!.leafElements.first);
    expect(dut.topInOutStructCondSource, isA<InOutStruct>());
    expect(dut.topInOutStructCondSource!.isNet, isTrue);

    expect(dutAdjusted.topInOutStructCond, isNull);
    expect(dutAdjusted.topInOutStructCondSource, isNull);

    expect(dut.botInPos.isInput, isTrue);
    expect(dut.botInPos.width, 5);

    expect(dutAdjusted.botInPos.width, 12);

    expect(dut.botInPosWidthed.isInput, isTrue);
    expect(dut.botInPosWidthed.width, 7);

    expect(botInNamedRenamed, dut.botInNamedRenamedSource);
    expect(dut.botInNamedRenamed.isInput, isTrue);
    expect(genFileContents, contains('/// bot in named renamed desc'));
    expect(dut.botInNamedRenamed.srcConnection, botInNamedRenamed);
    expect(dut.botInNamedRenamed.name, 'bot_in_named_renamed');

    expect(dut.botTypedInput.isInput, isTrue);
    expect(dut.botTypedInput, isA<NoArgStruct>());
    expect(dut.botTypedInput.elements.first.srcConnection,
        dut.botTypedInputSource.elements.first);

    expect(dutAdjusted.botTypedInput, isA<LogicArray>());
    expect(dutAdjusted.botTypedInputSource, isA<LogicArray>());
    expect(dutAdjusted.botTypedInput.width, 4 * 3 * 2);
  });

  test('opt pos gen module', () async {
    final dut = OptionalPositionalModule(Logic(width: 5), 5);
    final dutAdjusted = OptionalPositionalModule();

    expect(dut.optPosIn!.isInput, isTrue);
    expect(dut.name, 'renamedOptPos');
    expect(dut.definitionName, 'renamedOptPosDef');
    expect(dut.reserveDefinitionName, isTrue);
    expect(dut.reserveName, isTrue);
    expect(dut.optPosIn!.srcConnection, dut.optPosInSource);

    expect(dutAdjusted.optPosIn, isNull);
  });
}
