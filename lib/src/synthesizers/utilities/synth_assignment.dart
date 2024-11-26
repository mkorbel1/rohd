import 'package:rohd/src/synthesizers/utilities/utilities.dart';

/// Represents an assignment between two signals.
class SynthAssignment {
  SynthLogic _dst;

  /// The destination being driven by this assignment.
  ///
  /// Ensures it's always using the most up-to-date version.
  SynthLogic get dst {
    if (_dst.replacement != null) {
      _dst = _dst.replacement!;
      assert(_dst.replacement == null, 'should not be a chain...');
    }
    return _dst;
  }

  SynthLogic _src;

  /// The source driving in this assignment.
  ///
  /// Ensures it's always using the most up-to-date version.
  SynthLogic get src {
    if (_src.replacement != null) {
      _src = _src.replacement!;
      assert(_src.replacement == null, 'should not be a chain...');
    }
    return _src;
  }

  /// Constructs a representation of an assignment.
  SynthAssignment(this._src, this._dst);

  @override
  String toString() => '$dst <= $src';
}
