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

@GenStruct<MyLogicStructure>(
  [
    GenStructField('a', widthCalc: MyLogicStructure.calcAWidth),
    GenStructField('b', width: 8),
  ],
)
class MyLogicStructure extends _$MyLogicStructure {
  MyLogicStructure(super.w);

  static int calcAWidth(MyLogicStructure s) => 4;

  // MyLogicStructure()
  //     : super._([
  //         /// Description of a
  //         Logic(name: 'a'),

  //         /// Description of b
  //         Logic(name: 'b', width: 8),
  //       ]);
}

class MyOtherLogicStructure extends LogicStructure {
  MyOtherLogicStructure(int aWidth)
      : super([
          // this could be *anything* in here -- if/for, functions, etc., too hard?
          Logic(name: 'a', width: aWidth),
          Logic(name: 'b', width: 8),
        ]);
}

// yes this looks good!
@GenStruct(
  [
    GenStructField('a', width: null),
    GenStructField('b', width: 8, isConditional: true),
  ],
)
class YetAnotherLogicStructure extends _$YetAnotherLogicStructure {
  YetAnotherLogicStructure({required super.aWidth, required super.bPresent});
}
