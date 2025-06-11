import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/builders.dart';
import 'package:meta/meta.dart';

part 'gen_logic_structure_test.g.dart';

class ExampleStruct extends LogicStructure {
  final Logic a;
  final Logic b;

  factory ExampleStruct() =>
      ExampleStruct._(Logic(name: 'a'), Logic(name: 'b'));

  ExampleStruct._(this.a, this.b) : super([b, a]);
}

@GenStruct(fields: [GenLogic('a'), GenLogic('b')])
class ExampleStructWithGen extends _$ExampleStructWithGen {}
//TODO: name in super

void main() {}
