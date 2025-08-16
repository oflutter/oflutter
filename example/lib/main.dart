import 'package:flutter/widgets.dart';
import 'package:oflutter/helper.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => 'placeholder'
      .asText()
      .center()
      .textDirection(TextDirection.ltr)
      .mediaAsView(context);
}
