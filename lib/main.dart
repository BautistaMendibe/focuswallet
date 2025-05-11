import 'package:flutter/material.dart';
import 'package:focuswallet/routes/app_routes.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(FocusWalletApp());
}

class FocusWalletApp extends StatelessWidget {
  const FocusWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusWallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
      ),
      home: OnboardingScreen(),
      routes: appRoutes,
    );
  }
}
