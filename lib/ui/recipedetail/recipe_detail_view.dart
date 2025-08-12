import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/recipedetail/recipe_detail_viewmodel.dart';
import 'package:app4_receitas/ui/widgets/recipe_details_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailView extends StatefulWidget {
  const RecipeDetailView({super.key, required this.id, required this.userId});

  final String id;
  final String userId;

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  final viewModel = getIt<RecipeDetailViewmodel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.loadRecipe(widget.id);
      await viewModel.checkIfFavorite(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

        if (viewModel.errorMessage != null &&
            viewModel.errorMessage!.isNotEmpty) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 32,
                children: [
                  Text(
                    'Erro: ${viewModel.errorMessage}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (viewModel.recipe == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64),
                SizedBox(height: 16),
                Text('Receita não encontrada', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        final recipe = viewModel.recipe!;
        return SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                recipe.image ?? '',
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) =>
                    loadingProgress == null
                    ? child
                    : Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                errorBuilder: (context, child, stackTrace) => Container(
                  height: 400,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecipeRowDetails(recipe: recipe),
                    const SizedBox(height: 16),
                    recipe.ingredients.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Ingredientes:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recipe.ingredients.join('\n'),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : const Text('Nenhum ingrediente listado.'),
                    const SizedBox(height: 16),
                    recipe.instructions.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Instruções:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recipe.instructions.join('\n'),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : const Text('Nenhuma instrução listada.'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('VOLTAR'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () =>
                              viewModel.toggleFavorite(widget.userId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.isFavorite
                                ? Theme.of(context).colorScheme.onTertiary
                                : Theme.of(context).colorScheme.onSecondary,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                viewModel.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                viewModel.isFavorite
                                    ? 'DESFAVORITAR'
                                    : 'FAVORITAR',
                              ),
                            ],
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
      }),
    );
  }
}
