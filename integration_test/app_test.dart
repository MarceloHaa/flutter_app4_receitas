import 'package:app4_receitas/ui/recipes/recipes_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app4_receitas/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth E2E Test', () {
    testWidgets('deve realizar login', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byKey(ValueKey('emailField'));
      final passwordField = find.byKey(ValueKey('passwordField'));
      final submitButton = find.byKey(ValueKey('submitButton'));

      await tester.enterText(emailField, 'marcelohenrique.a@hotmail.com');
      await tester.enterText(passwordField, '123456#');
      await tester.pump();
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byType(RecipesView), findsOneWidget);
    });

    testWidgets('deve realizar cadastro', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final toggleButton = find.byKey(ValueKey('toggleButton'));
      await tester.ensureVisible(toggleButton);
      await tester.tap(toggleButton);

      final emailField = find.byKey(ValueKey('emailField'));
      final passwordField = find.byKey(ValueKey('passwordField'));
      final confirmPasswordField = find.byKey(ValueKey('confirmPasswordField'));
      final usernameField = find.byKey(ValueKey('usernameField'));
      final avatarUrlField = find.byKey(ValueKey('avatarUrlField'));

      final submitButton = find.byKey(ValueKey('submitButton'));

      await tester.enterText(emailField, 'marcelohenrique.a@hotmail.com');
      await tester.enterText(passwordField, '123456#');
      await tester.enterText(confirmPasswordField, '123456#');
      await tester.enterText(usernameField, 'Marcelo');
      await tester.enterText(
        avatarUrlField,
        'https://avatars.githubusercontent.com/MarceloHaa',
      );
      await tester.pump();

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'E-mail de confirmação enviado. Verifique sua caixa de entrada',
        ),
        findsOneWidget,
      );
    });
  });
}
