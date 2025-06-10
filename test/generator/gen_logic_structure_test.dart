import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/builders.dart';
import 'package:meta/meta.dart';

part 'gen_logic_structure_test.g.dart';

class ExampleStruct extends LogicStructure {
  final Logic a;

  factory ExampleStruct() => ExampleStruct._(Logic(name: 'a'));

  ExampleStruct._(this.a) : super([a]);
}

@GenStruct(fields: [GenLogic('a')])
class ExampleStructWithGen extends _$ExampleStructWithGen {}

void main() {}
