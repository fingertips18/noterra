import 'package:flutter/material.dart'
    show
        AppBar,
        BuildContext,
        ButtonStyle,
        Center,
        CircularProgressIndicator,
        Colors,
        Column,
        Size,
        EdgeInsets,
        ElevatedButton,
        FontWeight,
        IconButton,
        Icon,
        Icons,
        MainAxisAlignment,
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
import 'screens/email/emails.dart' show EmailsScreen;
import 'screens/template/templates.dart' show TemplatesPage;

class App extends StatefulWidget {
  final String title;

  const App({super.key, required this.title});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final OAuthController _oAuthController;

  @override
  void initState() {
    super.initState();

    _oAuthController = OAuthController(context: context);
    _oAuthController.init();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _oAuthController.isSignedIn,
      builder: (context, isSignedIn, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: isSignedIn
                ? [
                    IconButton(
                      onPressed: () async {
                        await _oAuthController.signOut();
                      },
                      icon: const Icon(Icons.logout),
                    ),
                  ]
                : null,
          ),
          body: isSignedIn ? child : _signInButton(),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => EmailsScreen(oAuthController: _oAuthController)));
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
              ),
              child: const Text('Emails', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInButton() {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: _oAuthController.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) return const CircularProgressIndicator();

          return ElevatedButton.icon(
            icon: SvgPicture.asset(Assets.google, height: 24, width: 24),
            label: const Text("Sign in with Google"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(200, 50)),
            onPressed: isLoading ? null : _oAuthController.signIn,
          );
        },
      ),
    );
  }
}
