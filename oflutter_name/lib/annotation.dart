import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

final _$lib = Uri(scheme: 'package', path: 'oflutter_name/annotation.dart');

class GenerateNameBase {
  const GenerateNameBase({required this.prefix});

  final String prefix;

  static const $prefix = 'prefix';
}

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

const name = GenerateName();
const lib = GenerateLib();

class GenerateName extends GenerateNameBase {
  const GenerateName({super.prefix = r'_$name$'});

  static final $type = TypeIdentifier(name: '$GenerateName', lib: _$lib);
}

class GenerateLib extends GenerateNameBase {
  const GenerateLib({super.prefix = r'_$lib$'});

  static final $type = TypeIdentifier(name: '$GenerateLib', lib: _$lib);
}

const type = GenerateType();
const typeBuildIn = GenerateBuildInType();

@Target({TargetKind.classType, TargetKind.topLevelVariable})
class GenerateType extends GenerateNameBase {
  const GenerateType({super.prefix = r'_$type$'});

  static final $type = TypeIdentifier(name: 'GenerateType', lib: _$lib);
}

@Target({TargetKind.topLevelVariable})
class GenerateBuildInType extends GenerateNameBase {
  const GenerateBuildInType({super.prefix = r'$type$'});

  static final $type = TypeIdentifier(name: 'GenerateBuildInType', lib: _$lib);
}
