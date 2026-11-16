import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/models/lecturer_model.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/viewmodels/booking_viewmodel.dart';
import 'package:mobile_app/views/student/booking_form_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:mobile_app/views/widgets/status_chip.dart';
import 'package:provider/provider.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  Future<void> _delete(BuildContext context, Booking b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete booking?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final vm = context.read<BookingViewModel>();
    final ok = await vm.delete(b.id!);
    if (!context.mounted) return;
    showAppToast(
      context,
      ok ? 'The booking has been deleted' : vm.error ?? 'Could not delete booking',
      error: !ok,
      title: ok ? 'Deleted' : 'Could not delete',
    );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // Looked up live, so the screen updates after an edit
    final vm = context.watch<BookingViewModel>();
    final booking = vm.bookings.where((b) => b.id == bookingId).firstOrNull;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('BOOKING')),
        body: const Center(child: Text('Booking not found')),
      );
    }

    final lecturer = Lecturer.byName(booking.lecturer);
    final when = DateFormat('EEEE, d MMMM yyyy').format(booking.dateTime);
    final time = DateFormat('HH:mm').format(booking.dateTime);

    return Scaffold(
      appBar: AppBar(title: const Text('BOOKING DETAILS')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SoftCard(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.moss, AppColors.sage],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.school_outlined, color: AppColors.ivory),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.lecturer,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (lecturer != null)
                            Text(
                              lecturer.department,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          const SizedBox(height: 8),
                          StatusChip(status: booking.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('01. Schedule'),
                    const SizedBox(height: 8),
                    InfoRow(icon: Icons.calendar_today_outlined, label: 'Date', value: when),
                    InfoRow(icon: Icons.access_time, label: 'Time', value: time),
                    if (lecturer != null)
                      InfoRow(
                        icon: Icons.meeting_room_outlined,
                        label: 'Office',
                        value: lecturer.office,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('02. Consultation'),
                    const SizedBox(height: 8),
                    InfoRow(icon: Icons.topic_outlined, label: 'Topic', value: booking.topic),
                    if (booking.notes.isNotEmpty)
                      InfoRow(
                        icon: Icons.notes_outlined,
                        label: 'Additional notes',
                        value: booking.notes,
                      ),
                    if (lecturer != null)
                      InfoRow(
                        icon: Icons.mail_outline,
                        label: 'Lecturer email',
                        value: lecturer.email,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingFormScreen(existing: booking),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.ivory,
                      ),
                      onPressed: () => _delete(context, booking),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}