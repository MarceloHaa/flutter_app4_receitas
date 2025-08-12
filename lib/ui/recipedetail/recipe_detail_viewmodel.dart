import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/favorites/fav_recipes_viewmodel.dart';
import 'package:get/get.dart';

class RecipeDetailViewmodel extends GetxController {
  final _repository = getIt<RecipeRepository>();

  final Rxn<Recipe> _recipe = Rxn<Recipe>();
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isFavorite = false.obs;
  bool _busy = false;

  Recipe? get recipe => _recipe.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  bool get isFavorite => _isFavorite.value;

  Future<void> loadRecipe(String id) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final loadedRecipe = await _repository.getRecipeById(id);
      if (loadedRecipe == null) {
        _errorMessage.value = 'Receita não encontrada';
      } else {
        _recipe.value = loadedRecipe;
      }
    } catch (e) {
      _errorMessage.value = 'Falha ao buscar receita: ${e.toString()}';
      _recipe.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> checkIfFavorite(String userId) async {
    if (recipe == null) return;

    try {
      final favRecipes = await _repository.getFavRecipes(userId);
      _isFavorite.value = favRecipes.any((r) => r.id == recipe!.id);
    } catch (e) {
      _errorMessage.value = 'Falha ao verificar favorito: ${e.toString()}';
    }
  }

  Future<void> toggleFavorite(String userId) async {
    if (recipe == null || _busy) return;
    _busy = true;

    final favVm = getIt<FavRecipesViewModel>();
    await favVm.init(userId);

    try {
      if (_isFavorite.value) {
        await _repository.removeFavorite(userId, recipe!.id);
        favVm.removeLocal(recipe!.id);
        _isFavorite.value = false;
      } else {
        await _repository.addFavorite(userId, recipe!.id);
        favVm.addLocal(recipe!);
        _isFavorite.value = true;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _busy = false;
    }
  }
}
