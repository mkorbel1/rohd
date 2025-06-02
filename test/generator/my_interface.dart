import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/annotations.dart';
import 'package:rohd/src/interfaces/interfaces.dart';

part 'my_interface.manual.dart';
part 'my_interface.g.dart';

// Things to support:
// - width based on other arguments
// - conditional/optional ports
// - extend another intf base class
// - hierarchical interfaces << let them do it manually?
// - structure ports << let them do it manually?
// - implement clone?

@GenInterface(extendsModule: PairInterface, {
  PairDirection.fromProvider: [
    IntfPort('a', isConditional: true),
    IntfPort('b', width: null),
  ],
})
class MyInterface extends _$MyInterface {
  MyInterface(int w) : super(bWidth: w, aPresent: w > 3) {
    setPorts([Logic.port('c', 2 * w)]);
  }
}
