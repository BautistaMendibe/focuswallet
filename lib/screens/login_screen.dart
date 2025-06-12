import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscurePass = true;
  bool _isLoading = false;

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = await _authService.login(emailCtrl.text, passCtrl.text);

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final loc = AppLocalizations.of(context)!;
      String errorMsg;

      switch (e.code) {
        case 'user-not-found':
          errorMsg = loc.auth_user_not_found;
          break;
        case 'wrong-password':
          errorMsg = loc.auth_wrong_password;
          break;
        case 'invalid-email':
          errorMsg = loc.auth_invalid_email;
          break;
        case 'user-disabled':
          errorMsg = loc.auth_user_disabled;
          break;
        case 'invalid-credential':
          errorMsg = loc.auth_invalid_credential;
          break;
        default:
          errorMsg = loc.auth_default_error;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final loc = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.unknownError(e.toString())),
          backgroundColor: Colors.red.shade400,
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
                Image.asset(
                  'assets/imgs/iconoapp.png',
                  height: 150,
                ),
                const SizedBox(height: 24),
                Text(
                  loc.login,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.loginSubtitle,
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
                      icon: Icon(_obscurePass
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePass = !_obscurePass;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : login,
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
                            loc.login,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.noAccount),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        loc.register,
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
