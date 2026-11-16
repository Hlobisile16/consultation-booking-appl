import 'package:flutter/material.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/admin_viewmodel.dart';
import 'package:mobile_app/views/admin/admin_dashboard_screen.dart';
import 'package:mobile_app/views/admin/admin_login_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _hidePassword = true;
  bool _formValid = false;

  List<TextEditingController> get _all => [_name, _email, _password, _code];

  @override
  void initState() {
    super.initState();
    for (final c in _all) {
      c.addListener(_checkValid);
    }
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkValid() {
    final valid = Validators.required(_name.text, 'Full name') == null &&
        Validators.email(_email.text) == null &&
        Validators.password(_password.text) == null &&
        Validators.required(_code.text, 'Access code') == null;
    if (valid != _formValid) setState(() => _formValid = valid);
  }

  Future<void> _submit() async {
    final vm = context.read<AdminViewModel>();
    final ok = await vm.register(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      code: _code.text.trim(),
    );
    if (!mounted) return;
    showAppToast(
      context,
      ok ? 'Your admin account has been created' : vm.error ?? 'Registration failed',
      error: !ok,
      title: ok ? 'Welcome, admin!' : 'Could not register',
    );
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        (route) => false,
      );
    }
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? type,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(subtitle: 'Admin registration'),
                  const SizedBox(height: 28),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionLabel('01. Admin details'),
                          const SizedBox(height: 16),
                          _field(_name, 'Full name', Icons.person_outline,
                              (v) => Validators.required(v, 'Full name')),
                          _field(_email, 'Email', Icons.mail_outline,
                              Validators.email,
                              type: TextInputType.emailAddress),
                          _field(
                            _password,
                            'Password',
                            Icons.lock_outline,
                            Validators.password,
                            obscure: _hidePassword,
                            suffix: IconButton(
                              icon: Icon(_hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          _field(_code, 'Admin access code', Icons.vpn_key_outlined,
                              (v) => Validators.required(v, 'Access code')),
                          const SizedBox(height: 6),
                          PrimaryButton(
                            label: 'Register as admin',
                            loading: vm.loading,
                            onPressed: _formValid ? _submit : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'I already have an admin account',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
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