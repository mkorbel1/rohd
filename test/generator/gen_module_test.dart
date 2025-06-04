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

@GenModule(outputs: [GenLogic('b')])
class ExampleModuleWithGen extends _$ExampleModuleWithGen {
  ExampleModuleWithGen(@Input() super.a) {
    b <= ~a;
  }
}

@GenModule() // no outputs specified
class NonSuperInputMod extends _$NonSuperInputMod {
  // input is not calling super, but passes it up to the parent class
  NonSuperInputMod(@Input() Logic a) : super(a);
}

class GenBaseMod extends Module {
  final bool myFlag;
  GenBaseMod({required this.myFlag});
}

@GenModule(outputs: [GenLogic('b')], baseConstructor: GenBaseMod.new)
class GenSubMod extends _$GenSubMod {
  GenSubMod(@Input() super.a);
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
}
