part of 'my_interface.dart';

class _$MyInterface extends PairInterface {
  _$MyInterface({required int bWidth, required bool aPresent}) {
    if (aPresent) {
      setPorts([Logic.port('a')], [PairDirection.fromProvider]);
    }
    setPorts([Logic.port('b', bWidth)], [PairDirection.fromProvider]);
  }
}
