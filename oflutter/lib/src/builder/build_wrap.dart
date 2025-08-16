import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
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

class GenerateWrapLibrary extends Top2AnnotationGenerator {
  const GenerateWrapLibrary();

  @override
  Iterable<GenerateOnAnnotationAnywhere> get generators => [
    const WrapGenerator(),
  ];
}

class WrapGenerator extends GenerateOnAnnotation
    with
        GenerateConstructor,
        GenerateStreamConstructor,
        GenerateTopLevelVariable {
  const WrapGenerator();

  @override
  TypeIdentifier get annotationType => GenerateWrap.$type;

  String targetName(ConstantReader annotation) {
    return annotation.peek(GenerateWrap.$targetParameterName)?.stringValue ??
        const GenerateWrap().targetParameterName;
  }

  @override
  FutureOr<GenerateComponentResult> generateTopLevelVariable(
    TopLevelVariableElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    switch (element.constantInitializer) {
      case final ConstructorReference _:
        if (element.computeConstantValue()?.toFunctionValue2()?.baseElement
            case final ConstructorElement2 element) {
          return generateConstructor(element, annotation, buildStep);
        }
        throw Exception('returned value not a constructor: $element');
    }
    return const GenerateComponentResult.content('// top level variable');
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
  ) {
    // todo: parse.
    return const GenerateComponentResult(
      directives: {"import 'package:flutter/widgets.dart';"},
      content: 'Widget',
    );
  }

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
    final targetName = this.targetName(annotation);
    return element.formalParameters.where((param) => param.name3 != targetName);
  }

  @override
  FutureOr<Iterable<FormalParameterElement>> filterOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final targetName = this.targetName(annotation);
    return element.formalParameters.where((param) => param.name3 != targetName);
  }

  @override
  FutureOr<GenerateComponentResult> generateOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final targetName = this.targetName(annotation);
    final result = await super.generateOutputs(element, annotation, buildStep);
    final prefix = result.content.isEmpty ? '' : ', ';
    return result + GenerateComponentResult.content('$prefix$targetName: this');
  }

  @override
  FutureOr<(GenerateComponentResult, bool)> generateInput(
    FormalParameterElement element,
  ) {
    // todo: resolve types.
    final content = element.toString().unwrapCurlyBrace;
    return (GenerateComponentResult(content: content), element.isNamed);
  }

  @override
  FutureOr<GenerateComponentResult> generateOutput(
    FormalParameterElement element,
  ) => GenerateComponentResult.content('${element.name3}: ${element.name3}');
}
