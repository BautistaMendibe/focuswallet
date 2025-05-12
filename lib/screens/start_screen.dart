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
  bool _seenOnboarding = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    setState(() {
      _seenOnboarding = seen;
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user != null) {
      Future.microtask(
        () => Navigator.pushReplacementNamed(context, '/dashboard'),
      );
      return const SizedBox();
    }

    if (_seenOnboarding) {
      Future.microtask(
        () => Navigator.pushReplacementNamed(context, '/login'),
      );
      return const SizedBox();
    }

    return const OnboardingScreen();
  }
}
