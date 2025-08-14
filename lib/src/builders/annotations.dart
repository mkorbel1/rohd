import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';

class Input extends GenInfo {
  const Input({
    super.name,
    super.width, //TODO: default is 1? nullable still is dynamic?
    super.description,
  }) : super(logicType: LogicType.logic);

  const Input.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const Input.typed({
    super.description,
    super.name,
  }) : super(logicType: LogicType.typed);
}

class Output extends GenInfo {
  const Output({
    super.name,
    super.width,
    super.description,
    // super.isNet,
  }) : super(logicType: LogicType.logic);

  const Output.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
    // super.isNet,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const Output.typed({
    super.description,
    super.name,
    // super.isNet,
  }) : super(logicType: LogicType.typed);
}

class InOut extends GenInfo {
  const InOut({
    super.name,
    super.width,
    super.description,
  }) : super(logicType: LogicType.logic);

  const InOut.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const InOut.typed({
    super.description,
    super.name,
  }) : super(logicType: LogicType.typed);
}

// TODO: annotation for adding interfaces to modules
class Intf {}

//TODO: do structs and interfaces need a net indication?

class StructField extends GenInfo {
  const StructField({
    super.name,
    super.width,
  }) : super(logicType: LogicType.logic);

  const StructField.array({
    super.name,
    super.dimensions,
    super.numUnpackedDimensions,
    int? elementWidth,
    // super.isNet,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const StructField.typed({
    super.name,
  }) : super(logicType: LogicType.typed);
}

// TODO: consider name: InterfacePort, but then Intf above?
class IntfPort<TagType extends Enum> extends GenInfo {
  final TagType tag;

  const IntfPort(
    this.tag, {
    super.name,
    super.width,
  }) : super(logicType: LogicType.logic);

  const IntfPort.array(
    this.tag, {
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const IntfPort.typed(
    this.tag, {
    super.name,
  }) : super(logicType: LogicType.typed);
}

//TODO: InOut

class GenModule {
  // final List<GenLogic>? inputs;
  // final List<GenLogic>? outputs;
  // final List<GenLogic>? inOuts;

  // final Type? extendsModule; // TODO: add custom constructor?

  /// If specified, this constructor will be used as the base constructor
  /// for the generated module and it will extend the return type of this
  /// constructor.  This must be a non-factory constructor and the base class
  /// must be a [Module].
  final Function? baseConstructor;

  //TODO: do we need interfaces in here too?

  const GenModule(
      {
      // this.inputs, this.outputs, this.inOuts,
      this.baseConstructor});
}

class GenInterface<T extends Enum> {
  // final Type? extendsModule; // TODO: add custom constructor?

  // final Map<T, List<GenLogic>>? ports;

  final Function? baseConstructor;

  const GenInterface({this.baseConstructor});
}

class GenStruct {
  //TODO name?

  // final List<GenLogic> fields;

  const GenStruct(
      // {required this.fields}
      );
}
