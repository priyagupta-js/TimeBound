import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Register a new user
  Future<String?> registerUser(String username, String password) async {
    final docRef = _firestore.collection(_collection).doc(username);
    final doc = await docRef.get();
    if (doc.exists) {
      return 'Username already exists';
    }
    await docRef.set({
      'username': username,
      'password': password,
    });
    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    return null;
  }

  // Login a user
  Future<String?> loginUser(String username, String password) async {
    final docRef = _firestore.collection(_collection).doc(username);
    final doc = await docRef.get();
    if (!doc.exists) {
      return 'Username not found';
    }
    if (doc['password'] != password) {
      return 'Incorrect password';
    }
    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    return null;
  }

  // Get current logged-in user
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
}
