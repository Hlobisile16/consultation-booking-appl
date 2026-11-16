import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/models/student_model.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;
  // The 'studentIds' collection exists only so we can check uniqueness
  // before the user is signed in.
  Future<bool> studentIdTaken(String studentId) async {
    final doc = await _db.collection('studentIds').doc(studentId).get();
    return doc.exists;
  }

  Future<Student> registerStudent({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (await studentIdTaken(studentId)) {
      throw AppException('That Student ID is already registered');
    }
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final student = Student(
      uid: cred.user!.uid,
      studentId: studentId,
      fullName: fullName,
      email: email,
      phone: phone,
    );

    final batch = _db.batch();
    batch.set(_db.collection('students').doc(student.uid), student.toMap());
    batch.set(_db.collection('studentIds').doc(studentId), {'uid': student.uid});
    await batch.commit();
    return student;
  }

  Future<Student> loginStudent(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc = await _db.collection('students').doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw AppException('No student account found for this email');
    }
    return Student.fromMap(doc.id, doc.data()!);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> logout() => _auth.signOut();

  Future<Student?> currentStudent() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('students').doc(user.uid).get();
    if (!doc.exists) return null;
    return Student.fromMap(doc.id, doc.data()!);
  }
}