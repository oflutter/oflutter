import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

part 'src/annotation/annotate_name.dart';
part 'src/annotation/annotate_type.dart';
part 'src/annotation/type_identifier.dart';

final _$lib = Uri(scheme: 'package', path: 'oflutter_name/annotation.dart');

class GenerateNameBase {
  const GenerateNameBase({required this.prefix});

  final String prefix;

  static const $prefix = 'prefix';
}
