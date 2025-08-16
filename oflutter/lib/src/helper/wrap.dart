import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:oflutter/annotation.dart';

part 'wrap.name.g.dart';
part 'wrap.wrap.g.dart';

@name
extension WrapEnvironment on Widget {
  static const String $$name = _$name$wrapEnvironment;

  MediaQuery media(MediaQueryData data, {Key? key}) {
    return MediaQuery(key: key, data: data, child: this);
  }

  MediaQuery mediaAsView(BuildContext context, {Key? key}) {
    return media(key: key, MediaQueryData.fromView(View.of(context)));
  }

  Directionality textDirection(TextDirection direction, {Key? key}) {
    return Directionality(key: key, textDirection: direction, child: this);
  }
}

@name
class EnsureText extends StatelessWidget {
  @wrap
  const EnsureText({
    super.key,
    this.defaultDirection = TextDirection.ltr,
    required this.child,
  });

  static const String $$name = _$name$ensureText;

  final TextDirection defaultDirection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var temp = child;
    if (MediaQuery.maybeOf(context) == null) temp = child.mediaAsView(context);
    if (Directionality.maybeOf(context) == null) {
      temp = temp.textDirection(defaultDirection);
    }
    return temp;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final d = defaultDirection;
    properties.add(EnumProperty<TextDirection>('defaultDirection', d));
  }
}
