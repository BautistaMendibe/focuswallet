import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _authService = AuthService();

  void login() async {
    try {
      final user = await _authService.register(emailCtrl.text, passCtrl.text);
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
      appBar: AppBar(title: const Text("Registrarse")),
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
            ElevatedButton(onPressed: login, child: const Text("Registrarse")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("¿Ya tienes cuenta?"),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text("Iniciar sesión"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
