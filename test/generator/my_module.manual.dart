part of 'my_module.dart';

class _$MyModule extends MyBaseModule {
  @protected
  late final Logic a;

  /// This is input b.
  @protected
  late final Logic b;

  @protected
  late final Logic? condInp;

  @protected
  late final MyStruct st;

  late final Logic c;

  _$MyModule(
    Logic b, {
    required Logic a,
    required int aWidth,
    required super.myFlag,
    required Logic? condInp,
    required MyStruct st,
  }) {
    this.a = addInput('a', a);
    this.b = addInput('b', b);
    this.condInp = condInp == null ? null : addInput('condInp', condInp);
    c = addOutput('c', width: 3);
    this.st = (st.clone() as MyStruct)..gets(addInput('st', st));
  }
}
