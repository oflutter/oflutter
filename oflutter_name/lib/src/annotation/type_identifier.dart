part of 'package:oflutter_name/annotation.dart';

@immutable
class TypeIdentifier {
  const TypeIdentifier({required this.name, required this.lib});

  final String name;
  final Uri lib;

  static const $name = 'name';
  static const $lib = 'lib';
  static final $type = TypeIdentifier(name: 'TypeIdentifier', lib: _$lib);

  String get importExpression => "import '$lib';";
  String get exportExpression => "export '$lib' show $name;";

  bool get isDartCore =>
      lib.scheme == 'dart' && lib.pathSegments.firstOrNull == 'core';

  @override
  bool operator ==(Object other) {
    return other is TypeIdentifier && other.name == name && other.lib == lib;
  }

  @override
  int get hashCode => Object.hash(name, lib);

  @override
  String toString() => '$name($lib)';
}
