import 'package:rohd/rohd.dart';
import 'package:rohd/src/interfaces/interfaces.dart';

part 'my_interface.manual.dart';

// Things to support:
// - width based on other arguments
// - conditional/optional ports
// - extend another intf base class
// - hierarchical interfaces
// - structure ports

class GenIntfPort {
  const GenIntfPort(String name);
}

class GenInterface<T> {
  const GenInterface(Map<T, List<GenIntfPort>> ports);
}

@GenInterface({
  PairDirection.fromProvider: [
    GenIntfPort('a'),
    GenIntfPort('b'),
  ],
})
class MyInterface extends _$MyInterface {}

class MyOtherInterface extends Interface {
  @GenIntfPort('a')
  final Logic a = Logic(name: 'a', width: 8);
  //then we can just call setPorts on all of them?

  late final Logic b = setPort(Logic(name: 'b'));

  Logic setPort(Logic p) {
    setPorts([p]);
    return port(p.name);
  }
}

abstract class _YetAnotherInterface extends Interface {
  @GenIntfPort('asdf')
  Logic get a;
}
