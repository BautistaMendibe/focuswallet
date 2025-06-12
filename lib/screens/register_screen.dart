import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  final _authService = AuthService();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;

  Future<void> _initializeUserDefaults(String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      //print('Inicializando settings...');
      await firestore.collection('users').doc(userId).set({
        'settings': {
          'pricePerHour': 2.0,
          'dailyBudget': 2.0,
        }
      });
      //print('Settings guardados correctamente.');
    } catch (e) {
      //print('Error al guardar settings: $e');
      rethrow;
    }

    try {
      //print('Inicializando categoryBudgets...');
      final categoryBudgetsRef = firestore.collection('users').doc(userId).collection('categoryBudgets');

      await Future.wait([
        categoryBudgetsRef.doc('social_media').set({
          'name': 'Redes sociales',
          'amount': 1.0,
        }),
        categoryBudgetsRef.doc('streaming').set({
          'name': 'Streaming',
          'amount': 0.5,
        }),
        categoryBudgetsRef.doc('juegos').set({
          'name': 'Juegos',
          'amount': 0.5,
        }),
      ]);
      //print('CategoryBudgets guardados correctamente.');
    } catch (e) {
      //print('Error al guardar categoryBudgets: $e');
      rethrow;
    }
}


  void register() async {
    final loc = AppLocalizations.of(context)!;

    if (passCtrl.text != confirmPassCtrl.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.passwordsDoNotMatch),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.register(emailCtrl.text, passCtrl.text);
      if (!mounted) return;

      if (user != null) {
        await _initializeUserDefaults(user.uid);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = loc.auth_email_already_in_use;
          break;
        case 'invalid-email':
          errorMsg = loc.auth_invalid_email;
          break;
        case 'weak-password':
          errorMsg = loc.auth_weak_password;
          break;
        default:
          errorMsg = loc.auth_register_default_error;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Image.asset('assets/imgs/iconoapp.png', height: 150),
                const SizedBox(height: 24),
                Text(
                  loc.registerTitle,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.registerSubtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 50),

                // Email
                TextField(
                  controller: emailCtrl,
                  decoration: customInputDecoration(loc.emailLabel),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePass,
                  decoration: customInputDecoration(loc.passwordLabel).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePass = !_obscurePass;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: _obscureConfirmPass,
                  decoration: customInputDecoration(loc.confirmPasswordLabel).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPass = !_obscureConfirmPass;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009792),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            loc.registerButton,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.alreadyHaveAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        loc.goToLogin,
                        style: const TextStyle(color: Color(0xFF009792)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
