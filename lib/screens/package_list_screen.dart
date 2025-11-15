// lib/screens/package_list_screen.dart

import 'package:flutter/material.dart';
import '../models/package_model.dart';
import 'package_details_screen.dart'; // Assumindo que esta tela existe
import '../widgets/package_card.dart'; // Assumindo que este widget existe

class PackageListScreen extends StatelessWidget {
  final List<Package> packages;
  final Function() onAddPackageRequested;
  final Function(String, String)
  onUpdatePhoto; // Necessário para a tela de detalhes
  final Future<void> Function() onReloadData;

  const PackageListScreen({
    super.key,
    required this.packages,
    required this.onAddPackageRequested,
    required this.onUpdatePhoto,
    /*required Future<void> Function() onReloadData,*/ required this.onReloadData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adicionei o Scaffold aqui para o FAB
      appBar: AppBar(title: const Text('Suas Encomendas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (packages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Text(
                    'Nenhuma encomenda cadastrada.\nClique no "+" para adicionar uma!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              // CORREÇÃO DE OVERFLOW: Envolver o ListView.separated em um Expanded
              Expanded(
                child: ListView.separated(
                  itemCount: packages.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return PackageCard(
                      package: package,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => PackageDetailsScreen(
                              package: package,
                              onUpdatePhoto: onUpdatePhoto,
                              onReloadData: this.onReloadData,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      // NOVO: Botão Flutuante (FAB) para Adicionar Encomenda
      floatingActionButton: FloatingActionButton(
        onPressed: onAddPackageRequested,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
