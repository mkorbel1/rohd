import 'package:build/build.dart';
import 'package:rohd/src/builders/interface_generator.dart';
import 'package:rohd/src/builders/logic_structure_generator.dart';
import 'package:rohd/src/builders/module_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder rohdBuilder(BuilderOptions options) => SharedPartBuilder([
      ModuleGenerator(),
      InterfaceGenerator(),
      LogicStructureGenerator(),
    ], 'rohd_builder');
