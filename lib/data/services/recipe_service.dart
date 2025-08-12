import 'package:app4_receitas/di/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecipeService {
  final SupabaseClient _supabaseClient = getIt<SupabaseClient>();

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    return await _supabaseClient
        .from('recipes')
        .select()
        .order('id', ascending: true);
  }

  Future<Map<String, dynamic>?> fetchRecipeById(String id) async {
    return await _supabaseClient.from('recipes').select().eq('id', id).single();
  }

  Future<bool> favoriteExists({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      e;
      return false;
    }
  }

  Future<void> addFavorite({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final exists = await favoriteExists(userId: userId, recipeId: recipeId);
      if (exists) {
        print('Favorito já existe para userId: $userId, recipeId: $recipeId');
        return;
      }

      await _supabaseClient.from('favorites').insert({
        'user_id': userId,
        'recipe_id': recipeId,
      });
    } catch (e) {
      e;
      throw Exception('Falha ao adicionar favorito: ${e.toString()}');
    }
  }

  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await _supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
    } catch (e) {
      e;
      throw Exception('Falha ao remover favorito: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavRecipes(String userId) async {
    try {
      return await _supabaseClient
          .from('favorites')
          .select(''' 
          recipes(
          id,
          name,
          ingredients,
          instructions,
          prep_time_minutes,
          cook_time_minutes,
          servings,
          difficulty,
          cuisine,
          calories_per_serving,
          tags,
          user_id,
          image,
          rating,
          review_count,
          meal_type
          )
          ''')
          .eq('user_id', userId);
    } catch (e) {
      e;
      throw Exception('Falha ao buscar receitas favoritas: ${e.toString()}');
    }
  }
}
