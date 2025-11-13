import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../views/register_view.dart';
import '../views/main_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInController {
  final BuildContext context;
  SignInController(this.context);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _analytics.logLogin(loginMethod: 'email');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in successful!')),
      );
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' => 'No user found for that email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email address.',
        'user-disabled' => 'This account has been disabled.',
        _ => 'Sign in failed. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);


      await _analytics.logLogin(loginMethod: 'google');
      await _analytics.logEvent(name: 'google_sign_in');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in failed: ${e.toString()}')),
      );
    }
  }
}
