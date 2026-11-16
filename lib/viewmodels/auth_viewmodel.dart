import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/student_model.dart';
import 'package:mobile_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthViewModel extends ChangeNotifier {
  final _service = AuthService();
  bool loading = false;
  String? error;
  Student? student;
  String? get uid => _service.currentUid;

  // Runs an action with loading and error handling, so each method stays short
  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('AUTH ERROR: $e');
      error = _friendly(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
    required String phone,
  }) =>
      _run(() async {
        student = await _service.registerStudent(
          fullName: fullName,
          studentId: studentId,
          email: email,
          password: password,
          phone: phone,
        );
      });

  Future<bool> login({
    required String email,
    required String password,
    required bool remember,
  }) =>
      _run(() async {
        student = await _service.loginStudent(email, password);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', remember);
        if (remember) {
          await prefs.setString('saved_email', email);
        } else {
          await prefs.remove('saved_email');
        }
      });

  Future<bool> resetPassword(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<String?> savedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember_me') ?? false) {
      return prefs.getString('saved_email');
    }
    return null;
  }

  Future<void> loadCurrentStudent() async {
    student = await _service.currentStudent();
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    student = null;
    notifyListeners();
  }

    String _friendly(Object e) {
    if (e is AppException) return e.message;
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'That email is already registered';
        case 'invalid-email':
          return 'That email address is not valid';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-credential':
        case 'user-not-found':
        case 'wrong-password':
          return 'Incorrect email or password';
        case 'too-many-requests':
          return 'Too many attempts. Try again later';
        case 'network-request-failed':
          return 'No internet connection';
        default:
          return e.message ?? 'Something went wrong';
      }
    }
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') {
        return 'Database permission denied. Check the Firestore rules';
      }
      if (e.code == 'unavailable') {
        return 'Cannot reach the database. Check your internet';
      }
      return 'Database error: ${e.code}';
    }
    return 'Something went wrong: $e';
  }

  
}