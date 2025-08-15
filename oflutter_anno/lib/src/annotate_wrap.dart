import 'package:oflutter_name/annotation.dart';

part 'annotate_wrap.name.g.dart';

const wrap = GenerateWrap();

@type
class GenerateWrap {
  const GenerateWrap({this.extensionName, this.methodName});

  @name
  final String? extensionName;

  @name
  final String? methodName;

  static final TypeIdentifier $type = _$type$generateWrap;
  static const String $extensionName = _$name$extensionName;
  static const String $methodName = _$name$methodName;
}
