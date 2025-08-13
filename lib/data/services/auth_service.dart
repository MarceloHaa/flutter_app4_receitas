import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = getIt<SupabaseClient>();

  // Retorna o usuário atual
  User? get currentUser => _supabaseClient.auth.currentUser;

  // Sign in com email e password
  Future<Either<AppError, AuthResponse>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          return Left(
            AppError('Usuário não cadastrado ou credenciais inválidas'),
          );
        case 'Email not confirmed':
          return Left(AppError('E-mail não confirmado'));
        default:
          return Left(AppError('Erro ao fazer login', e));
      }
    }
  }

  // Sign Up
  Future<Either<AppError, AuthResponse>> signUp({
    required String email,
    required String password,
    required String username,
    required String avatarUrl,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profileResult = await _createUserProfile(
          userId: response.user!.id,
          username: username,
          avatarUrl: avatarUrl,
        );

        return profileResult.fold(
          (left) => Left(left),
          (right) => Right(response),
        );
      }

      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'User already registered':
          return Left(AppError('Este e-mail já está cadastrado'));
        case 'Password should be at least 6 characters':
          return Left(AppError('A senha deve ter pelo menos 6 caracteres'));
        case 'Signup requires a valid password':
          return Left(AppError('Senha inválida'));
        case 'Invalid email format':
          return Left(AppError('Formato de e-mail inválido'));
        default:
          return Left(AppError('Erro ao criar conta: ${e.message}', e));
      }
    } catch (e) {
      return Left(AppError('Erro inesperado ao criar conta'));
    }
  }

  // Criar profile do usuário na tabela profiles
  Future<Either<AppError, void>> _createUserProfile({
    required String userId,
    required String username,
    required String avatarUrl,
  }) async {
    try {
      await _supabaseClient.from('profiles').insert({
        'id': userId,
        'username': username,
        'avatarUrl': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e) {
      return Left(AppError('Erro ao criar perfil do usuário'));
    }
  }

  // Retorna os valores da tabela profile
  Future<Either<AppError, Map<String, dynamic>?>> fetchUserProfile(
    String userId,
  ) async {
    try {
      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Right(profile);
    } catch (e) {
      return Left(AppError('Erro ao carregar profile'));
    }
  }

  // Logout
  Future<Either<AppError, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AppError('Erro ao fazer logout'));
    }
  }
}
