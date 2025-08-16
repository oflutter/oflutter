part of 'package:oflutter_name/annotation.dart';

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
