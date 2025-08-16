import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:oflutter_name/annotation.dart';
import 'package:oflutter_name/generator.dart';
import 'package:source_gen/source_gen.dart';

import 'build_type.dart';

Builder buildInTypeBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateBuildInTypeLibrary(),
  generatedExtension: r'.$type.g.dart',
);

class GenerateBuildInTypeLibrary extends TopAnnotationGenerator {
  const GenerateBuildInTypeLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const BuildInTypeGenerator(),
  ];
}

class BuildInTypeGenerator extends GenerateOnAnnotation
    with GenerateTopLevelVariable {
  const BuildInTypeGenerator();

  @override
  TypeIdentifier get annotationType => GenerateBuildInType.$type;

  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final result = await super.generate(element, annotation, buildStep);
    return result.appendDirective(TypeIdentifier.$type.importExpression);
  }

  @override
  FutureOr<GenerateComponentResult> generateTopLevelVariable(
    TopLevelVariableElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final value = element.computeConstantValue();
    if (value?.toTypeValue()?.element3 case final Element2 element) {
      return generateType(element, annotation, buildStep);
    } else if (value?.toSetValue() case final Set<DartObject> items) {
      final tasks = items
          .map((item) => item.toTypeValue()?.element3)
          .whereType<Element2>()
          .map((e) => Future.value(generateType(e, annotation, buildStep)));
      return (await Future.wait(tasks)).joinAsComponent();
    }
    throw Exception('not type or set: $element');
  }
}
