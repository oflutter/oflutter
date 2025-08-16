part of 'package:oflutter_name/annotation.dart';

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
