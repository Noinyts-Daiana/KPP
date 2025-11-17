// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Потік для відстеження стану автентифікації
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Отримати поточного користувача
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Вхід через Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In скасовано');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, userCredential.user!.displayName ?? 'Google User');
      }
    } catch (e) {
      print("Помилка входу через Google: $e");
      rethrow;
    }
  }

  // Вхід з Email/Паролем
  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Реєстрація з Email/Паролем
  Future<void> signUpWithEmail(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!, name);
      }
    } catch (e) {
      print("Помилка реєстрації: $e");
      rethrow;
    }
  }

  // Допоміжний метод для збереження даних у Firestore
  Future<void> _saveUserData(User user, String name) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    await userDocRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Вихід
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}