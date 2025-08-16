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
    const LibGenerator(),
    const TypeGenerator(),
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

class LibGenerator extends GenerateOnAnnotationAnywhere {
  const LibGenerator();

  @override
  TypeIdentifier get annotationType => GenerateLib.$type;

  @override
  FutureOr<GenerateComponentResult> generate(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final prefix =
        annotation.peek(GenerateNameBase.$prefix)?.stringValue ??
        const GenerateLib().prefix;

    final varName = '$prefix${element.displayName.camelCase}';
    final uri = element.library2?.uri;
    if (uri == null) throw Exception('cannot parse uri of $element');

    final expression = "Uri(scheme: '${uri.scheme}', path: '${uri.path}')";
    return GenerateComponentResult.content('final $varName = $expression;');
  }
}

class TypeGenerator extends GenerateOnAnnotation
    with GenerateClass, GenerateGetter {
  const TypeGenerator();

  @override
  TypeIdentifier get annotationType => GenerateType.$type;

  @override
  FutureOr<GenerateComponentResult> generateClass(
    ClassElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => generateType(element, annotation, buildStep);

  @override
  FutureOr<GenerateComponentResult> generateGetter(
    GetterElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final type = element.returnType.element3;
    if (type == null) throw Exception('cannot get return type of $element');
    return generateType(type, annotation, buildStep);
  }

  FutureOr<GenerateComponentResult> generateType(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final prefix =
        annotation.peek(GenerateNameBase.$prefix)?.stringValue ??
        const GenerateLib().prefix;

    final varName = '$prefix${element.displayName.camelCase}';
    final uri = element.library2?.uri;
    if (uri == null) throw Exception('cannot parse uri of $element');

    final expression =
        '${TypeIdentifier.$type.name}('
        "  ${TypeIdentifier.$name}: '${element.name3 ?? ''}', "
        '  ${TypeIdentifier.$lib}: Uri('
        "    scheme: '${uri.scheme}', "
        "    path: '${uri.path}', "
        '  ), '
        ')';
    return GenerateComponentResult.content('final $varName = $expression;');
  }
}
