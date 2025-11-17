// lib/controllers/sign_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 ДОДАНО
import '../views/register_view.dart';
import '../views/main_view.dart';


class SignInController {
  final BuildContext context;
  SignInController(this.context);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 👈 ДОДАНО

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterView()),
    );
  }

  // Допоміжний метод для збереження (або оновлення) даних користувача
  Future<void> _saveUserData(User user, String name) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    // merge:true гарантує, що ми не перезапишемо ім'я, якщо воно вже є
    await userDocRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Допоміжний метод для оновлення часу входу
  Future<void> _updateUserLastSeen(User user) async {
     final userDocRef = _firestore.collection('users').doc(user.uid);
     // update використовується, якщо ми впевнені, що документ існує
     if ((await userDocRef.get()).exists) {
        await userDocRef.update({'lastSeen': FieldValue.serverTimestamp()});
     }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Вхід
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // 2. 💡 ОНОВЛЕННЯ ЧАСУ ВХОДУ (Опціонально, але корисно)
      if (userCredential.user != null) {
        await _updateUserLastSeen(userCredential.user!);
      }

      // 3. Логування та навігація
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

      // 1. Вхід в Auth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // 2. 💡 ЗБЕРІГАЄМО/ОНОВЛЮЄМО КОРИСТУВАЧА У FIRESTORE (КОЛЕКЦІЯ 'users')
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