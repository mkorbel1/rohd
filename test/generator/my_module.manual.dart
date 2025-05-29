part of 'my_module.dart';

class _$MyModule extends Module {
  late final Logic a;
  late final Logic b;
  _$MyModule(Logic b, {required Logic a}) {
    this.a = addInput('a', a);
    this.b = addInput('b', b);
  }
}
