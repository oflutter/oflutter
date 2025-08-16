import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:oflutter/annotation.dart';
import 'package:oflutter/compat.dart';
import 'package:oflutter/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder wrapBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateWrapLibrary(),
  generatedExtension: '.wrap.g.dart',
);

Builder buildInWrapBuilder(BuilderOptions options) => LibraryBuilder(
  const GenerateBuildInWrapLibrary(),
  generatedExtension: r'.$wrap.g.dart',
);

class GenerateWrapLibrary extends Top2AnnotationGenerator {
  const GenerateWrapLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const WrapGenerator(),
  ];
}

class GenerateBuildInWrapLibrary extends TopAnnotationGenerator {
  const GenerateBuildInWrapLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const BuildInWrapGenerator(),
  ];
}

class WrapGenerator extends GenerateOnAnnotation
    with GenerateConstructor, GenerateStreamConstructor {
  const WrapGenerator();

  @override
  TypeIdentifier get annotationType => GenerateWrap.$type;

  String $targetName(ConstantReader annotation) {
    return annotation.peek(GenerateWrap.$targetParameterName)?.stringValue ??
        const GenerateWrap().targetParameterName;
  }

  bool $removeDeprecated(ConstantReader annotation) {
    return annotation.peek(GenerateWrap.$removeDeprecated)?.boolValue ??
        const GenerateWrap().removeDeprecated;
  }

  FormalParameterElement targetParameter(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final targetName = $targetName(annotation);
    return element.formalParameters.firstWhere(
      (param) => param.name3 == targetName,
      orElse: () => throw Exception('no target $targetName on $element'),
    );
  }

  @override
  FutureOr<GenerateComponentResult> generateExtensionName(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => GenerateComponentResult.content(
    annotation.peek(GenerateWrap.$extensionName)?.stringValue ??
        '\$Wrap\$${element.displayName.pascalCase}',
  );

  @override
  FutureOr<GenerateComponentResult> generateTarget(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => GenerateComponentResult.content(
    targetParameter(element, annotation, buildStep).type.toString(),
  );

  @override
  FutureOr<GenerateComponentResult> generateMethodName(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => GenerateComponentResult.content(
    annotation.peek(GenerateWrap.$methodName)?.stringValue ??
        '${annotation.peek(GenerateWrap.$methodNamePrefix) ?? ''}'
            '${element.displayName.camelCase}',
  );

  @override
  FutureOr<Iterable<FormalParameterElement>> filterInputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final targetName = $targetName(annotation);
    final result = element.formalParameters.where((p) => p.name3 != targetName);
    if (!$removeDeprecated(annotation)) return result;

    final classE = element.enclosingElement2 as ClassElement2;
    return result.where((param) {
      if (!param.isInitializingFormal) return true;
      if (classE.getField2(param.name3!) case final FieldElement2 field) {
        return field.firstAnnotation($type$deprecated) == null;
      }
      return true;
    });
  }

  @override
  FutureOr<Iterable<FormalParameterElement>> filterOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => filterInputs(element, annotation, buildStep);

  @override
  FutureOr<GenerateComponentResult> generateOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final targetName = $targetName(annotation);
    final isTargetNamed = element.formalParameters
        .firstWhere((p) => p.name3 == targetName)
        .isNamed;

    final result = await super.generateOutputs(element, annotation, buildStep);
    final prefix = result.content.isEmpty ? '' : ', ';
    final target = '${isTargetNamed ? '$targetName: ' : ''}this';
    return result + GenerateComponentResult.content('$prefix$target');
  }

  @override
  FutureOr<(GenerateComponentResult, bool)> generateInput(
    FormalParameterElement element,
  ) {
    final content = element.toString().unwrapCurlyBrace;
    return (GenerateComponentResult(content: content), element.isNamed);
  }

  @override
  FutureOr<GenerateComponentResult> generateOutput(
    FormalParameterElement element,
  ) => GenerateComponentResult.content('${element.name3}: ${element.name3}');
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
