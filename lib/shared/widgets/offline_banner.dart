import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';

class OfflineBannerWrapper extends ConsumerWidget {
  final Widget child;

  const OfflineBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(networkStatusProvider);

    // Default é online para não assustar no boot
    final isOffline = statusAsync.valueOrNull == NetworkStatus.offline;

    return Column(
      children: [
        Expanded(child: child),
        
        // Banner Animado
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOffline ? 40 : 0, // Altura dinâmica
          color: const Color(0xFFFFA000), // Amber escuro (Aviso)
          child: isOffline
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sem conexão. Modo Offline ativado.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}