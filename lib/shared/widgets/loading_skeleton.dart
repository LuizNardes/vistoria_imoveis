import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class InspectionListSkeleton extends StatelessWidget {
  const InspectionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega as cores base do tema para o shimmer ficar harmonioso
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // Simula 6 itens
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título Fake
                  Container(width: 200, height: 16, color: Colors.white),
                  const SizedBox(height: 12),
                  // Endereço Fake
                  Container(width: double.infinity, height: 12, color: Colors.white),
                  const SizedBox(height: 8),
                  // Data Fake
                  Container(width: 100, height: 12, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}