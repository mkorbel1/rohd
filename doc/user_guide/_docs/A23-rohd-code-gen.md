---
title: "ROHD Code Generation"
permalink: /docs/rohd-code-gen/
last_modified_at: 2025-6-2
toc: true
---

ROHD has no software reflection, which creates a clean decoupling between generated hardware objects and the source code that generates them.  However, there are cases where describing "simple" hardware in ROHD can result in repetitive code patterns. To help address these scenarios, ROHD has an annotation-based Dart code generator built on top of standard Dart code generation infrastructure.  This document describes these capabilities and shows some examples of how to use them.

## Setting Up

Make sure you have all the dependencies added to your `pubspec.yaml`:

```shell
# you need ROHD
dart pub add rohd

# for actually running the code generator
dart pub add dev:build_runner

# generated code may use the meta package
dart pub add meta
```

It's important to always include the `part` directive at the top of your files that use code generation.  For example:

```dart
// mymod.dart

// necessary imports for annotations, etc.
import 'package:rohd/builder.dart';
import 'package:rohd/rohd.dart';
import 'package:meta/meta.dart';

// necessary `part` directive for the generated file
part 'mymod.g.dart';
```

Now, to run the code generator, it's recommended to set the code generator up to watch changes to your code.  Code generation will automatically re-run as you modify your code.

```shell
dart run build_runner watch -d
```

You can set up a Visual Studio Task in your `.vscode/tasks.json` in your repository that can run `build_runner watch` in the background (see below).  To launch, run `Run Task` from the command pallette.

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build_runner watch",
      "type": "shell",
      "command": "dart run build_runner watch -d",
      "problemMatcher": [],
      "isBackground": true
    }
  ]
}
```

Alternatively, you could run the code generation on-demand whenever you like.  The generated code will only update each time you run this command.

```shell
dart run build_runner build
```

## GenModule

