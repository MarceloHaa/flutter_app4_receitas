import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/l10n/app_localizations.dart';
import 'package:app4_receitas/ui/widgets/language_selector.dart';
import 'package:app4_receitas/utils/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_viewmodel.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView>
    with SingleTickerProviderStateMixin {
  final viewModel = getIt<AuthViewModel>();

  late AnimationController _animationController;
  //  late Animation<double> _animation;

  final localeController = Get.find<LocaleController>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    //)..addStatusListener((listener) {});
    //_animation = Tween(begin: 50.0, end: 200.0).animate(_animationController);
    //_animation.addListener(() => setState(() {}));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Form(
                key: viewModel.formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(l10n),
                        const SizedBox(height: 32),
                        _buildEmailField(l10n),
                        const SizedBox(height: 16),
                        _buildPasswordField(l10n),
                        const SizedBox(height: 16),
                        if (!viewModel.isLoginMode) ...[
                          _buildConfirmPasswordField(l10n),
                          const SizedBox(height: 16),
                          _buildUsernameField(l10n),
                          const SizedBox(height: 16),
                          _buildAvatarUrlField(l10n),
                        ],
                        const SizedBox(height: 32),
                        _buildErrorMessage(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(l10n),
                        const SizedBox(height: 32),
                        _buildToggleModeButton(l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 32,
            right: 8,
            child: Obx(
              () => LanguageSelector(
                onLanguageChanged: localeController.changeLocale,
                currentLocale: localeController.locale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        _animatedLogo(controller: _animationController),
        const SizedBox(height: 16),
        Text(
          l10n.appTitle,
          style: GoogleFonts.dancingScript(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          viewModel.isLoginMode ? l10n.signInSubtitle : l10n.signUpSubtitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
        ),
      ],
    );
  }

  Widget _animatedLogo({required AnimationController controller}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final sizeTween = Tween(
          begin: 50.0,
          end: 200.0,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

        final colorTween =
            ColorTween(
              begin: Theme.of(context).colorScheme.onError,
              end: Theme.of(context).colorScheme.primary,
            ).animate(
              CurvedAnimation(parent: controller, curve: Curves.bounceInOut),
            );

        final angleTween = Tween(
          begin: 0.0,
          end: 2 * 3.14,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

        return Transform.rotate(
          angle: angleTween.value,
          child: SizedBox(
            height: 200,
            child: Icon(
              Icons.restaurant_menu,
              size: sizeTween.value,
              color: colorTween.value,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return TextFormField(
      key: ValueKey('emailField'),
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.emailLabel,
        hintText: l10n.emailHint,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Obx(
      () => TextFormField(
        key: ValueKey('passwordField'),
        controller: viewModel.passwordController,
        obscureText: viewModel.obscurePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: l10n.passwordLabel,
          hintText: l10n.passwordHint,
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

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return TextFormField(
      key: ValueKey('confirmPasswordField'),
      controller: viewModel.confirmPasswordController,
      obscureText: viewModel.obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.confirmPasswordLabel,
        hintText: l10n.confirmPasswordHint,
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

  Widget _buildUsernameField(AppLocalizations l10n) {
    return TextFormField(
      key: ValueKey('usernameField'),
      controller: viewModel.usernameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.usernameLabel,
        hintText: l10n.usernameHint,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateUsername,
    );
  }

  Widget _buildAvatarUrlField(AppLocalizations l10n) {
    return TextFormField(
      key: ValueKey('avatarUrlField'),
      controller: viewModel.avatarUrlController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.avatarUrlLabel,
        hintText: l10n.avatarUrlHint,
        prefixIcon: const Icon(Icons.image_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateAvatarUrl,
    );
  }

  Widget _buildErrorMessage() {
    return Obx(
      () => Visibility(
        visible: viewModel.errorMessage.isNotEmpty,
        child: Text(
          viewModel.errorMessage,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
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
                viewModel.isLoginMode ? l10n.signInButton : l10n.signUpButton,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleModeButton(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          viewModel.isLoginMode
              ? l10n.noAccountQuestion
              : l10n.hasAccountQuestion,
        ),
        TextButton(
          onPressed: viewModel.isSubmitting ? null : viewModel.toggleMode,
          child: Text(
            viewModel.isLoginMode ? l10n.signUpLink : l10n.signInLink,
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
