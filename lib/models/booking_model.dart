import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String studentUid, studentId, studentName, lecturer, topic, notes, status;
  final DateTime dateTime;

  Booking({
    this.id,
    required this.studentUid,
    required this.studentId,
    required this.studentName,
    required this.lecturer,
    required this.topic,
    this.notes = '',
    this.status = 'pending',
    required this.dateTime,
  });

  Map<String, dynamic> toMap() => {
        'studentUid': studentUid,
        'studentId': studentId,
        'studentName': studentName,
        'lecturer': lecturer,
        'topic': topic,
        'notes': notes,
        'status': status,
        'dateTime': Timestamp.fromDate(dateTime),
      };

  factory Booking.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return Booking(
      id: d.id,
      studentUid: m['studentUid'] ?? '',
      studentId: m['studentId'] ?? '',
      studentName: m['studentName'] ?? '',
      lecturer: m['lecturer'] ?? '',
      topic: m['topic'] ?? '',
      notes: m['notes'] ?? '',
      status: m['status'] ?? 'pending',
      dateTime: (m['dateTime'] as Timestamp).toDate(),
    );
  }
}