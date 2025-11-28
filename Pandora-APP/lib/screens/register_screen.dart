// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para input formatters

typedef OnRegistered =
    Future<void> Function(
      String email,
      String password,
      String boxId,
      String? phone, // AGORA SÃO 4 ARGUMENTOS
    );

class RegisterScreen extends StatefulWidget {
  final OnRegistered onRegistered;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegistered,
    required this.onBackToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para capturar os dados do formulário
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _boxIdController = TextEditingController();
  final _phoneController = TextEditingController(); // Novo campo

  @override
  void dispose() {
    // Liberar controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _boxIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    // Validação de senhas
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem!')));
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Chama a função assíncrona para salvar no SQLite e tentar logar
      await widget.onRegistered(
        _emailController.text,
        _passwordController.text,
        _boxIdController.text,
        _phoneController.text.isEmpty
            ? null
            : _phoneController.text, // NOVO ARG
      );
      // O restante da navegação é tratado no AuthWrapper após o sucesso do registro/login.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criação de Conta Pandora'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToLogin,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cadastre seus dados e sua Smart Box',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 1. Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@')
                    ? 'Insira um email válido'
                    : null,
              ),
              const SizedBox(height: 16),

              // 2. Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'A senha deve ter pelo menos 6 caracteres'
                    : null,
              ),
              const SizedBox(height: 16),

              // 3. Confirmação de Senha
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Confirme sua senha';
                  if (value != _passwordController.text)
                    return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 4. Cadastro da Caixa (Até 5 dígitos)
              TextFormField(
                controller: _boxIdController,
                decoration: const InputDecoration(
                  labelText: 'ID da sua Smart Box (5 dígitos)',
                  hintText: 'Ex: 12345',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (value) =>
                    value!.length != 5 ? 'O ID deve ter 5 dígitos' : null,
              ),
              const SizedBox(height: 16),

              // 5. Celular
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Celular (Opcional)',
                  hintText: '(DD) 99999-9999',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                // Uma validação mais rigorosa seria recomendada aqui, mas
                // deixamos opcional para simplificar.
              ),
              const SizedBox(height: 32),

              // Botão Cadastrar
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cadastrar e Entrar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: widget.onBackToLogin,
                child: const Text('Já tenho conta. Voltar para Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
