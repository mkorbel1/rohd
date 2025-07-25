import 'dart:math';

import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';

class Input extends GenInfo {
  const Input({
    super.logicName,
    super.width, //TODO: default is 1? nullable still is dynamic?
    super.description,
  }) : super(logicType: LogicType.logic);

  const Input.array({
    super.logicName,
    int? elementWidth,
    super.dimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const Input.struct({
    super.description,
    super.logicName,
  }) : super(logicType: LogicType.struct);
}

class Output extends GenInfo {
  const Output({
    super.logicName,
    super.width,
    super.description,
    // super.isNet,
  }) : super(logicType: LogicType.logic);

  const Output.array({
    super.logicName,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
    // super.isNet,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const Output.struct({
    super.description,
    super.logicName,
    // super.isNet,
  }) : super(logicType: LogicType.struct);
}

class InOut extends GenInfo {
  const InOut({
    super.logicName,
    super.width,
    super.description,
  }) : super(logicType: LogicType.logic);

  const InOut.array({
    super.logicName,
    int? elementWidth,
    super.dimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const InOut.struct({
    super.description,
    super.logicName,
  }) : super(logicType: LogicType.struct);
}

// TODO: annotation for adding interfaces to modules
class Intf {}

//TODO: do structs and interfaces need a net indication?

class StructField extends GenInfo {
  const StructField({
    super.logicName,
    super.width = 1,
  }) : super(logicType: LogicType.logic);

  const StructField.array({
    super.logicName,
    super.dimensions,
    super.numUnpackedDimensions,
    int? elementWidth,
    // super.isNet,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const StructField.struct({
    super.logicName,
  }) : super(logicType: LogicType.struct);
}

// TODO: consider name: InterfacePort, but then Intf above?
class IntfPort<TagType extends Enum> extends GenInfo {
  final TagType tag;

  const IntfPort(
    this.tag, {
    super.logicName,
    super.width,
  }) : super(logicType: LogicType.logic);

  const IntfPort.array(
    this.tag, {
    super.logicName,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const IntfPort.struct(
    this.tag, {
    super.logicName,
  }) : super(logicType: LogicType.struct);
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
