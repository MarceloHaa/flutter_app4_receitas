import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/favorites/fav_recipes_viewmodel.dart';
import 'package:app4_receitas/ui/widgets/recipe_details_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:go_router/go_router.dart';

class FavoriteRecipesView extends StatefulWidget {
  const FavoriteRecipesView({super.key, required this.userId});

  final String userId;

  @override
  State<FavoriteRecipesView> createState() => _FavoriteRecipesViewState();
}

class _FavoriteRecipesViewState extends State<FavoriteRecipesView> {
  final viewModel = getIt<FavRecipesViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.init(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Favoritas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (viewModel.isLoading) {
          return const Center(
            child: SizedBox(
              height: 96,
              width: 96,
              child: CircularProgressIndicator(strokeWidth: 12),
            ),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  Text(
                    'Erro: ${viewModel.errorMessage}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.favoriteRecipes.isEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Text(
                    'Nenhuma receita favorita',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Favorite suas receitas preferidas para vê-las aqui',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Explorar Receitas'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.favoriteRecipes.length,
          itemBuilder: (context, index) {
            final recipe = viewModel.favoriteRecipes[index];
            return _buildRecipeCard(context, recipe);
          },
        );
      }),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              recipe.image ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) =>
                  loadingProgress == null
                  ? child
                  : Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                RecipeRowDetails(recipe: recipe),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => context.go('/recipe/${recipe.id}'),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Ver Detalhes'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showRemoveDialog(context, recipe),
                      icon: const Icon(Icons.favorite),
                      label: const Text('Remover'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Favorito'),
        content: Text('Deseja remover "${recipe.name}" dos seus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await viewModel.removeFavorite(widget.userId, recipe.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${recipe.name} removido dos favoritos'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover favorito: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
