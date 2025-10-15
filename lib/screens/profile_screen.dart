// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final User currentUser;
  final Future<void> Function(User) onUserUpdated;

  const ProfileScreen({
    super.key,
    required this.currentUser,
    required this.onUserUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _boxIdController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _boxIdController = TextEditingController(text: widget.currentUser.boxId);
    _phoneController = TextEditingController(
      text: widget.currentUser.phone ?? '',
    );
  }

  @override
  void dispose() {
    _boxIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        email: widget.currentUser.email,
        password: widget.currentUser.password, // Mantém a senha
        boxId: _boxIdController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );

      await widget.onUserUpdated(updatedUser);
      _toggleEditMode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
      }
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isEditable = false,
    Widget? field,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isEditable
                ? field!
                : Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Email (Não Editável)
                      _buildDetailRow('Email', widget.currentUser.email),
                      const Divider(),

                      // ID da Caixa (Editável)
                      _buildDetailRow(
                        'ID da Caixa',
                        _boxIdController.text,
                        isEditable: _isEditing,
                        field: TextFormField(
                          controller: _boxIdController,
                          enabled: _isEditing,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.length != 5
                              ? 'O ID deve ter 5 dígitos'
                              : null,
                        ),
                      ),
                      const Divider(),

                      // Celular (Editável)
                      _buildDetailRow(
                        'Celular',
                        _phoneController.text.isNotEmpty
                            ? _phoneController.text
                            : 'Não Informado',
                        isEditable: _isEditing,
                        field: TextFormField(
                          controller: _phoneController,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: _toggleEditMode,
                    child: const Text('Cancelar Edição'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
