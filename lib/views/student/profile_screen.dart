import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_app/models/student_model.dart';
import 'package:mobile_app/theme/app_theme.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/viewmodels/profile_viewmodel.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _startEdit(Student s) {
    _name.text = s.fullName;
    _phone.text = s.phone;
    setState(() => _editing = true);
  }

  Future<void> _save(Student s) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final vm = context.read<ProfileViewModel>();
    final ok = await vm.saveProfile(
      uid: s.uid,
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      await auth.loadCurrentStudent(); // refreshes the welcome message too
      if (!mounted) return;
      setState(() => _editing = false);
      showAppToast(context, 'Your profile has been updated');
    } else {
      showAppToast(
        context,
        vm.error ?? 'Could not update profile',
        error: true,
        title: 'Could not save',
      );
    }
  }

  Future<void> _changePhoto(Student s) async {
    final auth = context.read<AuthViewModel>();
    final vm = context.read<ProfileViewModel>();
    final result = await vm.changePhoto(s.uid);
    if (!mounted || result == null) return; // null = cancelled
    if (result) {
      await auth.loadCurrentStudent();
      if (!mounted) return;
      showAppToast(context, 'Your profile picture has been updated');
    } else {
      showAppToast(
        context,
        vm.error ?? 'Could not update picture',
        error: true,
        title: 'Could not update',
      );
    }
  }

  Widget _avatar(Student s, bool busy) {
    final photo = s.photoBase64;
    final hasPhoto = photo != null && photo.isNotEmpty;
    final initial = s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?';
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.moss, AppColors.sage],
            ),
            boxShadow: AppShadows.soft,
          ),
          child: CircleAvatar(
            radius: 54,
            backgroundColor: AppColors.mist,
            backgroundImage: hasPhoto ? MemoryImage(base64Decode(photo)) : null,
            child: hasPhoto
                ? null
                : Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: AppColors.sage,
                    ),
                  ),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.sage,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 18,
              color: AppColors.ivory,
              tooltip: 'Change picture',
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: busy ? null : () => _changePhoto(s),
            ),
          ),
        ),
      ],
    );
  }

  Widget _viewMode(Student s) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('01. Details'),
                const SizedBox(height: 8),
                InfoRow(icon: Icons.person_outline, label: 'Full name', value: s.fullName),
                InfoRow(icon: Icons.badge_outlined, label: 'Student ID', value: s.studentId),
                InfoRow(icon: Icons.mail_outline, label: 'Email', value: s.email),
                InfoRow(icon: Icons.phone_outlined, label: 'Contact number', value: s.phone),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Edit profile',
            icon: Icons.edit_outlined,
            onPressed: () => _startEdit(s),
          ),
        ],
      );

  Widget _editMode(Student s, bool saving) => Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionLabel('01. Edit details'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    validator: (v) => Validators.required(v, 'Full name'),
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Student ID and email are shown but locked: the ID is the
                  // unique key and the email is the login
                  TextFormField(
                    initialValue: s.studentId,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Student ID (cannot be changed)',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: s.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email (cannot be changed)',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: saving ? null : () => setState(() => _editing = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Save',
                    icon: null,
                    loading: saving,
                    onPressed: () => _save(s),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthViewModel>().student;
    final saving = context.watch<ProfileViewModel>().saving;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PROFILE')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'EDIT PROFILE' : 'PROFILE')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              children: [
                _avatar(student, saving),
                const SizedBox(height: 14),
                Text(
                  student.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Student ID ${student.studentId}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                _editing ? _editMode(student, saving) : _viewMode(student),
              ],
            ),
          ),
        ),
      ),
    );
  }
}