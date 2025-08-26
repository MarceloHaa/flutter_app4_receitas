import 'package:app4_receitas/data/models/user_profile.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/services/auth_service.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;
  late AuthRepository authRepository;

  setUpAll(() {
    provideDummy<Either<AppError, AuthResponse>>(Right(AuthResponse()));
    provideDummy<Either<AppError, Map<String, dynamic>?>>(
      Right(<String, dynamic>{}),
    );
    provideDummy<Either<AppError, void>>(Right(null));
  });

  setUp(() {
    mockAuthService = MockAuthService();

    getIt.reset();

    getIt.registerSingleton<AuthService>(mockAuthService);

    authRepository = AuthRepository();
  });

  tearDown(() {
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
  });

  group('AuthRepository', () {
    group('currentUser', () {
      test('deve retornar UserProfile quando usario esta logado,', () async {
        //Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticates',
          createdAt: DateTime.now().toIso8601String(),
        );
        final mockProfile = {'id': 'user-id', 'username': 'testuser'};

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(
          mockAuthService.fetchUserProfile('user-id'),
        ).thenAnswer((_) async => Right(mockProfile));

        //Act
        final result = await authRepository.currentUser;

        //Assert
        expect(result.isRight, true);
      });

      test('deve retornar erro quando fechtUserProfile falha', () async {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );

        when(mockAuthService.currentUser).thenReturn(mockUser);
        when(
          mockAuthService.fetchUserProfile('user-id'),
        ).thenAnswer((_) async => Left(AppError('Erro ao carregar profile')));

        // Act
        final result = await authRepository.currentUser;

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao carregar profile'));
      });
    });

    group('signInWithPassword', () {
      test('deve retornar UserProfile quando login é bem sucedido', () async {
        // Arrange
        final mockUser = User(
          id: 'user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
        final mockAuthResponse = AuthResponse(user: mockUser);
        final mockProfile = {'id': 'user-id', 'username': 'testuser'};

        when(
          mockAuthService.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => Right(mockAuthResponse));

        when(
          mockAuthService.fetchUserProfile('user-id'),
        ).thenAnswer((_) async => Right(mockProfile));

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'password123',
        );

        // Assert
        expect(result.isRight, true);
        expect(result.right.username, equals('testuser'));
      });
      test('deve retornar erro quando credenciais são inválidas', () async {
        // Arrange
        when(
          mockAuthService.signInWithPassword(
            email: 'test@email.com',
            password: 'wrongpassword123',
          ),
        ).thenAnswer(
          (_) async =>
              Left(AppError('Usuário não cadastrado ou credenciais inválidas')),
        );

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'wrongpassword123',
        );

        // Assert
        expect(result.isLeft, true);
        expect(
          result.left.message,
          equals('Usuário não cadastrado ou credenciais inválidas'),
        );
      });
      test('deve retornar erro quando e-mail não foi confirmado', () async {
        // Arrange
        when(
          mockAuthService.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => Left(AppError('E-mail não confirmado')));

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('E-mail não confirmado'));
      });
      test(
        'deve retornar erro quando UserProfile falha após login bem sucedido',
        () async {
          // Arrange
          final mockUser = User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          );
          final mockAuthResponse = AuthResponse(user: mockUser);

          when(
            mockAuthService.signInWithPassword(
              email: 'test@email.com',
              password: 'password123',
            ),
          ).thenAnswer((_) async => Right(mockAuthResponse));

          when(
            mockAuthService.fetchUserProfile('user-id'),
          ).thenAnswer((_) async => Left(AppError('Erro ao carregar profile')));

          // Act
          final result = await authRepository.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          );

          // Assert
          expect(result.isLeft, true);
          expect(result.left.message, equals('Erro ao carregar profile'));
          verify(mockAuthService.fetchUserProfile('user-id')).called(1);
        },
      );
      test('deve retornar erro quando há problema no login', () async {
        // Arrange
        when(
          mockAuthService.signInWithPassword(
            email: 'test@email.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => Left(AppError('Erro ao fazer login')));

        // Act
        final result = await authRepository.signInWithPassword(
          email: 'test@email.com',
          password: 'password123',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao fazer login'));
      });
    });

    group('signUp', () {
      test(
        'deve retornar UserProfile quando cadastro é bem sucedido',
        () async {
          // Arrange
          final mockUser = User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          );
          final mockAuthResponse = AuthResponse(user: mockUser);
          final mockProfile = {'id': 'user-id', 'username': 'testuser'};

          when(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'https://example.com/avatar.jpg',
            ),
          ).thenAnswer((_) async => Right(mockAuthResponse));

          when(
            mockAuthService.fetchUserProfile('user-id'),
          ).thenAnswer((_) async => Right(mockProfile));

          // Act
          final result = await authRepository.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          );

          // Assert
          expect(result.isRight, true);
          expect(result.right, isA<UserProfile>());
          expect(result.right.username, equals('testuser'));
          verify(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'https://example.com/avatar.jpg',
            ),
          ).called(1);
          verify(mockAuthService.fetchUserProfile('user-id')).called(1);
        },
      );

      test('deve retornar erro quando username não está disponível', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'existinguser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('Username não disponível')));

        // Act
        final result = await authRepository.signUp(
          email: 'test@email.com',
          password: 'password123',
          username: 'existinguser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Username não disponível'));
        verify(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'existinguser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).called(1);
        verifyNever(mockAuthService.fetchUserProfile(any));
      });

      test('deve retornar erro quando e-mail já está registrado', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'existing@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('E-mail já registrado')));

        // Act
        final result = await authRepository.signUp(
          email: 'existing@email.com',
          password: 'password123',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('E-mail já registrado'));
        verify(
          mockAuthService.signUp(
            email: 'existing@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).called(1);
        verifyNever(mockAuthService.fetchUserProfile(any));
      });

      test('deve retornar erro quando há problema no cadastro', () async {
        // Arrange
        when(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).thenAnswer((_) async => Left(AppError('Erro ao registrar usuário')));

        // Act
        final result = await authRepository.signUp(
          email: 'test@email.com',
          password: 'password123',
          username: 'testuser',
          avatarUrl: 'https://example.com/avatar.jpg',
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao registrar usuário'));
        verify(
          mockAuthService.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          ),
        ).called(1);
        verifyNever(mockAuthService.fetchUserProfile(any));
      });

      test(
        'deve retornar erro quando fetchUserProfile falha após cadastro bem sucedido',
        () async {
          // Arrange
          final mockUser = User(
            id: 'user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          );
          final mockAuthResponse = AuthResponse(user: mockUser);

          when(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'https://example.com/avatar.jpg',
            ),
          ).thenAnswer((_) async => Right(mockAuthResponse));

          when(
            mockAuthService.fetchUserProfile('user-id'),
          ).thenAnswer((_) async => Left(AppError('Erro ao carregar profile')));

          // Act
          final result = await authRepository.signUp(
            email: 'test@email.com',
            password: 'password123',
            username: 'testuser',
            avatarUrl: 'https://example.com/avatar.jpg',
          );

          // Assert
          expect(result.isLeft, true);
          expect(result.left.message, equals('Erro ao carregar profile'));
          verify(
            mockAuthService.signUp(
              email: 'test@email.com',
              password: 'password123',
              username: 'testuser',
              avatarUrl: 'https://example.com/avatar.jpg',
            ),
          ).called(1);
          verify(mockAuthService.fetchUserProfile('user-id')).called(1);
        },
      );
    });
    group('signOut', () {
      test('deve retornar sucesso quando logout é bem sucedido', () async {
        // Arrange
        when(mockAuthService.signOut()).thenAnswer((_) async => Right(null));

        // Act
        final result = await authRepository.signOut();

        // Assert
        expect(result.isRight, true);
        verify(mockAuthService.signOut()).called(1);
      });
      test('deve retornar erro quando há problema no logout', () async {
        // Arrange
        when(
          mockAuthService.signOut(),
        ).thenAnswer((_) async => Left(AppError('Erro ao sair')));

        // Act
        final result = await authRepository.signOut();

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro ao sair'));
        verify(mockAuthService.signOut()).called(1);
      });
      test('deve retornar erro quando há erro inesperado no logout', () async {
        // Arrange
        when(
          mockAuthService.signOut(),
        ).thenAnswer((_) async => Left(AppError('Erro inesperado ao sair')));

        // Act
        final result = await authRepository.signOut();

        // Assert
        expect(result.isLeft, true);
        expect(result.left.message, equals('Erro inesperado ao sair'));
        verify(mockAuthService.signOut()).called(1);
      });
    });
  });
}
