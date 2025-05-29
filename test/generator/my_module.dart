import 'package:rohd/rohd.dart';

part 'my_module.manual.dart';

// ignore_for_file: type_init_formals

// Things to support:
// - inputs, outputs, inouts
// - fixed width or matching width
// - width based on some other argument? >> (exception?)
// - conditional ports  >> (nullable + exception?)
// - extension of another child class of module
// - struct ports
// - array ports
// - list of things ports

class Input {
  const Input();
}

class GenModule {
  final List<GenLogic>? outputs;
  const GenModule({this.outputs});
}

class GenLogic {
  final String name;
  final int? width;
  const GenLogic(this.name, {this.width});
}

@GenModule(outputs: [
  GenLogic('c', width: 3),
])
class MyModule extends _$MyModule {
  // late final Logic c = addOutput('c');

  MyModule(
    @Input() super.b, {
    @Input() required Logic super.a,
  }) {
    a & b;
  }
}
