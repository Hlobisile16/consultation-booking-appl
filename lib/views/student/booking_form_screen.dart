import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/models/booking_model.dart';
import 'package:mobile_app/models/lecturer_model.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/viewmodels/booking_viewmodel.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

class BookingFormScreen extends StatefulWidget {
  // null = new booking, otherwise we are editing this booking
  final Booking? existing;
  const BookingFormScreen({super.key, this.existing});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topic;
  late final TextEditingController _notes;
  String? _lecturer;
  DateTime? _dateTime;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _topic = TextEditingController(text: b?.topic ?? '');
    _notes = TextEditingController(text: b?.notes ?? '');
    _lecturer = Lecturer.all.any((l) => l.name == b?.lecturer) ? b!.lecturer : null;
    _dateTime = b?.dateTime;
  }

  @override
  void dispose() {
    _topic.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: (_dateTime != null && _dateTime!.isAfter(now)) ? _dateTime! : now,
      firstDate: now, // future dates only
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime ?? now),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateError = null;
    });
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();

    String? dateError;
    if (_dateTime == null) {
      dateError = 'Pick a date and time';
    } else if (!_dateTime!.isAfter(DateTime.now())) {
      dateError = 'Choose a future date and time';
    }
    setState(() => _dateError = dateError);
    if (!formOk || dateError != null) return;

    final student = context.read<AuthViewModel>().student;
    if (student == null) {
      showAppToast(
        context,
        'Your profile is still loading. Try again in a moment',
        error: true,
        title: 'One moment',
      );
      return;
    }

    final old = widget.existing;
    final booking = Booking(
      id: old?.id,
      studentUid: student.uid,
      studentId: student.studentId,
      studentName: student.fullName,
      lecturer: _lecturer!,
      topic: _topic.text.trim(),
      notes: _notes.text.trim(),
      status: old?.status ?? 'pending',
      dateTime: _dateTime!,
    );

    final vm = context.read<BookingViewModel>();
    final ok = await vm.save(booking);
    if (!mounted) return;
    if (ok) {
      showAppToast(
        context,
        old == null ? 'Your booking has been saved' : 'Your booking has been updated',
      );
      Navigator.pop(context);
    } else {
      showAppToast(
        context,
        vm.error ?? 'Could not save booking',
        error: true,
        title: 'Could not save',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<BookingViewModel>().saving;
    final editing = widget.existing != null;
    final lecturer = _lecturer == null ? null : Lecturer.byName(_lecturer!);

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'EDIT BOOKING' : 'NEW BOOKING')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionLabel('01. Lecturer'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _lecturer,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Choose a lecturer',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: Lecturer.all
                              .map((l) => DropdownMenuItem(
                                    value: l.name,
                                    child: Text(l.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _lecturer = v),
                          validator: (v) => v == null ? 'Select a lecturer' : null,
                        ),
                        if (lecturer != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 4),
                            child: Text(
                              '${lecturer.department}  |  ${lecturer.office}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionLabel('02. Date and time'),
                        const SizedBox(height: 16),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _pickDateTime,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Pick a date and time',
                              prefixIcon: const Icon(Icons.calendar_month_outlined),
                              errorText: _dateError,
                            ),
                            child: Text(
                              _dateTime == null
                                  ? 'Tap to choose'
                                  : DateFormat('EEE, d MMM yyyy  HH:mm')
                                      .format(_dateTime!),
                              style: TextStyle(
                                color: _dateTime == null
                                    ? AppColors.muted
                                    : AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SectionLabel('03. Details'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _topic,
                          maxLines: 3,
                          validator: Validators.topic,
                          decoration: const InputDecoration(
                            labelText: 'Topic (at least 20 characters)',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _notes,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Additional notes (optional)',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: editing ? 'Update booking' : 'Save booking',
                    loading: saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}