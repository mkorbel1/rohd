// Copyright (C) 2021-2023 Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause
//
// logic.dart
// Definition of basic signals, like Logic, and their behavior in the
// simulator, as well as basic operations on them
//
// 2021 August 2
// Author: Max Korbel <max.korbel@intel.com>

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd/src/exceptions/logic/logic_exceptions.dart';
import 'package:rohd/src/utilities/sanitizer.dart';
import 'package:rohd/src/utilities/synchronous_propagator.dart';

/// Represents the event of a [Logic] changing value.
class LogicValueChanged {
  /// The newly updated value of the [Logic].
  final LogicValue newValue;

  /// The previous value of the [Logic].
  final LogicValue previousValue;

  /// Represents the event of a [Logic] changing value from [previousValue]
  /// to [newValue].
  const LogicValueChanged(this.newValue, this.previousValue);

  @override
  String toString() => '$previousValue  -->  $newValue';
}

/// Represents a [Logic] that never changes value.
class Const extends Logic {
  /// Constructs a [Const] with the specified value.
  ///
  /// [val] should be processable by [LogicValue.of].
  Const(dynamic val, {int? width, bool fill = false})
      : super(
            name: 'const_$val',
            width: val is LogicValue ? val.width : width ?? 1) {
    put(val, fill: fill);
    _unassignable = true;
  }
}

//TODO: move _Wire and all of the "signals" to their own files, use "part"
// so that we can keep things safer instead of using @protected

/// Represents a physical wire which shares a common value with one or
/// more [Logic]s.
class _Wire {
  _Wire({required this.width})
      : _currentValue = LogicValue.filled(width, LogicValue.z);

  /// The current active value of this signal.
  LogicValue get value => _currentValue;

  /// The number of bits in this signal.
  final int width;

  /// The current active value of this signal.
  LogicValue _currentValue;

  /// The last value of this signal before the [Simulator] tick.
  ///
  /// This is useful for detecting when to trigger an edge.
  LogicValue? _preTickValue;

  /// A stream of [LogicValueChanged] events for every time the signal
  /// transitions at any time during a [Simulator] tick.
  ///
  /// This event can occur more than once per edge, or even if there is no edge.
  SynchronousEmitter<LogicValueChanged> get glitch => _glitchController.emitter;
  final SynchronousPropagator<LogicValueChanged> _glitchController =
      SynchronousPropagator<LogicValueChanged>();

  /// Controller for stable events that can be safely consumed at the
  /// end of a [Simulator] tick.
  final StreamController<LogicValueChanged> _changedController =
      StreamController<LogicValueChanged>.broadcast(sync: true);

  /// Tracks whether is being subscribed to by anything/anyone.
  bool _changedBeingWatched = false;

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed.
  Stream<LogicValueChanged> get changed {
    if (!_changedBeingWatched) {
      // only do these simulator subscriptions if someone has asked for
      // them! saves performance!
      _changedBeingWatched = true;

      _preTickSubscription = Simulator.preTick.listen((event) {
        _preTickValue = value;
      });
      _postTickSubscription = Simulator.postTick.listen((event) {
        if (value != _preTickValue && _preTickValue != null) {
          _changedController.add(LogicValueChanged(value, _preTickValue!));
        }
      });
    }
    return _changedController.stream;
  }

  /// The subscription to the [Simulator]'s `preTick`.
  ///
  /// Only non-null if [_changedBeingWatched] is true.
  late final StreamSubscription<void> _preTickSubscription;

  /// The subscription to the [Simulator]'s `postTick`.
  ///
  /// Only non-null if [_changedBeingWatched] is true.
  late final StreamSubscription<void> _postTickSubscription;

  /// Cancels all [Simulator] subscriptions and uses [newChanged] as the
  /// source to replace all [changed] events for this [_Wire].
  void _migrateChangedTriggers(Stream<LogicValueChanged> newChanged) {
    if (_changedBeingWatched) {
      unawaited(_preTickSubscription.cancel());
      unawaited(_postTickSubscription.cancel());
      newChanged.listen(_changedController.add);
      _changedBeingWatched = false;
    }
  }

