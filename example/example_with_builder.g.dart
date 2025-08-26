// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: avoid_setters_without_getters, unused_element_parameter

part of 'example_with_builder.dart';

// **************************************************************************
// ModuleGenerator
// **************************************************************************

abstract class _$Counter extends Module {
  @visibleForOverriding
  set val(Logic val);

  @protected
  Logic get en => input('en');

  /// The [inputSource] for the [en] port.
  Logic get enSource => inputSource('en');

  @protected
  Logic get reset => input('reset');

  /// The [inputSource] for the [reset] port.
  Logic get resetSource => inputSource('reset');

  @protected
  Logic get clk => input('clk');

  /// The [inputSource] for the [clk] port.
  Logic get clkSource => inputSource('clk');

  _$Counter(
    Logic en,
    Logic reset,
    Logic clk, {
    int? clkWidth,
    super.definitionName,
    int? enWidth,
    super.name = 'Counter_inst',
    super.reserveDefinitionName,
    super.reserveName,
    int? resetWidth,
    int valWidth = 1,
  }) : super() {
    val = addOutput('val', width: valWidth);

    addInput('en', en, width: enWidth ?? en.width);

    addInput('reset', reset, width: resetWidth ?? reset.width);

    addInput('clk', clk, width: clkWidth ?? clk.width);
  }
}
