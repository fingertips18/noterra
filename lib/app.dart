import 'dart:ui';

import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        ButtonStyle,
        Center,
        Colors,
        Column,
        EdgeInsets,
        ElevatedButton,
        FontWeight,
        MaterialPageRoute,
        Navigator,
        Scaffold,
        State,
        StatefulWidget,
        Text,
        TextButton,
        TextStyle,
        ValueListenableBuilder,
        Widget,
        WidgetStateProperty;
import 'package:flutter_svg/svg.dart' show SvgPicture;
import 'constants/assets.dart' show Assets;
import 'controller/oauth.dart' show OAuthController;
import 'screens/generate.dart' show GeneratePage;
import 'screens/template/templates.dart' show TemplatesPage;

class App extends StatefulWidget {
  final String title;

  const App({super.key, required this.title});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late OAuthController _oAuthController;

  @override
  void initState() {
    super.initState();

    _oAuthController = OAuthController(context: context, action: _refresh);
    _oAuthController.init();
  }

  // Called after sign-in
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _oAuthController.isSignedIn,
        builder: (context, isSignedIn, _) {
          if (!isSignedIn) {
            return Center(
              child: ElevatedButton.icon(
                icon: SvgPicture.asset(Assets.google, height: 24, width: 24),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
                onPressed: () => _oAuthController.signIn(),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: .center,
              spacing: 20,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const TemplatesPage()));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                  ),
                  child: const Text('Templates', style: TextStyle(fontSize: 18)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GeneratePage()));
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                  ),
                  child: const Text('Generate Daily Report', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
