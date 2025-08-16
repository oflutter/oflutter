import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
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

Builder typeBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateTypeLibrary(),
  generatedExtension: '.type.g.dart',
);

Builder buildInTypeBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateBuildInTypeLibrary(),
  generatedExtension: r'.$type.g.dart',
);

class GenerateNameLibrary extends RecursiveAnnotationGenerator
    with PartGenerator {
  const GenerateNameLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const NameGenerator(),
  ];
}

class GenerateTypeLibrary extends TopAnnotationGenerator with PartGenerator {
  const GenerateTypeLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const LibGenerator(),
    const TypeGenerator(),
  ];
}

class GenerateBuildInTypeLibrary extends TopAnnotationGenerator {
  const GenerateBuildInTypeLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const BuildInTypeGenerator(),
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

FutureOr<GenerateComponentResult> _generateType(
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
  ) => _generateType(element, annotation, buildStep);

  @override
  FutureOr<GenerateComponentResult> generateGetter(
    GetterElement element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final type = element.returnType.element3;
    if (type == null) throw Exception('cannot get return type of $element');
    return _generateType(type, annotation, buildStep);
  }
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
      return _generateType(element, annotation, buildStep);
    } else if (value?.toSetValue() case final Set<DartObject> items) {
      final tasks = items
          .map((item) => item.toTypeValue()?.element3)
          .whereType<Element2>()
          .map((e) => Future.value(_generateType(e, annotation, buildStep)));
      return (await Future.wait(tasks)).joinAsComponent();
    }
    throw Exception('not type or set: $element');
  }
}
