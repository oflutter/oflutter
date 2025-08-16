import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'composed_generator.dart';
import 'generate_annotation.dart';

mixin GenerateConstructor on GenerateOnAnnotation {
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

mixin GenerateClass on GenerateOnAnnotation {
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

mixin GenerateGetter on GenerateOnAnnotation {
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

mixin GenerateTopLevelVariable on GenerateOnAnnotation {
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

mixin GenerateVariableEntries on GenerateConstructor, GenerateTopLevelVariable {
  @override
  FutureOr<GenerateComponentResult> generateTopLevelVariable(
    TopLevelVariableElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final value = element.computeConstantValue();
    if (value?.toFunctionValue2()?.baseElement
        case final ConstructorElement2 element) {
      return generateConstructor(element, annotation, buildStep);
    } else if (value?.toSetValue() case final Set<DartObject> items) {
      final tasks = items
          .map((item) => item.toFunctionValue2())
          .whereType<ConstructorElement2>()
          .map((e) => generateConstructor(e, annotation, buildStep))
          .map(Future.value);
      return (await Future.wait(tasks)).joinAsComponent();
    }
    throw Exception('returned value not constructor or set: $element');
  }
}

mixin GenerateStreamConstructor on GenerateConstructor {
  @override
  FutureOr<GenerateComponentResult> generateConstructor(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final eName = await generateExtensionName(element, annotation, buildStep);
    final mName = await generateMethodName(element, annotation, buildStep);
    final target = await generateTarget(element, annotation, buildStep);
    final inputs = await generateInputs(element, annotation, buildStep);
    final outputs = await generateOutputs(element, annotation, buildStep);
    final className = element.enclosingElement2.name3;

    return GenerateComponentResult(
      directives: {
        ...eName.directives,
        ...mName.directives,
        ...target.directives,
        ...inputs.directives,
        ...outputs.directives,
      },
      content:
          'extension ${eName.content} on ${target.content} {\n'
          '  $className ${mName.content}(${inputs.content}) {\n'
          '    return ${element.displayName}(${outputs.content});\n'
          '  }\n'
          '}',
    );
  }

  FutureOr<GenerateComponentResult> generateExtensionName(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  FutureOr<GenerateComponentResult> generateMethodName(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  FutureOr<GenerateComponentResult> generateTarget(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  );

  FutureOr<GenerateComponentResult> generateInputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final directives = <String>{};
    final namedItems = <String>[];
    final unnamedItems = <String>[];
    final inputParams = await filterInputs(element, annotation, buildStep);
    final results = inputParams.map((p) => Future.value(generateInput(p)));
    for (final (result, named) in await Future.wait(results)) {
      directives.addAll(result.directives);
      named ? namedItems.add(result.content) : unnamedItems.add(result.content);
    }

    final unnamed = unnamedItems.isEmpty ? '' : '${unnamedItems.join(', ')}, ';
    final named = namedItems.isEmpty ? '' : '{${namedItems.join(', ')}}';
    return GenerateComponentResult(
      directives: directives,
      content: '$unnamed$named',
    );
  }

  FutureOr<GenerateComponentResult> generateOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final outputParams = await filterOutputs(element, annotation, buildStep);
    final results = outputParams.map((p) => Future.value(generateOutput(p)));
    return (await Future.wait(results)).joinAsComponent(',');
  }

  FutureOr<Iterable<FormalParameterElement>> filterInputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element.formalParameters;

  FutureOr<Iterable<FormalParameterElement>> filterOutputs(
    ConstructorElement2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) => element.formalParameters;

  /// The bool value means whether named.
  FutureOr<(GenerateComponentResult, bool)> generateInput(
    FormalParameterElement element,
  );

  FutureOr<GenerateComponentResult> generateOutput(
    FormalParameterElement element,
  );
}
