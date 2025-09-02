// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Eu Amo Cozinhar';

  @override
  String get signInSubtitle => 'Entre na sua conta';

  @override
  String get signUpSubtitle => 'Crie uma nova conta';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'Digite seu e-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get passwordHint => 'Digite sua senha';

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get confirmPasswordHint => 'Digite novamente sua senha';

  @override
  String get usernameLabel => 'Usuário';

  @override
  String get usernameHint => 'Digite seu nome de usuário';

  @override
  String get avatarUrlLabel => 'URL do Avatar';

  @override
  String get avatarUrlHint => 'Digite a URL do seu avatar';

  @override
  String get signInButton => 'ENTRAR';

  @override
  String get signUpButton => 'CADASTRAR';

  @override
  String get noAccountQuestion => 'Não tem uma conta? ';

  @override
  String get hasAccountQuestion => 'Já tem uma conta? ';

  @override
  String get signUpLink => 'Cadastre-se';

  @override
  String get signInLink => 'Entre aqui';
}
