import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/interfaces/interfaces.dart';

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

void main() {}
