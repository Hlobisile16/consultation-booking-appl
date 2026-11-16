import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/models/student_model.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/viewmodels/booking_viewmodel.dart';
import 'package:mobile_app/views/student/booking_detail_screen.dart';
import 'package:mobile_app/views/student/booking_form_screen.dart';
import 'package:mobile_app/views/student/login_screen.dart';
import 'package:mobile_app/views/student/profile_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:mobile_app/views/widgets/status_chip.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _tabLabels = ['All', 'Pending', 'Confirmed'];
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthViewModel>();
      // After an app restart the student isn't in memory, so load it
      if (auth.student == null) auth.loadCurrentStudent();
      final uid = auth.uid;
      if (uid != null) context.read<BookingViewModel>().listen(uid);
    });
  }

  Future<void> _logout() async {
    context.read<BookingViewModel>().clear();
    await context.read<AuthViewModel>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _refresh() async {
    final uid = context.read<AuthViewModel>().uid;
    if (uid != null) await context.read<BookingViewModel>().refresh(uid);
  }

  void _newBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BookingFormScreen()),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  List<Booking> _filtered(List<Booking> all) {
    if (_tab == 1) return all.where((b) => b.status != 'confirmed').toList();
    if (_tab == 2) return all.where((b) => b.status == 'confirmed').toList();
    return all;
  }

  Widget _welcomeCard(Student? student) {
    final photo = student?.photoBase64;
    final ImageProvider? image = (photo != null && photo.isNotEmpty)
        ? MemoryImage(base64Decode(photo))
        : null;
    final name = student?.fullName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SoftCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.mist,
                backgroundImage: image,
                child: image == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sage,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF58B368),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                Text(
                  name.isEmpty ? '...' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (student != null)
                  Text(
                    'Student ID ${student.studentId}',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'profile') {
                _openProfile();
              } else {
                _logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('My profile')),
              PopupMenuItem(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewCard(List<Booking> all) {
    final total = all.length;
    final confirmed = all.where((b) => b.status == 'confirmed').length;
    final progress = total == 0 ? 0.0 : confirmed / total;
    final upcoming = all.where((b) => b.dateTime.isAfter(DateTime.now())).toList();

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('01. Overview'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(value: progress, minHeight: 10),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$confirmed of $total confirmed',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          if (upcoming.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.event, size: 18, color: AppColors.sage),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next: ${DateFormat('EEE d MMM, HH:mm').format(upcoming.first.dateTime)} with ${upcoming.first.lecturer}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookingCard(Booking b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.id!)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.sage),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(b.dateTime),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.lecturer,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.topic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  StatusChip(status: b.status),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sand),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final noBookings = _tab == 0;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SoftCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 30,
                color: AppColors.sage,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              noBookings
                  ? 'No bookings yet'
                  : 'Nothing in ${_tabLabels[_tab].toLowerCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              noBookings
                  ? 'Tap New booking to schedule a consultation.'
                  : 'Switch tabs to see your other bookings.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthViewModel>().student;
    final vm = context.watch<BookingViewModel>();
    final list = _filtered(vm.bookings);
    final dayFormat = DateFormat('EEE, d MMM yyyy');

    final children = <Widget>[
      _welcomeCard(student),
      const SizedBox(height: 16),
      _overviewCard(vm.bookings),
      const SizedBox(height: 20),
      SegmentedTabs(
        labels: _tabLabels,
        selected: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    ];

    if (vm.error != null) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(vm.error!, style: const TextStyle(color: AppColors.danger)),
      ));
    }
    if (list.isEmpty && vm.error == null) children.add(_emptyState());

    // Bookings are sorted by date, so a new header is added whenever the day changes
    String? lastDay;
    for (final b in list) {
      final day = dayFormat.format(b.dateTime);
      if (day != lastDay) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
          child: SectionLabel(day),
        ));
        lastDay = day;
      }
      children.add(_bookingCard(b));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('MY CONSULTATIONS')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newBooking,
        icon: const Icon(Icons.add),
        label: const Text('New booking'),
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                    children: children,
                  ),
                ),
              ),
            ),
    );
  }
}