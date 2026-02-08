import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Adicione intl ao pubspec para formatar a data
import 'create_inspection_controller.dart';

class CreateInspectionScreen extends ConsumerStatefulWidget {
  const CreateInspectionScreen({super.key});

  @override
  ConsumerState<CreateInspectionScreen> createState() => _CreateInspectionScreenState();
}

class _CreateInspectionScreenState extends ConsumerState<CreateInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers de texto
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController(); // Apenas visual
  
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Função auxiliar para abrir o DatePicker
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now, // Não permite agendar no passado
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Escuta passiva para feedback (Sucesso/Erro)
    ref.listen(createInspectionControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao agendar: ${error.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vistoria agendada com sucesso!')),
          );
          context.pop(); // Fecha a tela e volta para a Home
        },
      );
    });

    // 2. Observa o estado para Loading do botão
    final state = ref.watch(createInspectionControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Vistoria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Nome do Cliente ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Informe o nome do cliente' : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // --- Endereço ---
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço do Imóvel',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Informe o endereço' : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // --- Data (Read-only + Tap) ---
              TextFormField(
                controller: _dateController,
                readOnly: true, // Impede digitação manual
                onTap: isLoading ? null : _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Data da Vistoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                validator: (value) =>
                    _selectedDate == null ? 'Selecione uma data' : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),

              // --- Botão de Ação ---
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          // Dispara a mutação no controller
                          ref.read(createInspectionControllerProvider.notifier).submit(
                                clientName: _nameController.text.trim(),
                                address: _addressController.text.trim(),
                                date: _selectedDate!,
                              );
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('AGENDAR VISTORIA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}