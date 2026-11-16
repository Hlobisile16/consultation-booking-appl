import 'package:flutter/material.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/views/student/home_screen.dart';
import 'package:mobile_app/views/student/login_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _formValid = false;

  List<TextEditingController> get _all =>
      [_name, _studentId, _email, _phone, _password];

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

  // Runs on every keystroke, so the button enables as soon as all fields are valid
  void _checkValid() {
    final valid = Validators.required(_name.text, 'Full name') == null &&
        Validators.studentId(_studentId.text) == null &&
        Validators.email(_email.text) == null &&
        Validators.phone(_phone.text) == null &&
        Validators.password(_password.text) == null;
    if (valid != _formValid) setState(() => _formValid = valid);
  }

  Future<void> _submit() async {
    final vm = context.read<AuthViewModel>();
    final ok = await vm.register(
      fullName: _name.text.trim(),
      studentId: _studentId.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    showAppToast(
      context,
      ok ? 'Your account has been created' : vm.error ?? 'Registration failed',
      error: !ok,
      title: ok ? 'Welcome aboard!' : 'Could not register',
    );
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
    final vm = context.watch<AuthViewModel>();
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
                  const AuthHeader(subtitle: 'Create your account'),
                  const SizedBox(height: 28),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionLabel('01. Your details'),
                          const SizedBox(height: 16),
                          _field(_name, 'Full name', Icons.person_outline,
                              (v) => Validators.required(v, 'Full name')),
                          _field(_studentId, 'Student ID', Icons.badge_outlined,
                              Validators.studentId,
                              type: TextInputType.number),
                          _field(_email, 'Email', Icons.mail_outline,
                              Validators.email,
                              type: TextInputType.emailAddress),
                          _field(_phone, 'Contact number', Icons.phone_outlined,
                              Validators.phone,
                              type: TextInputType.phone),
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
                          const SizedBox(height: 6),
                          PrimaryButton(
                            label: 'Register',
                            loading: vm.loading,
                            onPressed: _formValid ? _submit : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'I already have an account',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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