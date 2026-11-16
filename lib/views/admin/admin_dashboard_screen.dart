import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/viewmodels/admin_viewmodel.dart';
import 'package:mobile_app/views/admin/admin_login_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:mobile_app/views/widgets/status_chip.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminViewModel>().listen();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AdminViewModel>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _pickRange() async {
    final vm = context.read<AdminViewModel>();
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDateRange: vm.range,
    );
    if (picked != null) vm.setRange(picked);
  }

  void _clearFilters() {
    _search.clear();
    context.read<AdminViewModel>().clearFilters();
  }

  Future<void> _delete(Booking b) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete booking?'),
        content: Text('Delete the booking for ${b.studentName} (${b.studentId})? '
            'This cannot be undone.'),
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
    if (confirm != true || !mounted) return;
    final vm = context.read<AdminViewModel>();
    final ok = await vm.deleteBooking(b.id!);
    if (!mounted) return;
    showAppToast(
      context,
      ok ? 'The booking has been deleted' : vm.error ?? 'Could not delete',
      error: !ok,
      title: ok ? 'Deleted' : 'Could not delete',
    );
  }

  Future<void> _confirmBooking(Booking b) async {
    final vm = context.read<AdminViewModel>();
    final ok = await vm.confirmBooking(b.id!);
    if (!mounted) return;
    showAppToast(
      context,
      ok ? 'The booking is now confirmed' : vm.error ?? 'Could not confirm',
      error: !ok,
      title: ok ? 'Confirmed' : 'Could not confirm',
    );
  }

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.sage),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );

  Widget _stat(String label, int value) => Expanded(
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      );

  Widget _card(Booking b) {
    final when = DateFormat('EEE, d MMM yyyy  HH:mm').format(b.dateTime);
    final initial = b.studentName.isNotEmpty ? b.studentName[0].toUpperCase() : '?';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.mist,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.sage,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Student ID ${b.studentId}',
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StatusChip(status: b.status),
              ],
            ),
            const Divider(height: 24, color: AppColors.mist),
            _line(Icons.calendar_today_outlined, when),
            _line(Icons.person_outline, b.lecturer),
            _line(Icons.notes_outlined, b.topic),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (b.status != 'confirmed')
                  TextButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Confirm'),
                    onPressed: () => _confirmBooking(b),
                  ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  onPressed: () => _delete(b),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final list = vm.filtered;
    final dateFormat = DateFormat('d MMM yyyy');
    final hasFilters = vm.query.isNotEmpty || vm.range != null;
    final pending = vm.all.where((b) => b.status != 'confirmed').length;
    final confirmed = vm.all.length - pending;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  children: [
                    SoftCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          _stat('Total', vm.all.length),
                          _stat('Pending', pending),
                          _stat('Confirmed', confirmed),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _search,
                      onChanged: vm.setQuery,
                      decoration: InputDecoration(
                        labelText: 'Search by Student ID',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: vm.query.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _search.clear();
                                  vm.setQuery('');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range, size: 18),
                            label: Text(
                              vm.range == null
                                  ? 'Filter by date range'
                                  : '${dateFormat.format(vm.range!.start)} to ${dateFormat.format(vm.range!.end)}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: _pickRange,
                          ),
                        ),
                        if (hasFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SectionLabel('${list.length} of ${vm.all.length} bookings'),
                ),
              ),
              Expanded(
                child: vm.loadingBookings
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error != null
                        ? Center(
                            child: Text(
                              vm.error!,
                              style: const TextStyle(color: AppColors.danger),
                            ),
                          )
                        : list.isEmpty
                            ? const Center(
                                child: Text(
                                  'No bookings found',
                                  style: TextStyle(color: AppColors.muted),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                itemCount: list.length,
                                itemBuilder: (_, i) => _card(list[i]),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}