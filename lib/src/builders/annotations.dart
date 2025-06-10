import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';

class GenLogic extends GenInfo {
  const GenLogic(
    String name, {
    super.width = 1,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet = false,
  }) : super(dimensions: null, type: null, name: name);

  const GenLogic.array(
    String name, {
    int? elementWidth = 1,
    List<int> super.dimensions = const [1],
    int super.numUnpackedDimensions = 0,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet = false,
  }) : super(width: elementWidth, type: null, name: name);

  const GenLogic.struct(
    String name, {
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet = false,
  }) : super(dimensions: null, name: name);
}

class Input extends GenInfo {
  const Input({
    super.logicName,
    super.width,
    super.description,
    // super.isNet,
  });

  const Input.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    // super.isNet,
  }) : super(width: elementWidth);

  const Input.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet,
  });
}

class Output extends GenInfo {
  const Output({
    super.logicName,
    super.width,
    super.description,
    // super.isNet,
  });

  const Output.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    // super.isNet,
  }) : super(width: elementWidth);

  const Output.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet,
  });
}

class InOut extends GenInfo {
  const InOut({
    super.logicName,
    super.width,
    super.description,
    // super.isNet = true,
  });

  const InOut.array({
    super.logicName,
    int? elementWidth = 1,
    super.dimensions = const [1],
    super.description,
    super.isConditional = false,
    // super.isNet = true,
  }) : super(width: elementWidth);

  const InOut.struct({
    required Type super.type,
    super.description,
    super.isConditional = false,
    super.logicName,
    // super.isNet = true,
  });
}

//TODO: InOut

class GenModule {
  final List<GenLogic>? inputs;
  final List<GenLogic>? outputs;
  final List<GenLogic>? inOuts;

  // final Type? extendsModule; // TODO: add custom constructor?

  /// If specified, this constructor will be used as the base constructor
  /// for the generated module and it will extend the return type of this
  /// constructor.  This must be a non-factory constructor and the base class
  /// must be a [Module].
  final Function? baseConstructor;

  //TODO: do we need interfaces in here too?

  const GenModule(
      {this.inputs, this.outputs, this.inOuts, this.baseConstructor});
}

class GenInterface<T> {
  final Type? extendsModule; // TODO: add custom constructor?
  const GenInterface(Map<T, List<GenLogic>> ports, {this.extendsModule});
}

class GenStruct {
  //TODO name?

  final List<GenLogic> fields;

  const GenStruct({required this.fields});
}
