import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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

  void login() async {
    try {
      final user = await _authService.login(emailCtrl.text, passCtrl.text);
      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'No hay usuario con ese correo.';
          break;
        case 'wrong-password':
          errorMsg = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          errorMsg = 'El correo ingresado no es válido.';
          break;
        case 'user-disabled':
          errorMsg = 'Este usuario ha sido deshabilitado.';
          break;
        default:
          errorMsg = 'Error inesperado. Intenta nuevamente.';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error desconocido: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
        ),
      );
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: BackButton(),
                ),
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.lock_outline, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 24),
                const Text("Iniciar sesión",
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Accede a tu cuenta",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),

                // Email
                TextField(
                  controller: emailCtrl,
                  decoration: customInputDecoration('Email'),
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: _obscurePass,
                  decoration: customInputDecoration('Contraseña').copyWith(
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
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Iniciar sesión",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes cuenta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text("Registrarse", style: TextStyle(color: Color(0xFF007BFF)),),
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
