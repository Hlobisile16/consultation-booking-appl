import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/services/booking_service.dart';

class BookingViewModel extends ChangeNotifier {
  final _service = BookingService();
  StreamSubscription<List<Booking>>? _sub;

  List<Booking> bookings = [];
  bool loading = true;
  bool saving = false;
  String? error;

  // Real-time connection: the list updates by itself whenever Firestore changes
  void listen(String uid) {
    _sub?.cancel();
    loading = true;
    notifyListeners();
    _sub = _service.streamForStudent(uid).listen(
      (list) {
        bookings = list;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('BOOKINGS ERROR: $e');
        loading = false;
        error = 'Could not load bookings';
        notifyListeners();
      },
    );
  }

  // Used by pull-to-refresh
  Future<void> refresh(String uid) async {
    try {
      bookings = await _service.fetchOnce(uid);
      error = null;
    } catch (e) {
      debugPrint('REFRESH ERROR: $e');
      error = 'Could not refresh. Check your internet';
    }
    notifyListeners();
  }

  // Called on logout so the next user never sees old data
  void clear() {
    _sub?.cancel();
    _sub = null;
    bookings = [];
    loading = true;
    error = null;
  }

  Future<bool> save(Booking booking) => _run(() => _service.save(booking));

  Future<bool> delete(String id) => _run(() => _service.delete(id));

  Future<bool> _run(Future<void> Function() action) async {
    saving = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseException catch (e) {
      debugPrint('BOOKING ERROR: $e');
      error = e.code == 'unavailable'
          ? 'Cannot reach the database. Check your internet'
          : 'Database error: ${e.code}';
      return false;
    } catch (e) {
      debugPrint('BOOKING ERROR: $e');
      error = 'Something went wrong. Please try again';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}