import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/models/booking_model.dart';

class BookingService {
  final _col = FirebaseFirestore.instance.collection('bookings');

  // Sorting here (not in the query) means no Firestore index is needed
  List<Booking> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final list = snap.docs.map(Booking.fromDoc).toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  Stream<List<Booking>> streamForStudent(String uid) =>
      _col.where('studentUid', isEqualTo: uid).snapshots().map(_sorted);

  Future<List<Booking>> fetchOnce(String uid) async {
    final snap = await _col
        .where('studentUid', isEqualTo: uid)
        .get(const GetOptions(source: Source.server));
    return _sorted(snap);
  }

  Future<void> save(Booking b) async {
    if (b.id == null) {
      await _col.add(b.toMap());
    } else {
      await _col.doc(b.id).update(b.toMap());
    }
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}