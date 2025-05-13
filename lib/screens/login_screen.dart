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

  void login() async {
    try {
      final user = await _authService.login(emailCtrl.text, passCtrl.text);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar sesión")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: 'Email')),
            TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Ingresar")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿No tienes cuenta?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Registrarse"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
