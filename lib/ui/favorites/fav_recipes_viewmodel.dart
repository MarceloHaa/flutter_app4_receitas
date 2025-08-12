import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:get/get.dart';

class FavRecipesViewModel extends GetxController {
  final _repository = getIt<RecipeRepository>();

  final RxList<Recipe> _favoriteRecipes = <Recipe>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  bool _isInitialized = false;

  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasError => _errorMessage.value.isNotEmpty;

  Future<void> init(String userId) async {
    if (_isInitialized) return;
    await loadFavoriteRecipes(userId);
    _isInitialized = true;
  }

  Future<void> loadFavoriteRecipes(String userId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final recipes = await _repository.getFavRecipes(userId);
      _favoriteRecipes.assignAll(recipes);
    } catch (e) {
      _errorMessage.value =
          'Falha ao carregar receitas favoritas: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addFavorite(String userId, Recipe recipe) async {
    try {
      _errorMessage.value = '';

      await _repository.addFavorite(userId, recipe.id);

      if (!_favoriteRecipes.any((r) => r.id == recipe.id)) {
        _favoriteRecipes.add(recipe);
      }
    } catch (e) {
      _errorMessage.value = 'Falha ao adicionar favorito: ${e.toString()}';
      throw e;
    }
  }

  Future<void> removeFavorite(String userId, String recipeId) async {
    try {
      _errorMessage.value = '';

      await _repository.removeFavorite(userId, recipeId);

      _favoriteRecipes.removeWhere((recipe) => recipe.id == recipeId);
    } catch (e) {
      _errorMessage.value = 'Falha ao remover favorito: ${e.toString()}';
      throw e;
    }
  }

  void addLocal(Recipe recipe) {
    if (!_favoriteRecipes.any((r) => r.id == recipe.id)) {
      _favoriteRecipes.add(recipe);
    }
  }

  void removeLocal(String recipeId) {
    _favoriteRecipes.removeWhere((recipe) => recipe.id == recipeId);
  }

  bool isFavorite(String recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