  /// Tells this [_Wire] to adopt all the behavior of [other] so that
  /// it can replace [other].
  void _adopt(_Wire other) {
    _glitchController.emitter.adopt(other._glitchController.emitter);
    other._migrateChangedTriggers(changed);
  }

  /// Store the [negedge] stream to avoid creating multiple copies
  /// of streams.
  Stream<LogicValueChanged>? _negedge;

  /// Store the [posedge] stream to avoid creating multiple copies
  /// of streams.
  Stream<LogicValueChanged>? _posedge;

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed
  /// from `1` to `0`.
  ///
  /// Throws an exception if [width] is not `1`.
  Stream<LogicValueChanged> get negedge {
    if (width != 1) {
      throw Exception(
          'Can only detect negedge when width is 1, but was $width');
    }

    _negedge ??= changed.where((args) => LogicValue.isNegedge(
          args.previousValue,
          args.newValue,
          ignoreInvalid: true,
        ));

    return _negedge!;
  }

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed
  /// from `0` to `1`.
  ///
  /// Throws an exception if [width] is not `1`.
  Stream<LogicValueChanged> get posedge {
    if (width != 1) {
      throw Exception(
          'Can only detect posedge when width is 1, but was $width');
    }

    _posedge ??= changed.where((args) => LogicValue.isPosedge(
          args.previousValue,
          args.newValue,
          ignoreInvalid: true,
        ));

    return _posedge!;
  }

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick.
  Future<LogicValueChanged> get nextChanged => changed.first;

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick from `0` to `1`.
  ///
  /// Throws an exception if [width] is not `1`.
  Future<LogicValueChanged> get nextPosedge => posedge.first;

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick from `1` to `0`.
  ///
  /// Throws an exception if [width] is not `1`.
  Future<LogicValueChanged> get nextNegedge => negedge.first;

  /// Injects a value onto this signal in the current [Simulator] tick.
  ///
  /// This function calls [put()] in [Simulator.injectAction()].
  void inject(dynamic val, {required String signalName, bool fill = false}) {
    Simulator.injectAction(() => put(val, signalName: signalName, fill: fill));
  }

  /// Keeps track of whether there is an active put, to detect reentrance.
  bool _isPutting = false;

  //TODO: update to reference `LogicValue.of`.

  /// Puts a value [val] onto this signal, which may or may not be picked up
  /// for [changed] in this [Simulator] tick.
  ///
  /// The type of [val] and usage of [fill] should be supported by
  /// [LogicValue.of].
  ///
  /// This function is used for propogating glitches through connected signals.
  /// Use this function for custom definitions of [Module] behavior.
  void put(dynamic val, {required String signalName, bool fill = false}) {
    var newValue = LogicValue.of(val, fill: fill, width: width);

    if (newValue.width != width) {
      throw PutException(signalName,
          'Updated value width mismatch. The width of $val should be $width.');
    }

    if (_isPutting) {
      // if this is the result of a cycle, then contention!
      newValue = LogicValue.filled(width, LogicValue.x);
    }

    final prevValue = _currentValue;
    _currentValue = newValue;

    // sends out a glitch if the value deposited has changed
    if (_currentValue != prevValue) {
      _isPutting = true;
      _glitchController.add(LogicValueChanged(_currentValue, prevValue));
      _isPutting = false;
    }
  }
}

/// Represents a logical signal of any width which can change values.
class Logic {
  /// An internal counter for encouraging unique naming of unnamed signals.
  static int _signalIdx = 0;

  // A special quiet flag to prevent `<=` and `<` where inappropriate
  bool _unassignable = false;

  /// Makes it so that this signal cannot be assigned by any full (`<=`) or
  /// conditional (`<`) assignment.
  void makeUnassignable() => _unassignable = true;

