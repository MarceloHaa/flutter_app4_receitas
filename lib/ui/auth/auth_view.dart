import 'package:app4_receitas/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final viewModel = getIt<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Form(
            key: viewModel.formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 16),
                    if (!viewModel.isLoginMode) ...[
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 16),
                      _buildUsernameField(),
                      const SizedBox(height: 16),
                      _buildAvatarUrlField(),
                    ],
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 32),
                    _buildToggleModeButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.restaurant_menu,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Eu Amo Cozinhar',
          style: GoogleFonts.dancingScript(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          viewModel.isLoginMode ? 'Entre na sua conta' : 'Crie uma nova conta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'E-mail',
        hintText: 'Digite seu e-mail',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: viewModel.passwordController,
        obscureText: viewModel.obscurePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: 'Senha',
          hintText: 'Digite sua senha',
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: viewModel.toggleObscurePassword,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: viewModel.validatePassword,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      obscureText: viewModel.obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Confirmar senha',
        hintText: 'Digite novamente sua senha',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: viewModel.toggleObscurePassword,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateConfirmPassword,
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: viewModel.usernameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Usuário',
        hintText: 'Digite seu nome de usuário',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateUsername,
    );
  }

  Widget _buildAvatarUrlField() {
    return TextFormField(
      controller: viewModel.avatarUrlController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'URL do Avatar',
        hintText: 'Digite a URL do seu avatar',
        prefixIcon: const Icon(Icons.image_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateAvatarUrl,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.submit,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: viewModel.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                viewModel.isLoginMode ? 'ENTRAR' : 'CADASTRAR',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleModeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          viewModel.isLoginMode ? 'Não tem uma conta? ' : 'Já tem uma conta? ',
        ),
        TextButton(
          onPressed: viewModel.isSubmitting ? null : viewModel.toggleMode,
          child: Text(
            viewModel.isLoginMode ? 'Cadastre-se' : 'Entre aqui',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
