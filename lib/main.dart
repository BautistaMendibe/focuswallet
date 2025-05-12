import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:focuswallet/routes/app_routes.dart';
import 'package:focuswallet/screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const StartScreen(),
      routes: appRoutes,
    );
  }
}