  /// The name of this signal.
  final String name;

  /// The [_Wire] which holds the current value and listeners for this [Logic].
  ///
  /// May be a shared object between multiple [Logic]s.
  _Wire _wire;

  /// The number of bits in this signal.
  int get width => _wire.width;

  /// The current active value of this signal.
  LogicValue get value => _wire._currentValue;

  /// The current active value of this signal if it has width 1, as
  /// a [LogicValue].
  ///
  /// Throws an Exception if width is not 1.
  @Deprecated('Use `value` instead.'
      '  Check `width` separately to confirm single-bit.')
  LogicValue get bit => value.bit;

  /// The current valid active value of this signal as an [int].
  ///
  /// Throws an exception if the signal is not valid or can't be represented
  /// as an [int].
  @Deprecated('Use value.toInt() instead.')
  int get valueInt => value.toInt();

  /// The current valid active value of this signal as a [BigInt].
  ///
  /// Throws an exception if the signal is not valid.
  @Deprecated('Use value.toBigInt() instead.')
  BigInt get valueBigInt => value.toBigInt();

  /// Returns `true` iff the value of this signal is valid (no `x` or `z`).
  @Deprecated('Use value.isValid instead.')
  bool hasValidValue() => value.isValid;

  /// Returns `true` iff *all* bits of the current value are floating (`z`).
  @Deprecated('Use value.isFloating instead.')
  bool isFloating() => value.isFloating;

  /// The [Logic] signal that is driving `this`, if any.
  Logic? get srcConnection => _srcConnection;
  Logic? _srcConnection;

  Iterable<Logic> get srcConnections =>
      [if (srcConnection != null) srcConnection!];

  /// An [Iterable] of all [Logic]s that are being directly driven by `this`.
  late final Iterable<Logic> dstConnections =
      UnmodifiableListView(_dstConnections);
  final Set<Logic> _dstConnections = {};

  /// Notifies `this` that [dstConnection] is now directly connected to the
  /// output of `this`.
  void _registerConnection(Logic dstConnection) =>
      _dstConnections.add(dstConnection);

  /// A stream of [LogicValueChanged] events for every time the signal
  /// transitions at any time during a [Simulator] tick.
  ///
  /// This event can occur more than once per edge, or even if there is no edge.
  SynchronousEmitter<LogicValueChanged> get glitch => _wire.glitch;

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed.
  Stream<LogicValueChanged> get changed => _wire.changed;

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed
  /// from `1` to `0`.
  ///
  /// Throws an exception if [width] is not `1`.
  Stream<LogicValueChanged> get negedge => _wire.negedge;

  /// A [Stream] of [LogicValueChanged] events which triggers at most once
  /// per [Simulator] tick, iff the value of the [Logic] has changed
  /// from `0` to `1`.
  ///
  /// Throws an exception if [width] is not `1`.
  Stream<LogicValueChanged> get posedge => _wire.posedge;

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick.
  Future<LogicValueChanged> get nextChanged => _wire.changed.first;

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick from `0` to `1`.
  ///
  /// Throws an exception if [width] is not `1`.
  Future<LogicValueChanged> get nextPosedge => _wire.posedge.first;

  /// Triggers at most once, the next time that this [Logic] changes
  /// value at the end of a [Simulator] tick from `1` to `0`.
  ///
  /// Throws an exception if [width] is not `1`.
  Future<LogicValueChanged> get nextNegedge => _wire.negedge.first;

  /// The [Module] that this [Logic] exists within.
  ///
  /// This only gets populated after its parent [Module], if it exists,
  /// has been built.
  Module? get parentModule => _parentModule;
  Module? _parentModule;

  LogicStructure? get parentStructure => _parentStructure;
  LogicStructure? _parentStructure;

