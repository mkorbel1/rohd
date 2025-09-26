import 'package:rohd/builder.dart';

class IntfExtracted extends Intf {
  @override
  String get name => super.name!;

  IntfExtracted({
    required String super.name,
    required super.inputTags,
    required super.outputTags,
    required super.inOutTags,
  });
}

class PairIntfExtracted extends PairIntf {
  @override
  String get name => super.name!;

  PairIntfExtracted(super.role, {required String super.name});
}
