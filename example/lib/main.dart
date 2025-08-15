import 'package:flutter/widgets.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQueryData.fromView(View.of(context)),
    child: const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('placeholder')),
    ),
  );
}
