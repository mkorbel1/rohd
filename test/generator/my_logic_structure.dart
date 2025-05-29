import 'package:rohd/rohd.dart';

part 'my_logic_structure.manual.dart';

// Things to support:
// - fixed width
// - widths based on some other argument
// - conditional presence of a signal
// - nested structures
// - implement clone

class GenStruct<T extends LogicStructure> {
  const GenStruct(List<GenStructField<T>> x);
}

class GenStructField<T extends LogicStructure> {
  final String name;
  final int? width;
  final bool isConditional;

  final int Function(T)? widthCalc;
  // also calcPresence

  const GenStructField(this.name,
      {this.width, this.widthCalc, this.isConditional = false});
}

// yes this looks good!
@GenStruct(
  [
    GenStructField('a', width: null),
    GenStructField('b', width: 8, isConditional: true),
  ],
)
class MyLogicStructure extends _$MyLogicStructure {
  MyLogicStructure({required super.aWidth, required super.bPresent});
}
