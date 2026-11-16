import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/services/admin_service.dart';
import 'package:mobile_app/services/auth_service.dart';

class AdminViewModel extends ChangeNotifier {
  final _service = AdminService();
  StreamSubscription<List<Booking>>? _sub;

  List<Booking> all = [];
  bool loading = false; // login, register, delete
  bool loadingBookings = true;
  String? error;
  String query = '';
  DateTimeRange? range;

  // Applies the Student ID search and the date range to the full list
  List<Booking> get filtered {
    final q = query.trim().toLowerCase();
    return all.where((b) {
      if (q.isNotEmpty && !b.studentId.toLowerCase().contains(q)) return false;
      if (range != null) {
        final day = DateTime(b.dateTime.year, b.dateTime.month, b.dateTime.day);
        if (day.isBefore(range!.start) || day.isAfter(range!.end)) return false;
      }
      return true;
    }).toList();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setRange(DateTimeRange? value) {
    range = value;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    range = null;
    notifyListeners();
  }

  // Real-time list of every student's bookings
  void listen() {
    _sub?.cancel();
    loadingBookings = true;
    notifyListeners();
    _sub = _service.streamAllBookings().listen(
      (list) {
        all = list;
        loadingBookings = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ADMIN BOOKINGS ERROR: $e');
        loadingBookings = false;
        error = 'Could not load bookings';
        notifyListeners();
      },
    );
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (e) {
      debugPrint('ADMIN ERROR: $e');
      error = _friendly(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String code,
  }) =>
      _run(() => _service.registerAdmin(
            fullName: fullName,
            email: email,
            password: password,
            code: code,
          ));

  Future<bool> login(String email, String password) =>
      _run(() => _service.loginAdmin(email, password));

  Future<bool> deleteBooking(String id) =>
      _run(() => _service.deleteBooking(id));

  Future<bool> confirmBooking(String id) =>
      _run(() => _service.setStatus(id, 'confirmed'));

  Future<void> logout() async {
    _sub?.cancel();
    _sub = null;
    all = [];
    query = '';
    range = null;
    loadingBookings = true;
    await _service.logout();
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
      return e.code == 'unavailable'
          ? 'Cannot reach the database. Check your internet'
          : 'Database error: ${e.code}';
    }
    return 'Something went wrong. Please try again';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}