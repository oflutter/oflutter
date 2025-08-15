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
      if (item.content != null) contents.add(item.content!);
    }

    if (directives.isEmpty && contents.isEmpty) return null;
    final sorted = directives.toList()..sort((a, b) => a.compareTo(b));
    return '${sorted.join('\n')}\n\n${contents.join('\n\n')}';
  }

  Iterable<FutureOr<GenerateComponentResult>> generateComponents(
    LibraryReader library,
    BuildStep buildStep,
  );
}

class GenerateComponentResult {
  const GenerateComponentResult({this.directives = const [], this.content});

  final Iterable<String> directives;
  final String? content;

  bool get isEmpty => directives.isEmpty && content == null;
  bool get isNotEmpty => !isEmpty;
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
      yield GenerateComponentResult(
        directives: ["part of '${buildStep.inputId.pathSegments.last}';"],
      );
    }
  }
}
