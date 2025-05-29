part of 'my_logic_structure.dart';

class _$MyLogicStructure extends LogicStructure {
  late final Logic a = elements[1];
  late final Logic b = elements[0];

  final int w;

  _$MyLogicStructure(this.w)
      : super([
          Logic(name: 'b', width: 8),
          Logic(name: 'a', width: MyLogicStructure.calcAWidth(this))
        ]);

  // _$MyLogicStructure._(super.elements, {super.name}) {}
}

class _$YetAnotherLogicStructure extends LogicStructure {
  late final Logic a = elements[0];
  late final Logic b = elements[1];

  _$YetAnotherLogicStructure({required int aWidth, required bool bPresent})
      : super([
          Logic(name: 'a', width: aWidth),
          if (bPresent) Logic(name: 'b', width: 8),
        ]);
}
