import 'package:flutter/material.dart';
import 'package:transfer_bank/services/auth_service.dart';
import 'package:transfer_bank/pages/login.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final password_confirmation = passwordConfirmController.text.trim();

    if (password != password_confirmation) {
      setState(() {
        isLoading = false;
        errorMessage = 'Password dan konfirmasi password tidak cocok.';
      });
      return;
    }

    final success = await AuthService.register(email, name, password, password_confirmation);

    setState(() {
      isLoading = false;
      if (success) {
        successMessage = 'Registrasi berhasil! Silakan login.';
        errorMessage = '';
      } else {
        errorMessage = 'Registrasi gagal. Cek data dan coba lagi.';
        successMessage = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: passwordConfirmController,
              decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: const Text('Register'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // kembali ke halaman login
              },
              child: const Text('Sudah punya akun? Login'),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            ],
            if (successMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(successMessage, style: const TextStyle(color: Colors.green)),
            ],
          ],
        ),
      ),
    );
  }
}
