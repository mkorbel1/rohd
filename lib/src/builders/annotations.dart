import 'package:rohd/rohd.dart';

class _GenLogic {
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

  const _GenLogic({
    this.name,
    this.logicName,
    this.width,
    this.dimensions,
    this.description,
    this.type,
    this.isConditional = false,
    this.isNet = false,
  });
}

class GenLogic extends _GenLogic {
  const GenLogic(
    String name, {
    super.width = 1,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet = false,
  }) : super(dimensions: null, type: null, name: name);

  const GenLogic.array(
    String name, {
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet = false,
  }) : super(width: elementWidth, type: null, name: name);

  const GenLogic.struct(
    String name, {
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet = false,
  }) : super(dimensions: null, name: name);
}

class Input extends _GenLogic {
  const Input({
    super.logicName,
    super.width,
    super.description,
    super.isNet,
  });

  const Input.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet,
  }) : super(width: elementWidth);

  const Input.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet,
  });
}

class Output extends _GenLogic {
  const Output({
    super.logicName,
    super.width,
    super.description,
    super.isNet,
  });

  const Output.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet,
  }) : super(width: elementWidth);

  const Output.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet,
  });
}

class InOut extends _GenLogic {
  const InOut({
    super.logicName,
    super.width,
    super.description,
    super.isNet = true,
  });

  const InOut.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    super.isNet = true,
  }) : super(width: elementWidth);

  const InOut.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    super.isNet = true,
  });
}

//TODO: InOut

class GenModule {
  final List<GenLogic>? outputs;
  // final Type? extendsModule; // TODO: add custom constructor?

  /// If specified, this constructor will be used as the base constructor
  /// for the generated module and it will extend the return type of this
  /// constructor.  This must be a non-factory constructor and the base class
  /// must be a [Module].
  final Function? baseConstructor;

  const GenModule({this.outputs, this.baseConstructor});
}

class GenInterface<T> {
  final Type? extendsModule; // TODO: add custom constructor?
  const GenInterface(Map<T, List<GenLogic>> ports, {this.extendsModule});
}

class GenStruct {
  const GenStruct({required List<GenLogic> fields});
}
