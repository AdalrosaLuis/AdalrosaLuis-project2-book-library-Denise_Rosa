import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acedemos ao AuthProvider usando o tipo correto
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text('Email: ${user?.email ?? "Desconhecido"}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('ID: ${user?.uid}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => authProvider.logout(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
              ),
              child: const Text('SAIR DA CONTA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}