  LogicStructure? get rootStructure {
    //TODO: do we even need this?
    LogicStructure? root = parentStructure;
    while (root?.parentStructure != null) {
      root = root?.parentStructure;
    }
    return root;
  }

  /// True if this is a member of a [LogicArray].
  bool get isArrayMember => parentStructure is LogicArray;

  /// TODO
  /// Returns the name relative to the [parentStructure]-defined hierarchy, if
  /// one exists.  Otherwise, this is the same as [name].
  ///
  /// This is useful for finding the name of a signal as an element of a root
  /// [LogicArray].
  String get structureName {
    if (parentStructure != null) {
      if (parentStructure is LogicArray) {
        return '${parentStructure!.structureName}[${arrayIndex!}]';
      } else {
        return '${parentStructure!.structureName}.$name';
      }
    } else {
      return name;
    }
  }

  //TODO: protect this properly

  int? arrayIndex;
  //TODO
  List<int>? get arrayLocationFromRoot {
    if (!isArrayMember) {
      return null;
    }

    return [
      ...parentStructure!.arrayLocationFromRoot!,
      arrayIndex!,
    ];
  }

  @protected
  set parentStructure(LogicStructure? newParentStructure) =>
      _parentStructure = newParentStructure;

  /// Sets the value of [parentModule] to [newParentModule].
  ///
  /// This should *only* be called by [Module.build()].  It is used to
  /// optimize search.
  @protected
  set parentModule(Module? newParentModule) => _parentModule = newParentModule;

  /// Returns true iff this signal is an input of its parent [Module].
  ///
  /// Note: [parentModule] is not populated until after its parent [Module],
  /// if it exists, has been built. If no parent [Module] exists, returns false.
  bool get isInput => parentModule?.isInput(this) ?? false;

  /// Returns true iff this signal is an output of its parent [Module].
  ///
  /// Note: [parentModule] is not populated until after its parent [Module],
  /// if it exists, has been built. If no parent [Module] exists, returns false.
  bool get isOutput => parentModule?.isOutput(this) ?? false;

  /// Returns true iff this signal is an input or output of its parent [Module].
  ///
  /// Note: [parentModule] is not populated until after its parent [Module],
  /// if it exists, has been built. If no parent [Module] exists, returns false.
  bool get isPort => isInput || isOutput;

  /// Constructs a new [Logic] named [name] with [width] bits.
  ///
  /// The default value for [width] is 1.  The [name] should be synthesizable
  /// to the desired output (e.g. SystemVerilog).
  Logic({String? name, int width = 1})
      : name = (name == null || name.isEmpty)
            ? 's${_signalIdx++}'
            : Sanitizer.sanitizeSV(name),
        _wire = _Wire(width: width) {
    if (width < 0) {
      throw Exception('Logic width must be greater than or equal to 0.');
    }
  }

  @override
  String toString() => 'Logic($width): $name';

  /// Throws an exception if this [Logic] cannot be connected to another signal.
  void _assertConnectable(Logic other) {
    if (_srcConnection != null) {
      throw Exception(
          'This signal "$this" is already connected to "$srcConnection",'
          ' so it cannot be connected to "$other".');
    }
    if (_unassignable) {
      throw Exception('This signal "$this" has been marked as unassignable.  '
          'It may be a constant expression or otherwise should'
          ' not be assigned.');
    }
  }

  /// Injects a value onto this signal in the current [Simulator] tick.
  ///
  /// This function calls [put()] in [Simulator.injectAction()].
  void inject(dynamic val, {bool fill = false}) =>
      _wire.inject(val, signalName: name, fill: fill);

  /// Puts a value [val] onto this signal, which may or may not be picked up
  /// for [changed] in this [Simulator] tick.
  ///
  /// The type of [val] should be an `int`, [BigInt], `bool`, or [LogicValue].
  ///
  /// This function is used for propogating glitches through connected signals.
  /// Use this function for custom definitions of [Module] behavior.
  ///
  /// If [fill] is set, all bits of the signal gets set to [val], similar
  /// to `'` in SystemVerilog.
  void put(dynamic val, {bool fill = false}) =>
      _wire.put(val, signalName: name, fill: fill);

