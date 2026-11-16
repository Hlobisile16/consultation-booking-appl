import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String uid, studentId, fullName, email, phone;
  final String? photoBase64;

  Student({
    required this.uid,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.photoBase64,
  });

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'photoBase64': photoBase64,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory Student.fromMap(String uid, Map<String, dynamic> m) => Student(
        uid: uid,
        studentId: m['studentId'] ?? '',
        fullName: m['fullName'] ?? '',
        email: m['email'] ?? '',
        phone: m['phone'] ?? '',
        photoBase64: m['photoBase64'],
      );
}