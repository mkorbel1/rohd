import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';

import '../logic_structure_test.dart';

part 'my_logic_structure.manual.dart';

// Things to support:
// - fixed width
// - widths based on some other argument
// - conditional presence of a signal
// - nested structures (nullable for optional?)
// - implement clone

// yes this looks good!
// @GenStruct(
//   fields: [
//     GenLogic('a', width: null),
//     GenLogic('b', width: 8, isConditional: true),
//     GenLogic.struct('rv', type: MyStruct),
//     GenLogic.struct('rv2', type: MyStruct)
//   ],
// )
class MyLogicStructure extends _$MyLogicStructure {
  MyLogicStructure(int x, {required super.aWidth, required super.bPresent})
      : super(rv2: MyStruct());
}

// @GenModule()
// class MyFpOperation extends _$MyFpOperation {
//   @Output()
//   FloatingPoint myOut1;

//   @Output()
//   FloatingPoint myOut2;

//   MyFpOperation(
//     @Input() FloatingPoint myIn,
//   ) : super(
//           myOut1: FloatingPoint(mantissaWdith: 25),
//           myOut2: myIn.clone(),
//         );
// }

// class _$MyFpOperation {
//   _$MyFpOperation({FloatingPoint myOut1}) {
//     addMatchedOutput('myOut1', myOut1 ?? FloatingPoint());
//   }
// }
