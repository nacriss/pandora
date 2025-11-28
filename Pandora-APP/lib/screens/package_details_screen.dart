// lib/screens/package_details_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/package_model.dart';
import 'package:image_picker/image_picker.dart';

import '../services/database_service.dart';

class PackageDetailsScreen extends StatefulWidget {
  // CORRIGIDO: Agora usa 'package' em vez de 'packageData'
  final Package package;
  final Function(String, String) onUpdatePhoto;
  final Future<void> Function() onReloadData;

  const PackageDetailsScreen({
    super.key,
    required this.package, // Usando 'package'
    required this.onUpdatePhoto,
    required this.onReloadData,
  });

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  String? currentPhoto;
  final ImagePicker _picker = ImagePicker();

  // Variável para evitar o erro de 'BuildContext across async gaps'
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    currentPhoto = widget.package.photo;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return const Color(0xFFFEF3C7);
      case PackageStatus.arrived:
        return const Color(0xFFD1FAE5);
      case PackageStatus.delivered:
        return const Color(0xFFF3F4F6); // Era 'collected'
    }
  }

  Color _getStatusTextColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return const Color(0xFFB45309);
      case PackageStatus.arrived:
        return const Color(0xFF065F46);
      case PackageStatus.delivered:
        return const Color(0xFF374151); // Era 'collected'
    }
  }

  String _getStatusText(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return 'Pendente';
      case PackageStatus.arrived:
        return 'Chegou na Caixa';
      case PackageStatus.delivered:
        return 'Retirado'; // Era 'collected'
    }
  }

  // Lógica para Upload/Captura da Foto do Entregador
  Future<void> _handlePhotoUpload() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (!_isMounted) return;

      setState(() {
        //currentPhoto = base64Image;
      });

      // Chama a função de atualização no AuthWrapper (main.dart)
      widget.onUpdatePhoto(widget.package.id, base64Image);

      if (!_isMounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto da encomenda atualizada!')),
      );
    }
  }

  /*Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.camera, size: 40, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          currentPhoto == null
              ? 'Tirar foto do entregador'
              : 'Toque para trocar a foto',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ],
    );
  }*/

  // Confirmação de DELETE
  Future<bool> confirmarSaida(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirmar"),
            content: const Text("Tem certeza que deseja DELETAR?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), // Não voltar
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    final DatabaseService databaseService = DatabaseService();
                    databaseService.deletePackage(widget.package.id);
                    widget.onReloadData();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    //Navigator.of(context).pop();
                  });
                }, // Confirmar
                child: const Text("Sim"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image, size: 60, color: Colors.grey),
    );
  }

  List<String> separarPorPontoEVirgula(String? texto) {
    if (texto == null) {
      return [];
    } else {
      return texto.split(';').map((s) => s.trim()).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> fotos = separarPorPontoEVirgula(widget.package.photo);
    //fotos[0] = widget.package.photo!;
    final bool temFotos;
    if (widget.package.photo == "null") {
      temFotos = false;
      //print(widget.package.photo);
    } else {
      temFotos = true;
      //print(fotos[1]);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes da Encomenda',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título e Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.package, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.package.sender, // Usando widget.package
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Chip(
                      label: Text(
                        _getStatusText(
                          widget.package.status,
                        ), // Usando widget.package
                        style: TextStyle(
                          color: _getStatusTextColor(widget.package.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: _getStatusColor(widget.package.status),
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Descrição
                const Text(
                  'Descrição',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.package.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Rastreamento e Previsão
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rastreamento',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.package.trackingCode,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chegada',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.package.estimatedDelivery,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Foto da Encomenda / Entregador
                const Text(
                  'Foto da Encomenda / Entregador',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 250,
                  child: temFotos
                      ? PageView.builder(
                          itemCount: fotos.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(fotos[index]!),
                                fit: BoxFit.cover,
                                //errorBuilder: (context, error, stackTrace) =>
                                //  _buildUploadPlaceholder(),
                              ),
                            );
                          },
                        )
                      : _placeholder(),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: 500,
                  height: 130,

                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: IconButton(
                          iconSize: 36,
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              confirmarSaida(context);
                            });
                          },
                        ),
                      ),
                      //SizedBox(width: 12),
                      Text(
                        "Deletar",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                //SizedBox(width: 30), // espaço entre ícone e texto
              ],
            ),
          ),
        ),
      ),
    );
  }
}
