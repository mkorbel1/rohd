import 'package:rohd/rohd.dart';

class GenLogic {
  final String? name;

  /// The name to use for the [Logic], if different from the variable [name].
  final String? logicName;

  final int? width;
  final String? description; //TODO: test multi-line descriptions
  final bool isConditional;

  final List<int>? dimensions;
  bool get isArray => dimensions != null;

  final Type? type;
  bool get isStruct => type != null;

  final bool isNet;

  const GenLogic._({
    this.name,
    this.logicName,
    this.width,
    this.dimensions,
    this.description,
    this.type,
    this.isConditional = false,
    this.isNet = false,
  });

  const GenLogic(
    String this.name, {
    this.width = 1,
    this.description,
    this.isConditional = false,
    this.logicName,
    this.isNet = false,
  })  : dimensions = null,
        type = null;

  const GenLogic.array(
    String this.name, {
    int? elementWidth = 1,
    this.dimensions = const [1],
    this.description,
    this.isConditional = false,
    this.logicName,
    this.isNet = false,
  })  : width = elementWidth,
        type = null;

  const GenLogic.struct(
    String this.name, {
    required Type this.type,
    this.description,
    this.isConditional = false,
    this.logicName,
    this.isNet = false,
  })  : width = null,
        dimensions = null;
}

class Input extends GenLogic {
  const Input({
    super.logicName,
    super.width,
    super.description,
    super.isNet,
  }) : super._();

  const Input.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet,
  }) : super._(width: elementWidth);

  const Input.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet,
  }) : super._();
}

class Output extends GenLogic {
  const Output({
    super.logicName,
    super.width,
    super.description,
    super.isNet,
  }) : super._();

  const Output.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet,
  }) : super._(width: elementWidth);

  const Output.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet,
  }) : super._();
}

class InOut extends GenLogic {
  const InOut({
    super.logicName,
    super.width,
    super.description,
    super.isNet = true,
  }) : super._();

  const InOut.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet = true,
  }) : super._(width: elementWidth);

  const InOut.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet = true,
  }) : super._();
}

//TODO: InOut

class GenModule {
  final List<GenLogic>? outputs;
  final Type? extendsModule; // TODO: add custom constructor?
  const GenModule({this.outputs, this.extendsModule});
}

class GenInterface<T> {
  final Type? extendsModule; // TODO: add custom constructor?
  const GenInterface(Map<T, List<GenLogic>> ports, {this.extendsModule});
}

class GenStruct {
  const GenStruct({required List<GenLogic> fields});
}
