import 'package:flutter/material.dart' show BuildContext, ValueNotifier, VoidCallback;
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn, GoogleSignInAccount;
import '/constants/status.dart' show Status;
import '/env/env.dart' show Env;
import '/widgets/toast.dart' show toast;

class OAuthController {
  final BuildContext context;
  final VoidCallback? action;

  OAuthController({required this.context, this.action});

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final ValueNotifier<bool> isSignedIn = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> init() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _googleSignIn.initialize(clientId: Env.iosClientID);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn() async {
    if (isLoading.value) return;

    isLoading.value = true;
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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      isSignedIn.value = false;
      toast(message: "Signed out", status: Status.success);
      action?.call();
    } catch (e) {
      toast(message: "Sign-out failed: $e", status: Status.error);
    } finally {
      isLoading.value = false;
    }
  }
}
