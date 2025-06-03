import 'package:build/build.dart';
import 'package:rohd/src/builders/interface_builder.dart';
import 'package:rohd/src/builders/logic_structure_builder.dart';
import 'package:rohd/src/builders/module_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder rohdBuilder(BuilderOptions options) => SharedPartBuilder([
      ModuleGenerator(),
      InterfaceGenerator(),
      LogicStructureGenerator(),
    ], 'rohd_builder');
