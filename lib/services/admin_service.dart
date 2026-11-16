import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/services/auth_service.dart';

class AdminService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists && doc.data()?['isAdmin'] == true;
  }

  Future<void> registerAdmin({
    required String fullName,
    required String email,
    required String password,
    required String code,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    try {
      // The privilege flag lives in the 'admins' collection. The security
      // rules only accept this write if 'accessCode' matches config/admin.
      await _db.collection('admins').doc(cred.user!.uid).set({
        'fullName': fullName,
        'email': email,
        'isAdmin': true,
        'accessCode': code,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Remove the login that was just created, so nothing is left half-made
      await cred.user!.delete();
      if (e.code == 'permission-denied') {
        throw AppException('Incorrect admin access code');
      }
      rethrow;
    }
  }

  Future<void> loginAdmin(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!await isAdmin(cred.user!.uid)) {
      await _auth.signOut();
      throw AppException('This account is not an admin account');
    }
  }

  Stream<List<Booking>> streamAllBookings() =>
      _db.collection('bookings').snapshots().map((snap) {
        final list = snap.docs.map(Booking.fromDoc).toList();
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      });

  Future<void> deleteBooking(String id) =>
      _db.collection('bookings').doc(id).delete();

  Future<void> setStatus(String id, String status) =>
      _db.collection('bookings').doc(id).update({'status': status});

  Future<void> logout() => _auth.signOut();
}