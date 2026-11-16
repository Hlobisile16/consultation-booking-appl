import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/services/admin_service.dart';
import 'package:mobile_app/viewmodels/admin_viewmodel.dart';
import 'package:mobile_app/viewmodels/auth_viewmodel.dart';
import 'package:mobile_app/viewmodels/booking_viewmodel.dart';
import 'package:mobile_app/viewmodels/profile_viewmodel.dart';
import 'package:mobile_app/views/admin/admin_dashboard_screen.dart';
import 'package:mobile_app/views/student/home_screen.dart';
import 'package:mobile_app/views/student/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consultation Booking',
      theme: AppTheme.light,
      home: const StartGate(),
    );
  }
}

// Decides the first screen: the admin dashboard for a signed-in admin,
// Home for a student who chose "Remember me", otherwise Login
class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  late final Future<Widget> _start = _pickStartScreen();

  Future<Widget> _pickStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var admin = false;
      try {
        admin = await AdminService().isAdmin(user.uid);
      } catch (_) {
        admin = false;
      }
      if (admin) return const AdminDashboardScreen();

      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      if (!remember) await FirebaseAuth.instance.signOut();
    }
    return FirebaseAuth.instance.currentUser != null
        ? const HomeScreen()
        : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _start,
      builder: (context, snapshot) {
        if (snapshot.hasData) return snapshot.data!;
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}