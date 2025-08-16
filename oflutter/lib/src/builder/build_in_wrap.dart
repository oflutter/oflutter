import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:oflutter/annotation.dart';
import 'package:oflutter/compat.dart';
import 'package:oflutter/generator.dart';
import 'package:source_gen/source_gen.dart';

import 'build_wrap.dart';

Builder buildInWrapBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateBuildInWrapLibrary(),
  generatedExtension: r'.$wrap.g.dart',
);

class GenerateBuildInWrapLibrary extends TopAnnotationGenerator {
  const GenerateBuildInWrapLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const BuildInWrapGenerator(),
  ];
}

class BuildInWrapGenerator extends WrapGenerator
    with GenerateTopLevelVariable, GenerateVariableConstructorEntries {
  const BuildInWrapGenerator();

  @override
  TypeIdentifier get annotationType => GenerateBuildInWrap.$type;

  @override
  FutureOr<GenerateComponentResult> generateConstructor(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final result = super.generateConstructor(element, annotation, buildStep);
    final type = element.returnType.typeIdentifier;
    const ignoreLints =
        '// '
        'ignore_for_file: unnecessary_import, '
        'implementation_imports '
        'generated.\n';

    return (await result).appendDirectives({
      ignoreLints,
      if (!type.isDartCore) type.importExpression,
    });
  }

  @override
  FutureOr<GenerateComponentResult> generateTarget(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final type = targetParameter(
      element,
      annotation,
      buildStep,
    ).type.typeIdentifier;

    return GenerateComponentResult(
      directives: {if (!type.isDartCore) type.importExpression},
      content: type.name,
    );
  }

  @override
  FutureOr<(GenerateComponentResult, bool)> generateInput(
    FormalParameterElement element,
  ) {
    final type = element.type.typeIdentifier;
    final content = element.toString().unwrapCurlyBrace;
    return (
      GenerateComponentResult(
        directives: {if (!type.isDartCore) type.importExpression},
        content: content,
      ),
      element.isNamed,
    );
  }
}
