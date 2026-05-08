import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../../inspection_details/data/inspection_details_repository.dart';
import '../../inspections/data/inspections_repository.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final inspectionsRepo = ref.read(inspectionsRepositoryProvider);
      final detailsRepo = ref.read(inspectionDetailsRepositoryProvider);

      if (authRepo.isGoogleUser) {
        await authRepo.reauthenticateWithGoogle();
      } else {
        await authRepo.reauthenticateWithPassword(_passwordController.text);
      }

      final ids = await inspectionsRepo.getAllUserInspectionIds();
      for (final id in ids) {
        await detailsRepo.deleteAllRoomsForInspection(id);
        await inspectionsRepo.deleteInspection(id);
      }

      await authRepo.deleteAccount();
      // O router redireciona para /login automaticamente via authStateChanges
    } catch (e) {
      if (!mounted) return;
      final String message;
      final err = e.toString();
      if (err.contains('wrong-password') || err.contains('invalid-credential')) {
        message = 'Senha incorreta. Tente novamente.';
      } else if (err.contains('requires-recent-login')) {
        message = 'Por segurança, faça logout e login novamente antes de excluir a conta.';
      } else if (err.contains('cancelada')) {
        message = 'Autenticação cancelada.';
      } else {
        message = 'Erro ao excluir a conta. Tente novamente.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showConfirmDialog() {
    final authRepo = ref.read(authRepositoryProvider);
    if (!authRepo.isGoogleUser && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite sua senha para confirmar.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text(
          'Todas as suas vistorias, fotos e dados serão excluídos permanentemente. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Excluir definitivamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGoogle = ref.read(authRepositoryProvider).isGoogleUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Excluir conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Ação irreversível',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Ao excluir sua conta, serão removidos permanentemente:'),
                  const SizedBox(height: 8),
                  const Text('• Todas as suas vistorias'),
                  const Text('• Todos os cômodos e itens registrados'),
                  const Text('• Todas as fotos enviadas'),
                  const Text('• Seus dados de perfil e acesso'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (isGoogle) ...[
              const Text(
                'Sua conta usa login com Google. Você precisará confirmar sua identidade para prosseguir.',
                style: TextStyle(fontSize: 15),
              ),
            ] else ...[
              const Text(
                'Para confirmar, digite sua senha atual:',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _isLoading ? null : _showConfirmDialog,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete_forever),
                label: Text(_isLoading ? 'Excluindo...' : 'Excluir minha conta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
