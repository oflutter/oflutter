import 'package:analyzer/dart/element/type.dart';
import 'package:oflutter_name/annotation.dart';

extension ParseType on DartType {
  TypeIdentifier get typeIdentifier {
    final lib = element3?.library2?.uri;
    if (lib == null) throw Exception('cannot parse lib for $this');
    return TypeIdentifier(name: toString(), lib: lib);
  }
}
