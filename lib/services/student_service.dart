import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class StudentService {
  final _db = FirebaseFirestore.instance;

  // Also updates the name stored on the student's existing bookings,
  // so the admin dashboard never shows an old name
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    final batch = _db.batch();
    batch.update(_db.collection('students').doc(uid), {
      'fullName': fullName,
      'phone': phone,
    });
    final bookings = await _db
        .collection('bookings')
        .where('studentUid', isEqualTo: uid)
        .get();
    for (final d in bookings.docs) {
      batch.update(d.reference, {'studentName': fullName});
    }
    await batch.commit();
  }

  // Opens the gallery and shrinks the picture so it fits in a Firestore document.
  // Returns null if the user cancels.
  Future<String?> pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> updatePhoto(String uid, String photoBase64) => _db
      .collection('students')
      .doc(uid)
      .update({'photoBase64': photoBase64});
}