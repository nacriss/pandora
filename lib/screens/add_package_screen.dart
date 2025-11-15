// lib/screens/add_package_screen.dart

import 'package:flutter/material.dart';
import 'package:pandora/models/user_model.dart';
import '../models/package_model.dart';
import '../services/database_service.dart';

class AddPackageScreen extends StatefulWidget {
  final String userEmail;
  final Function(Package) onPackageAdded;

  const AddPackageScreen({
    super.key,
    required this.userEmail,
    required this.onPackageAdded,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _trackingCodeController = TextEditingController();
  String _estimatedDelivery = '';

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _estimatedDelivery = pickedDate.toIso8601String().split('T').first;
      });
    });
  }

  Future<void> _handleRealAddPackage(Package newPackage) async {
    final DatabaseService databaseService = DatabaseService();
    User? uuser = await databaseService.getUserByEmail("as");

    //await databaseService.insertRealPackage(newPackage, uuser!.boxId);
    await databaseService.insertRealPackage(newPackage, uuser!.boxId);
    //await _loadRealPackge(); //encomendas
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      String cod = _trackingCodeController.text;
      final newPackage = Package(
        id: "id_$cod",
        //DateTime.now().millisecondsSinceEpoch.toString(),
        userEmail: widget.userEmail,
        sender: _senderController.text,
        description: _descriptionController.text,
        status: PackageStatus.pending,
        estimatedDelivery: "",
        trackingCode: "id_$cod",
      );

      await _handleRealAddPackage(newPackage);

      await widget.onPackageAdded(newPackage);
      Navigator.of(context).pop(); // Volta para a lista
    } /*else if (_estimatedDelivery.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Falha no cadastro!')));
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Nova Encomenda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Remetente
              TextFormField(
                controller: _senderController,
                decoration: const InputDecoration(
                  labelText: 'Remetente (Ex: Amazon, Mercado Livre)',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Produto',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // Código de Rastreio
              TextFormField(
                controller: _trackingCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Rastreio',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),

              // Data de Entrega Estimada
              /*
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _estimatedDelivery.isEmpty
                          ? 'Data de Entrega Estimada: Não selecionada'
                          : 'Entrega Estimada: ${_estimatedDelivery.substring(8, 10)}/${_estimatedDelivery.substring(5, 7)}/${_estimatedDelivery.substring(0, 4)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Selecionar Data'),
                  ),
                ],
              ),*/
              const SizedBox(height: 40),

              // Botão Cadastrar
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.add_box),
                  label: const Text(
                    'Adicionar Encomenda',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
