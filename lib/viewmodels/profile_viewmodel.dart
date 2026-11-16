import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/services/student_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final _service = StudentService();
  bool saving = false;
  String? error;

  Future<bool> saveProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _service.updateProfile(uid: uid, fullName: fullName, phone: phone);
      return true;
    } catch (e) {
      debugPrint('PROFILE ERROR: $e');
      error = _friendly(e);
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  // true = updated, false = failed, null = the user cancelled the picker
  Future<bool?> changePhoto(String uid) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      final photo = await _service.pickPhoto();
      if (photo == null) return null;
      // Firestore documents are limited to 1 MB
      if (photo.length > 700000) {
        error = 'That image is too large. Pick a smaller one';
        return false;
      }
      await _service.updatePhoto(uid, photo);
      return true;
    } catch (e) {
      debugPrint('PHOTO ERROR: $e');
      error = _friendly(e);
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  String _friendly(Object e) {
    if (e is FirebaseException) {
      return e.code == 'unavailable'
          ? 'Cannot reach the database. Check your internet'
          : 'Database error: ${e.code}';
    }
    return 'Something went wrong. Please try again';
  }
}