  /// Connects this [Logic] directly to [other].
  ///
  /// Every time [other] transitions (`glitch`es), this signal will transition
  /// the same way.
  void gets(Logic other) {
    _assertConnectable(other);

    // If we are connecting a `LogicStructure` to this simple `Logic`,
    // then pack it first.
    if (other is LogicStructure) {
      // ignore: parameter_assignments
      other = other.packed;
    }

    _connect(other);

    _srcConnection = other;
    other._registerConnection(this);
  }

  /// Handles the actual connection of this [Logic] to [other].
  void _connect(Logic other) {
    _unassignable = true;
    _updateWire(other._wire);
  }

  /// Updates the current active [_Wire] for this [Logic] and also
  /// notifies all downstream [Logic]s of the new source [_Wire].
  void _updateWire(_Wire newWire) {
    // first, propagate the new value (if it's different) downstream
    _wire.put(newWire.value, signalName: name);

    // then, replace the wire
    newWire._adopt(_wire);
    _wire = newWire;

    // tell all downstream signals to update to the new wire as well
    for (final dstConnection in dstConnections) {
      dstConnection._updateWire(newWire);
    }
  }

  /// Connects this [Logic] directly to another [Logic].
  ///
  /// This is shorthand for [gets()].
  void operator <=(Logic other) => gets(other);

  /// Logical bitwise NOT.
  Logic operator ~() => NotGate(this).out;

  /// Logical bitwise AND.
  Logic operator &(Logic other) => And2Gate(this, other).out;

  /// Logical bitwise OR.
  Logic operator |(Logic other) => Or2Gate(this, other).out;

  /// Logical bitwise XOR.
  Logic operator ^(Logic other) => Xor2Gate(this, other).out;

  /// Addition.
  ///
  /// WARNING: Signed math is not fully tested.
  Logic operator +(dynamic other) => Add(this, other).out;

  /// Subtraction.
  ///
  /// WARNING: Signed math is not fully tested.
  Logic operator -(dynamic other) => Subtract(this, other).out;

  /// Multiplication.
  ///
  /// WARNING: Signed math is not fully tested.
  Logic operator *(dynamic other) => Multiply(this, other).out;

  /// Division.
  ///
  /// WARNING: Signed math is not fully tested.
  Logic operator /(dynamic other) => Divide(this, other).out;

  /// Modulo operation.
  Logic operator %(dynamic other) => Modulo(this, other).out;

  /// Arithmetic right-shift.
  Logic operator >>(dynamic other) => ARShift(this, other).out;

  /// Logical left-shift.
  Logic operator <<(dynamic other) => LShift(this, other).out;

  /// Logical right-shift.
  Logic operator >>>(dynamic other) => RShift(this, other).out;

  /// Unary AND.
  Logic and() => AndUnary(this).out;

  /// Unary OR.
  Logic or() => OrUnary(this).out;

  /// Unary XOR.
  Logic xor() => XorUnary(this).out;

  /// Logical equality.
  Logic eq(dynamic other) => Equals(this, other).out;

  /// Logical inequality.
  Logic neq(dynamic other) => NotEquals(this, other).out;

  /// Less-than.
  Logic lt(dynamic other) => LessThan(this, other).out;

  /// Less-than-or-equal-to.
  Logic lte(dynamic other) => LessThanOrEqual(this, other).out;

  /// Greater-than.
  Logic gt(dynamic other) => GreaterThan(this, other).out;

  /// Greater-than-or-equal-to.
  Logic gte(dynamic other) => GreaterThanOrEqual(this, other).out;

  /// Greater-than.
  Logic operator >(dynamic other) => GreaterThan(this, other).out;

  /// Greater-than-or-equal-to.
  Logic operator >=(dynamic other) => GreaterThanOrEqual(this, other).out;

