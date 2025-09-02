// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'I Love Cooking';

  @override
  String get signInSubtitle => 'Sign in to your account';

  @override
  String get signUpSubtitle => 'Create a new account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Enter your password again';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get avatarUrlLabel => 'Avatar URL';

  @override
  String get avatarUrlHint => 'Enter your avatar URL';

  @override
  String get signInButton => 'SIGN IN';

  @override
  String get signUpButton => 'SIGN UP';

  @override
  String get noAccountQuestion => 'Don\'t have an account? ';

  @override
  String get hasAccountQuestion => 'Already have an account? ';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get signInLink => 'Sign in here';
}
