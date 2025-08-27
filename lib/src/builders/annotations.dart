import 'package:rohd/rohd.dart';
import 'package:rohd/src/builders/gen_info.dart';

class Input extends GenInfo {
  const Input({
    super.name,
    super.width, //TODO: default is 1? nullable still is dynamic?
    super.description,
  }) : super(logicType: LogicType.logic, isNet: false);

  const Input.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array, isNet: false);

  const Input.typed({
    super.description,
    super.name,
  }) : super(logicType: LogicType.typed, isNet: false);
}

class Output extends GenInfo {
  const Output({
    super.name,
    super.width,
    super.description,
    // super.isNet,
  }) : super(logicType: LogicType.logic, isNet: false);

  const Output.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
    // super.isNet,
  }) : super(width: elementWidth, logicType: LogicType.array, isNet: false);

  const Output.typed({
    super.description,
    super.name,
    // super.isNet,
  }) : super(logicType: LogicType.typed, isNet: false);
}

class InOut extends GenInfo {
  const InOut({
    super.name,
    super.width,
    super.description,
  }) : super(logicType: LogicType.logic, isNet: true);

  const InOut.array({
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    super.description,
  }) : super(width: elementWidth, logicType: LogicType.array, isNet: true);

  const InOut.typed({
    super.description,
    super.name,
  }) : super(logicType: LogicType.typed, isNet: true);
}

// TODO: annotation for adding interfaces to modules
class Intf<TagType extends Enum> {
  final List<TagType>? inputTags;
  final List<TagType>? outputTags;
  final List<TagType>? inOutTags;

  final String? name;

  const Intf({this.name, this.inputTags, this.outputTags, this.inOutTags});
}

class PairIntf {
  final PairRole role;

  final String? name;

  const PairIntf(this.role, {this.name});
}

//TODO: do structs and interfaces need a net indication?

class StructField extends GenInfo {
  const StructField({
    super.name,
    super.width,
  }) : super(logicType: LogicType.logic, isNet: null);

  const StructField.array({
    super.name,
    super.dimensions,
    super.numUnpackedDimensions,
    int? elementWidth,
    bool super.isNet = false,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const StructField.typed({
    super.name,
  }) : super(logicType: LogicType.typed, isNet: null);
}

// TODO: consider name: InterfacePort, but then Intf above?
class IntfPort<TagType extends Enum> extends GenInfo {
  final TagType tag;

  const IntfPort(
    this.tag, {
    super.name,
    super.width,
  }) : super(logicType: LogicType.logic, isNet: null);

  const IntfPort.array(
    this.tag, {
    super.name,
    int? elementWidth,
    super.dimensions,
    super.numUnpackedDimensions,
    bool super.isNet = false,
  }) : super(width: elementWidth, logicType: LogicType.array);

  const IntfPort.typed(
    this.tag, {
    super.name,
  }) : super(logicType: LogicType.typed, isNet: false);
}

class SubPairIntf {
  final String? name;

  final bool reverse;

  const SubPairIntf({this.name, this.reverse = false});
}

class GenModule {
  /// If specified, this constructor will be used as the base constructor
  /// for the generated module and it will extend the return type of this
  /// constructor.  This must be a non-factory constructor and the base class
  /// must be a [Module].
  final Function? baseConstructor;

  //TODO: do we need interfaces in here too?

  const GenModule({this.baseConstructor});
}

class GenInterface<T extends Enum> {
  final Function? baseConstructor;

  const GenInterface({this.baseConstructor});

  const GenInterface.pair() : baseConstructor = PairInterface.new;
}

class GenStruct {
  //TODO name?

  const GenStruct();
}