  /// A function that returns whatever [Logic] is provided.
  ///
  /// Used as a default no-op for short-hands.
  @protected
  static Logic nopS(Logic x) => x;

  /// Shorthand for a [Conditional] which increments this by [val].
  ///
  /// By default for a [Logic] variable, if no [val] is provided then the
  /// result is ++variable else result is variable+=[val].
  ///
  /// If using [Combinational], you will need to provide [s] as a remapping
  /// function since otherwise this will cause a "write after read" violation.
  ///
  /// ```dart
  ///
  /// Sequential(clk, [
  ///   pOut.incr(val: b),
  /// ]);
  ///
  /// Combinational.ssa((s) => [
  ///       s(pOut) < a,
  ///       pOut.incr(val: b, s: s),
  ///     ]);
  ///
  /// ```
  Conditional incr({Logic Function(Logic) s = nopS, dynamic val = 1}) =>
      s(this) < s(this) + val;

  /// Shorthand for a [Conditional] which decrements this by [val].
  ///
  /// By default for a [Logic] variable, if no [val] is provided then the
  /// result is --variable else result is var-=[val].
  ///
  /// If using [Combinational], you will need to provide [s] as a remapping
  /// function since otherwise this will cause a "write after read" violation.
  ///
  /// ```dart
  ///
  /// Sequential(clk, [
  ///   pOut.decr(val: b),
  /// ]);
  ///
  /// Combinational.ssa((s) => [
  ///       s(pOut) < a,
  ///       pOut.decr(val: b, s: s),
  ///     ]);
  ///
  /// ```
  Conditional decr({Logic Function(Logic) s = nopS, dynamic val = 1}) =>
      s(this) < s(this) - val;

  /// Shorthand for a [Conditional] which increments this by [val].
  ///
  /// For a [Logic] variable, this is variable *= [val].
  ///
  /// If using [Combinational], you will need to provide [s] as a remapping
  /// function since otherwise this will cause a "write after read" violation.
  ///
  /// ```dart
  ///
  /// Sequential(clk, [
  ///   pOut.mulAssign(val: b),
  /// ]);
  ///
  /// Combinational.ssa((s) => [
  ///       s(pOut) < a,
  ///       pOut.mulAssign(val: b, s: s),
  ///     ]);
  ///
  /// ```
  Conditional mulAssign({Logic Function(Logic) s = nopS, dynamic val}) =>
      s(this) < s(this) * val;

  /// Shorthand for a [Conditional] which increments this by [val].
  ///
  /// For a [Logic] variable, this is variable /= [val].
  ///
  /// If using [Combinational], you will need to provide [s] as a remapping
  /// function since otherwise this will cause a "write after read" violation.
  ///
  /// ```dart
  ///
  /// Sequential(clk, [
  ///   pOut.divAssign(val: b),
  /// ]);
  ///
  /// Combinational.ssa((s) => [
  ///       s(pOut) < a,
  ///       pOut.divAssign(val: b, s: s),
  ///     ]);
  ///
  /// ```
  Conditional divAssign({Logic Function(Logic) s = nopS, dynamic val}) =>
      s(this) < s(this) / val;

  /// Conditional assignment operator.
  ///
  /// Represents conditionally asigning the value of another signal to this.
  /// Returns an instance of [ConditionalAssign] to be be passed to a
  /// [Conditional].
  Conditional operator <(dynamic other) {
    if (_unassignable) {
      throw Exception('This signal "$this" has been marked as unassignable.  '
          'It may be a constant expression or otherwise'
          ' should not be assigned.');
    }

    if (other is Logic) {
      return ConditionalAssign(this, other);
    } else {
      return ConditionalAssign(this, Const(other, width: width));
    }
  }

