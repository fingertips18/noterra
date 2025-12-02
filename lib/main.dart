import 'package:flutter/material.dart' show BuildContext, Colors, MaterialApp, StatelessWidget, ThemeData, Widget, WidgetsFlutterBinding, runApp;
import 'app.dart' show App;
import 'constants/string.dart' show StringConstants;
import 'package:hive_flutter/hive_flutter.dart' show Hive, HiveX;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialized Hive for Flutter
  await Hive.initFlutter();

  // Open the Hive box to store items
  await Hive.openBox(StringConstants.templateBox);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noterra',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blueAccent), useMaterial3: true),
      home: const App(title: "Noterra"),
    );
  }
}
