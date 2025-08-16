import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oflutter/helper.dart';

void main() {
  testWidgets('${WrapEnvironment.$$name}: ensure text', (t) async {
    const message = 'message';
    final probe = Builder(
      builder: (context) {
        return message
            .asText()
            .center()
            .textDirection(TextDirection.ltr)
            .mediaAsView(context);
      },
    );
    await t.pumpWidget(probe);
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('${EnsureText.$$name}: validate', (t) async {
    const message = 'message';
    await t.pumpWidget(message.asText().ensureText());
    expect(find.text(message), findsOneWidget);
  });
}
