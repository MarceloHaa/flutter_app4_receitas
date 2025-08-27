import 'package:app4_receitas/data/models/user_profile.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/services/auth_service.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/auth/auth_view.dart';
import 'package:app4_receitas/ui/auth/auth_viewmodel.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './auth_view_test.mocks.dart';

@GenerateMocks([AuthRepository, AuthService])
void main() {
  late MockAuthService mockAuthService;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    provideDummy<Either<AppError, UserProfile>>(
      Right(
        UserProfile(
          id: 'test-user-id',
          email: 'test@email.com',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      ),
    );
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAuthRepository = MockAuthRepository();

    Get.reset();
    getIt.reset();
    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<AuthRepository>(mockAuthRepository);
    getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  });

  tearDown(() {
    Get.reset();
    getIt.reset();
  });
  group('AuthView', () {
    testWidgets('deve verificar o título', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthView()));
      await tester.pumpAndSettle();

      final titleFinder = find.text('Eu Amo Cozinhar');

      expect(titleFinder, findsOneWidget);
      final Text titleText = tester.widget(titleFinder);
      expect(titleText.style?.fontSize, 48);
      expect(titleText.style?.fontWeight, FontWeight.w700);
      expect(
        titleText.style?.fontFamilyFallback,
        equals(GoogleFonts.dancingScript().fontFamilyFallback),
      );
    });

    testWidgets('deve realizar login', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthView()));
      await tester.pumpAndSettle();

      final emailField = find.byKey(ValueKey('emailField'));
      final passwordField = find.byKey(ValueKey('passwordField'));
      final submitButton = find.byKey(ValueKey('submitButton'));

      when(
        mockAuthRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'Teste123!@#',
        ),
      ).thenAnswer(
        (_) async => Right(
          UserProfile(
            id: 'test-user-id',
            email: 'test@email.com',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ),
      );

      await tester.enterText(emailField, 'test@email.com');
      await tester.enterText(passwordField, 'Teste123!@#');
      await tester.pump();

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(
        mockAuthRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'Teste123!@#',
        ),
      ).called(1);
    });
  });
}
