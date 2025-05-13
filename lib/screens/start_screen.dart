import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
  }

  Future<void> _handleStartupLogic() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    // Redirige según corresponda
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (seen) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Si no vio el onboarding, se muestra la pantalla
    return const OnboardingScreen();
  }
}
