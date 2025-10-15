// lib/widgets/package_card.dart

import 'package:flutter/material.dart';
import '../models/package_model.dart';

class PackageCard extends StatelessWidget {
  // CORRIGIDO: O widget espera o parâmetro 'package' (não 'packageData')
  final Package package;
  final VoidCallback onTap;

  const PackageCard({super.key, required this.package, required this.onTap});

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      // Usando os novos enums:
      case PackageStatus.pending:
        return const Color(0xFFFEF3C7); // Amarelo Claro
      case PackageStatus.arrived:
        return const Color(0xFFD1FAE5); // Verde Claro
      case PackageStatus.delivered:
        return const Color(0xFFF3F4F6); // Cinza Claro
    }
  }

  Color _getStatusTextColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return const Color(0xFFB45309); // Amarelo Escuro
      case PackageStatus.arrived:
        return const Color(0xFF065F46); // Verde Escuro
      case PackageStatus.delivered:
        return const Color(0xFF374151); // Cinza Escuro
    }
  }

  String _getStatusText(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return 'Pendente';
      case PackageStatus.arrived:
        return 'Chegou na Caixa';
      case PackageStatus.delivered:
        return 'Retirado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.sender,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Simulação do Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(package.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getStatusText(package.status),
                      style: TextStyle(
                        color: _getStatusTextColor(package.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                package.description,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Código: ${package.trackingCode}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Previsão: ${package.estimatedDelivery}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
