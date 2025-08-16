import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

abstract class ComposedGenerator extends Generator {
  const ComposedGenerator();

  @override
  Future<String?> generate(LibraryReader library, BuildStep buildStep) async {
    final componentsResults =
        Stream. //
            fromIterable(generateComponents(library, buildStep))
            .asyncExpand((result) => Stream.fromFuture(Future.value(result)));

    final directives = <String>{};
    final contents = <String>[];
    await for (final item in componentsResults) {
      directives.addAll(item.directives);
      if (item.content.isNotEmpty) contents.add(item.content);
    }

    if (directives.isEmpty && contents.isEmpty) return null;
    final sorted = directives.toList()..sort((a, b) => a.compareTo(b));
    return '${sorted.join('\n')}\n\n${contents.join('\n\n')}\n';
  }

  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  );
}

mixin PartGenerator on ComposedGenerator {
  @override
  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  ) sync* {
    final components = super.generateComponents(library, buildStep);
    yield* components;
    if (components.isNotEmpty) {
      yield GenerateComponentResult.directives({
        "part of '${buildStep.inputId.pathSegments.last}';",
      });
    }
  }
}

class GenerateComponentResult {
  const GenerateComponentResult({
    this.directives = const {},
    this.content = '',
  });

  const GenerateComponentResult.content(
    this.content, {
    this.directives = const {},
  });

  const GenerateComponentResult.directives(
    this.directives, {
    this.content = '',
  });

  final Set<String> directives;
  final String content;

  bool get isEmpty => directives.isEmpty && content.isEmpty;
  bool get isNotEmpty => !isEmpty;

  GenerateComponentResult operator +(GenerateComponentResult other) {
    return GenerateComponentResult(
      directives: {...directives, ...other.directives},
      content: content + other.content,
    );
  }
}

extension JoinGenerateComponentResult on Iterable<GenerateComponentResult> {
  GenerateComponentResult joinAsComponent([String separator = '\n\n']) {
    final content = <String>[];
    final directives = <String>{};
    for (final item in this) {
      if (item.content.isNotEmpty) content.add(item.content);
      directives.addAll(item.directives);
    }
    return GenerateComponentResult(
      directives: directives,
      content: content.join(separator),
    );
  }
}