  /// Accesses the [index]th bit of this signal.
  ///
  /// Accepts both [int] and [Logic] as [index].
  ///
  /// Throws [Exception] when index is not an [int] or [Logic].
  ///
  /// Negative/Positive index values are allowed (only when index is an int).
  /// When, index is a Logic, the index value is treated as an unsigned value.
  /// The negative indexing starts from the end=[width]-1
  ///
  /// -([width]) <= [index] < [width]
  ///
  /// ```dart
  /// Logic nextVal = addOutput('nextVal', width: width);
  /// // Example: val = 0xce, val.width = 8, bin(0xce) = "0b11001110"
  /// // Positive Indexing
  /// nextVal <= val[3]; // output: 1
  ///
  /// // Negative Indexing
  /// nextVal <= val[-5]; // output: 1, also val[3] == val[-5]
  ///
  /// // Error cases
  /// nextVal <= val[-9]; // Error!: allowed values [-8, 7]
  /// nextVal <= val[8]; // Error!: allowed values [-8, 7]
  /// ```
  /// Note: When, indexed by a Logic value, out-of-bounds will always return an
  /// invalid (LogicValue.x) value. This behavior is differs in simulation as
  /// compared to the generated SystemVerilog. In the generated SystemVerilog,
  /// [index] will be ignored, and the logic is returned as-is.
  Logic operator [](dynamic index) {
    if (index is Logic) {
      return IndexGate(this, index).selection;
    } else if (index is int) {
      return slice(index, index);
    }
    throw Exception('Expected `int` or `Logic`');
  }

  //TODO: test this
  late final List<Logic> elements =
      List.generate(width, (index) => this[index], growable: false);

  /// Accesses a subset of this signal from [startIndex] to [endIndex],
  /// both inclusive.
  ///
  /// If [endIndex] comes before the [startIndex] on position, the returned
  /// value will be reversed relative to the original signal.
  /// Negative/Positive index values are allowed. (The negative indexing starts from where the array ends)
  ///
  ///
  /// ```dart
  /// Logic nextVal = addOutput('nextVal', width: width);
  /// // Example: val = 0xce, val.width = 8, bin(0xce) = "0b11001110"
  /// // Negative Slicing
  /// nextVal <= val.slice(val.width - 1, -3); // = val.slice(7,5) & output: 0b110, where the output.width=3
  ///
  /// // Positive Slicing
  /// nextVal <= val.slice(5, 0); // = val.slice(-3, -8) & output: 0b001110, where the output.width=6
  /// ```
  ///
  Logic slice(int endIndex, int startIndex) {
    // Given start and end index, if either of them are seen to be -ve index
    // value(s) then convert them to a +ve index value(s)
    final modifiedStartIndex =
        (startIndex < 0) ? width + startIndex : startIndex;
    final modifiedEndIndex = (endIndex < 0) ? width + endIndex : endIndex;

    if (modifiedStartIndex == 0 && modifiedEndIndex == width - 1) {
      // ignore: avoid_returning_this
      return this;
    }

    // Create a new bus subset
    return BusSubset(this, modifiedStartIndex, modifiedEndIndex).subset;
  }

  /// Returns a version of this [Logic] with the bit order reversed.
  Logic get reversed => slice(0, width - 1);

