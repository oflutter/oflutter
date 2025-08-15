import 'package:analyzer/dart/element/element2.dart';
import 'package:oflutter_name/annotation.dart';

extension ResolveAnnotationType on ElementAnnotation {
  Element2? get annotationType {
    switch (element2) {
      case final GetterElement element:
        return element.returnType.element3;
      case final ConstructorElement2 element:
        return element.returnType.element3;
    }
    return null;
  }
}

extension MatchAnnotation on Annotatable {
  ElementAnnotation? firstAnnotation(TypeIdentifier type) {
    for (final annotation in metadata2.annotations) {
      if (annotation.annotationType case final Element2 element) {
        if (element.name3 != type.name) continue;
        if (element.library2?.uri != type.lib) continue;
        return annotation;
      }
    }
    return null;
  }
}
