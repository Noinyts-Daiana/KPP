// lib/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ДОДАНО
import '../views/sign_view.dart';
import '../views/main_view.dart';

class RegisterController {
  final BuildContext context;
  RegisterController(this.context);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 👈 ДОДАНО

  void goToSignIn() {
    // Використовуємо pop, оскільки RegisterView, ймовірно, відкрився поверх SignView
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Якщо ні, то переходимо (запасний варіант)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignView()),
      );
    }
  }

  // Допоміжний метод для збереження даних користувача у Firestore
  Future<void> _saveUserData(User user, String name) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    // set з merge:true, щоб не перезаписати існуючі дані
    await userDocRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Створюємо користувача в Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _auth.currentUser?.updateDisplayName(name);

      // 2. 💡 ЗБЕРІГАЄМО КОРИСТУВАЧА У FIRESTORE (КОЛЕКЦІЯ 'users')
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, name);
      }

      // 3. Логування та навігація
      await _analytics.logSignUp(signUpMethod: 'email');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainView()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'This email is already registered.',
        'invalid-email' => 'Invalid email address.',
        'weak-password' => 'Password should be at least 6 characters.',
        _ => 'Registration failed. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

      // 1. Вхід в Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 2. 💡 ЗБЕРІГАЄМО КОРИСТУВАЧА У FIRESTORE (КОЛЕКЦІЯ 'users')
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, userCredential.user!.displayName ?? 'Google User');
      }

      // 3. Логування та навігація
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