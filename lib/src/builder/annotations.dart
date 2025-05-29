class GenLogic {
  final String? name;
  final int? width;
  final String? description; //TODO: test multi-line descriptions
  final bool? isConditional;
  const GenLogic(this.name,
      {this.width = 1, this.description, this.isConditional});
}

class Input extends GenLogic {
  const Input({String? name, super.width, super.description}) : super(name);
}

class Output extends GenLogic {
  @override
  String get name => super.name!;

  const Output(String super.name,
      {super.width, super.description, bool super.isConditional = false});
}

class GenModule {
  final List<GenLogic>? outputs;
  final Type? extendsModule;
  const GenModule({this.outputs, this.extendsModule});
}
