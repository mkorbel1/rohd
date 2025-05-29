part of 'my_logic_structure.dart';

class _$MyLogicStructure extends LogicStructure {
  late final Logic a = elements[0];
  late final Logic b = elements[1];

  _$MyLogicStructure({required int aWidth, required bool bPresent})
      : super([
          Logic(name: 'a', width: aWidth),
          if (bPresent) Logic(name: 'b', width: 8),
        ]);
}