  /// Returns a subset [Logic].  It is inclusive of [startIndex], exclusive of
  /// [endIndex].
  ///
  /// The [startIndex] must come before the [endIndex]. If [startIndex] and
  /// [endIndex] are equal, then a zero-width signal is returned.
  /// Negative/Positive index values are allowed. (The negative indexing starts from where the array ends)
  ///
  /// If [endIndex] is not provided, [width] of the [Logic] will
  /// be used as the default values which assign it to the last index.
  ///
  /// ```dart
  /// Logic nextVal = addOutput('nextVal', width: width);
  /// // Example: val = 0xce, val.width = 8, bin(0xce) = "0b11001110"
  /// // Negative getRange
  /// nextVal <= val.getRange(-3, val.width); // = val.getRange(5,8) & output: 0b110, where the output.width=3
  ///
  /// // Positive getRange
  /// nextVal <= val.getRange(0, 6); // = val.slice(0, -2) & output: 0b001110, where the output.width=6
  ///
  /// // Get range from startIndex
  /// nextVal <= val.getRange(-3); // the endIndex will be auto assign to val.width
  /// ```
  ///
  Logic getRange(int startIndex, [int? endIndex]) {
    endIndex ??= width;
    if (endIndex == startIndex) {
      return Const(0, width: 0);
    }

    // Given start and end index, if either of them are seen to be -ve index
    // value(s) then conver them to a +ve index value(s)
    final modifiedStartIndex =
        (startIndex < 0) ? width + startIndex : startIndex;
    final modifiedEndIndex = (endIndex < 0) ? width + endIndex : endIndex;
    if (modifiedEndIndex < modifiedStartIndex) {
      throw Exception(
          'End $modifiedEndIndex(=$endIndex) cannot be less than start'
          ' $modifiedStartIndex(=$startIndex).');
    }
    return slice(modifiedEndIndex - 1, modifiedStartIndex);
  }

  /// Returns a new [Logic] with width [newWidth] where new bits added are zeros
  /// as the most significant bits.
  ///
  /// The [newWidth] must be greater than or equal to the current width or an
  /// exception will be thrown.
  Logic zeroExtend(int newWidth) {
    if (newWidth < width) {
      throw Exception(
          'New width $newWidth must be greater than or equal to width $width.');
    }
    return [
      Const(0, width: newWidth - width),
      this,
    ].swizzle();
  }

  /// Returns a new [Logic] with width [newWidth] where new bits added are sign
  /// bits as the most significant bits.  The sign is determined using two's
  /// complement, so it takes the most significant bit of the original signal
  /// and extends with that.
  ///
  /// The [newWidth] must be greater than or equal to the current width or
  /// an exception will be thrown.
  Logic signExtend(int newWidth) {
    if (width == 1) {
      return ReplicationOp(this, newWidth).replicated;
    } else if (newWidth > width) {
      return [
        ReplicationOp(this[width - 1], newWidth - width).replicated,
        this,
      ].swizzle();
    } else if (newWidth == width) {
      // ignore: avoid_returning_this
      return this;
    }

    throw Exception(
        'New width $newWidth must be greater than or equal to width $width.');
  }

  /// Returns a copy of this [Logic] with the bits starting from [startIndex]
  /// up until [startIndex] + [update]`.width` set to [update] instead
  /// of their original value.
  ///
  /// The return signal will be the same [width].  An exception will be thrown
  /// if the position of the [update] would cause an overrun past the [width].
  Logic withSet(int startIndex, Logic update) {
    if (startIndex + update.width > width) {
      throw Exception(
          'Width of updatedValue $update at startIndex $startIndex would'
          ' overrun the width of the original ($width).');
    }

    return [
      getRange(startIndex + update.width, width),
      update,
      getRange(0, startIndex),
    ].swizzle();
  }

  /// Returns a replicated signal using [ReplicationOp] with new
  /// width = this.width * [multiplier]
  /// The input [multiplier] cannot be negative or 0; an exception will be
  /// thrown, otherwise.
  Logic replicate(int multiplier) => ReplicationOp(this, multiplier).replicated;

  /// Returns `1` (of [width]=1) if the [Logic] calling this function is in
  /// [list]. Else `0` (of [width]=1) if not present.
  ///
  /// The [list] can be [Logic] or [int] or [bool] or [BigInt] or
  /// [list] of [dynamic] i.e combinition of aforementioned types.
  ///
  Logic isIn(List<dynamic> list) {
    // By default isLogicIn is not present return `0`:
    // Empty list corner-case state
    Logic isLogicIn = Const(0, width: 1);
    for (final dynamic y in list) {
      // Iterating through the list to check if the logic is present
      isLogicIn |= eq(y);
    }
    return isLogicIn;
  }
}