import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'composed_generator.dart';
import 'generate_annotation.dart';
import 'match_annotation.dart';

mixin AnnotationsGenerator on ComposedGenerator {
  Iterable<GenerateOnAnnotationAnywhere> get generators;

  Iterable<FutureOr<GenerateComponentResult>> generateOnElement(
    Element2 element,
    BuildStep buildStep,
  ) sync* {
    if (element case final Annotatable annotatableElement) {
      for (final generator in generators) {
        if (annotatableElement.firstAnnotation(generator.annotationType)
            case final ElementAnnotation annotation) {
          yield generator.generate(
            element,
            ConstantReader(annotation.computeConstantValue()),
            buildStep,
          );
        }
      }
    }
  }
}

/// Generate only on the top layer, to avoid unnecessary recursive generation.
abstract class TopAnnotationGenerator extends ComposedGenerator
    with AnnotationsGenerator {
  const TopAnnotationGenerator();

  @override
  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) sync* {
    for (final element in library.element.children2) {
      yield* generateOnElement(element, buildStep);
    }
  }
}

/// Generator on annotations of the top-two layers.
/// Because the constructor and methods are usually at the second layer.
abstract class Top2AnnotationGenerator extends ComposedGenerator
    with AnnotationsGenerator {
  const Top2AnnotationGenerator();

  @override
  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) sync* {
    for (final element in library.element.children2) {
      yield* generateOnElement(element, buildStep);
      for (final nestedElement in element.children2) {
        yield* generateOnElement(nestedElement, buildStep);
      }
    }
  }
}

abstract class RecursiveAnnotationGenerator extends ComposedGenerator
    with AnnotationsGenerator {
  const RecursiveAnnotationGenerator();

  @override
  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) => generateSingleLayer(library.element, buildStep);

  Iterable<FutureOr<GenerateComponentResult>> generateSingleLayer(
    Element2 element,
    BuildStep buildStep,
  ) sync* {
    yield* generateOnElement(element, buildStep);
    for (final nestedElement in element.children2) {
      yield* generateSingleLayer(nestedElement, buildStep);
    }
  }
}
