import 'package:flutter/material.dart';

class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const CustomErrorScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ilustração (Ícone grande por enquanto)
              Icon(Icons.error_outline_rounded, size: 80, color: Colors.red[300]),
              const SizedBox(height: 24),
              
              const Text(
                'Ops! Algo deu errado.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'Não se preocupe, seus dados estão seguros. Tente reiniciar a tela.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}