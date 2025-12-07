import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noterra/constants/status.dart';
import 'package:noterra/env/env.dart';
import 'package:noterra/widgets/toast.dart';

class OAuthController {
  final BuildContext context;
  final VoidCallback? action;

  OAuthController({required this.context, this.action});

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final ValueNotifier<bool> isSignedIn = ValueNotifier(false);

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> init() async {
    await _googleSignIn.initialize(clientId: Env.iosClientID);
  }

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.authenticate(scopeHint: ['https://www.googleapis.com/auth/gmail.readonly']);
      if (_currentUser == null) {
        toast(message: "Sign-in cancelled", status: Status.info);
        return;
      }

      isSignedIn.value = true;
      toast(message: "Signed in as ${_currentUser!.email}", status: Status.success);
      action?.call();
    } catch (e) {
      toast(message: "Sign-in failed: $e", status: Status.error);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      isSignedIn.value = false;
      toast(message: "Signed out", status: Status.success);
      action?.call();
    } catch (e) {
      toast(message: "Sign-out failed: $e", status: Status.error);
    }
  }
}
