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

mixin GenerateAnnotatedConstructor on GenerateOnAnnotation {
  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element is ConstructorElement2
      ? generateConstructor(element, annotation, buildStep)
      : super.generate(element, annotation, buildStep);

  FutureOr<GenerateComponentResult> generateConstructor(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}

mixin GenerateAnnotatedClass on GenerateOnAnnotation {
  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element is ClassElement2
      ? generateClass(element, annotation, buildStep)
      : super.generate(element, annotation, buildStep);

  FutureOr<GenerateComponentResult> generateClass(
    ClassElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}

mixin GenerateAnnotatedGetter on GenerateOnAnnotation {
  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element is GetterElement
      ? generateGetter(element, annotation, buildStep)
      : super.generate(element, annotation, buildStep);

  FutureOr<GenerateComponentResult> generateGetter(
    GetterElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}

mixin GenerateAnnotatedTopLevelVariable on GenerateOnAnnotation {
  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element is TopLevelVariableElement2
      ? generateTopLevelVariable(element, annotation, buildStep)
      : super.generate(element, annotation, buildStep);

  FutureOr<GenerateComponentResult> generateTopLevelVariable(
    TopLevelVariableElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );
}
