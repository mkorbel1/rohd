import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:test/test.dart';

part 'gen_module_test.g.dart';

class ExampleModule extends Module {
  Logic get b => output('b');
  ExampleModule(Logic a) : super(name: 'simple_module') {
    a = addInput('a', a);
    addOutput('b', width: 3);
    b <= ~a;
  }
}

@GenModule(outputs: [Output('b')])
class ExampleModuleWithGen extends Module {
  ExampleModuleWithGen(@Input() Logic a) : super(name: 'simple_module') {
    // b <= ~a;
  }
}

void main() {
  group('simple module', () {
    for (final modBuilder in [ExampleModule.new, ExampleModuleWithGen.new]) {
      test('builds and generates code $modBuilder', () async {
        final mod = modBuilder(Logic());
        await mod.build();
        expect(mod.outputs['b']!.width, 3);
        final svCode = mod.generateSynth();
        expect(svCode, contains('module simple_module'));
      });
    }
  });
}
