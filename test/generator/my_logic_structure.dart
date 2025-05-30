import 'package:rohd/rohd.dart';
import 'package:rohd/src/builder/annotations.dart';

import '../logic_structure_test.dart';

part 'my_logic_structure.manual.dart';

// Things to support:
// - fixed width
// - widths based on some other argument
// - conditional presence of a signal
// - nested structures
// - implement clone

// yes this looks good!
@GenStruct(
  fields: [
    StructField('a', width: null),
    StructField('b', width: 8, isConditional: true),
    StructField('rv', constructor: MyStruct.new, type: MyStruct)
  ],
)
class MyLogicStructure extends _$MyLogicStructure {
  MyLogicStructure({required super.aWidth, required super.bPresent});
}
