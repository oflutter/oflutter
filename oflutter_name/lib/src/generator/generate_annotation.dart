import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';
import 'package:oflutter_name/annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'composed_generator.dart';

abstract class GenerateOnAnnotationAnywhere {
  const GenerateOnAnnotationAnywhere();

  TypeIdentifier get annotationType;

  @mustCallSuper
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}

abstract class GenerateOnAnnotation extends GenerateOnAnnotationAnywhere {
  const GenerateOnAnnotation();

  @override
  @mustCallSuper
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => throw InvalidAnnotationPosition(annotationType, element.kind);
}

class InvalidAnnotationPosition implements Exception {
  const InvalidAnnotationPosition(this.type, this.kind);

  final TypeIdentifier type;
  final ElementKind kind;

  @override
  String toString() => 'cannot annotate $type on $kind';
}
