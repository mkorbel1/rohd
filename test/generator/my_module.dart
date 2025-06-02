import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/builder/annotations.dart';

import '../logic_structure_test.dart';

part 'my_module.manual.dart';

// ignore_for_file: type_init_formals

// Things to support:
// - inputs, outputs, inouts
// - fixed width or matching width
// - width based on some other argument? >> (exception?)
// - conditional ports  >> (nullable + exception?)
// - extension of another child class of module (non default constructor?)
// - struct ports
// - array ports
// - list of things ports
// - interfaces (normal and pair)

class MyBaseModule extends Module {
  final bool myFlag;
  MyBaseModule({required this.myFlag});
}

@GenModule(extendsModule: MyBaseModule, outputs: [
  Output('c', width: 3),
])
class MyModule extends _$MyModule {
  MyModule(
    @Input(width: 3, description: 'This is input b') super.b, {
    @Input(width: null) required Logic super.a,
    int aw = 3,
    @Input() Logic? super.condInp,
    @Input() required MyStruct super.st,
    required super.myFlag,
  }) : super(aWidth: aw) {
    c <= a & b;
  }
}
