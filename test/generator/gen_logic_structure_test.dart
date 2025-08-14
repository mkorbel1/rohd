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

@GenStruct()
class ExampleStructWithGen extends _$ExampleStructWithGen {
  /// Documentation here.
  @StructField()
  late final Logic a;

  @StructField()
  late final Logic b;
}

@GenStruct()
class KitchenSinkStruct extends _$KitchenSinkStruct {
  @StructField()
  late final Logic basic;

  @StructField.array()
  late final LogicArray array;

  @StructField.typed()
  late final ExampleStructWithGen struct;

  KitchenSinkStruct({super.name});
}

//TODO: name in super

//TODO: BUG! elements are backwards, make sure order of elements is right!

void main() {}
