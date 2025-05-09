import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Регистрация
  Future<UserCredential> signUp(String email, String password, String username) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return userCredential;
  }

  // Вход
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Изход
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Вземане на текущ потребител
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Проверка дали потребителят е логнат
  Stream<User?> get authStateChanges => _auth.authStateChanges();
} 