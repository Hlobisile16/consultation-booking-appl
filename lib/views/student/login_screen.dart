import 'package:flutter/material.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/views/admin/admin_login_screen.dart';
import 'package:mobile_app/views/student/home_screen.dart';
import 'package:mobile_app/views/student/register_screen.dart';
import 'package:mobile_app/views/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _remember = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill the email if "Remember me" was on last time
    context.read<AuthViewModel>().savedEmail().then((email) {
      if (email != null && mounted) {
        setState(() {
          _email.text = email;
          _remember = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    final ok = await vm.login(
      email: _email.text.trim(),
      password: _password.text,
      remember: _remember,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      showAppToast(
        context,
        vm.error ?? 'Login failed',
        error: true,
        title: 'Login failed',
      );
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (email == null || !mounted) return;

    final problem = Validators.email(email);
    if (problem != null) {
      showAppToast(context, problem, error: true, title: 'Check the email');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final ok = await vm.resetPassword(email);
    if (!mounted) return;
    showAppToast(
      context,
      ok
          ? 'Reset link sent. Check your inbox and spam folder'
          : vm.error ?? 'Could not send reset email',
      error: !ok,
      title: ok ? 'Email sent' : 'Could not send',
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
                  const AuthHeader(subtitle: 'Student sign in'),
                  const SizedBox(height: 28),
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SectionLabel('01. Account'),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: _hidePassword,
                            validator: (v) => Validators.required(v, 'Password'),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _hidePassword = !_hidePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Remember me'),
                            value: _remember,
                            onChanged: (v) => setState(() => _remember = v),
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Login',
                            loading: vm.loading,
                            onPressed: _login,
                          ),
                          Center(
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'Create an account',
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                      ),
                      child: const Text('Admin portal'),
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