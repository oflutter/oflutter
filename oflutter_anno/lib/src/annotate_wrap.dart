import 'package:oflutter_name/annotation.dart';

part 'annotate_wrap.name.g.dart';

const wrap = GenerateWrap();

@type
class GenerateWrap {
  const GenerateWrap({
    this.extensionName,
    this.methodName,
    this.methodNamePrefix,
    this.targetParameterName = 'child',
  });

  @name
  final String? extensionName;

  @name
  final String? methodName;

  @name
  final String? methodNamePrefix;

  @name
  final String targetParameterName;

  static final TypeIdentifier $type = _$type$generateWrap;
  static const String $extensionName = _$name$extensionName;
  static const String $methodName = _$name$methodName;
  static const String $methodNamePrefix = _$name$methodNamePrefix;
  static const String $targetParameterName = _$name$targetParameterName;
}
