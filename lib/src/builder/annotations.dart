import 'package:rohd/rohd.dart';

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
  final Type? extendsModule; // TODO: add custom constructor?
  const GenModule({this.outputs, this.extendsModule});
}

class IntfPort extends GenLogic {
  const IntfPort(String super.name,
      {super.width, super.description, super.isConditional = false});
}

class GenInterface<T> {
  final Type? extendsModule; // TODO: add custom constructor?
  const GenInterface(Map<T, List<IntfPort>> ports, {this.extendsModule});
}

class StructField extends GenLogic {
  final Logic Function()? constructor; //TODO: ditch constructor?
  final Type? type;
  const StructField(String super.name,
      {super.width,
      super.description,
      super.isConditional = false,
      this.constructor,
      this.type = Logic});
}

class GenStruct {
  const GenStruct({required List<StructField> fields});
}
