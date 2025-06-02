---
title: "ROHD Code Generation"
permalink: /docs/rohd-code-gen/
last_modified_at: 2025-6-2
toc: true
---

ROHD has no software reflection, which creates a clean decoupling between generated hardware objects and the source code that generates them.  However, there are cases where describing "simple" hardware in ROHD can result in repetitive code patterns. To help address these scenarios, ROHD has an annotation-based Dart code generator built on top of standard Dart code generation infrastructure.  This document describes these capabilities and shows some examples of how to use them.

## GenModule

