import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:oflutter_name/annotation.dart';
import 'package:oflutter_name/compat.dart';
import 'package:oflutter_name/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder nameBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateNameLibrary(),
  generatedExtension: '.name.g.dart',
);

class GenerateNameLibrary extends RecursiveAnnotationGenerator
    with PartGenerator {
  const GenerateNameLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const NameGenerator(),
  ];
}

class NameGenerator extends GenerateOnAnnotationAnywhere {
  const NameGenerator();

  @override
  TypeIdentifier get annotationType => GenerateName.$type;

  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final prefix =
        annotation.peek(GenerateNameBase.$prefix)?.stringValue ??
        const GenerateName().prefix;

    final varName = '$prefix${element.displayName.camelCase}';
    final result = element.name3 ?? '';
    return GenerateComponentResult.content("const $varName = '$result';");
  }
}
