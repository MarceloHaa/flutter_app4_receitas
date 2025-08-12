import 'package:app4_receitas/ui/base_screen.dart';
import 'package:app4_receitas/ui/favorites/fav_recipes_view.dart';
import 'package:app4_receitas/ui/recipedetail/recipe_detail_view.dart';
import 'package:app4_receitas/ui/recipes/recipes_view.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  late final GoRouter router;

  static const String userId = 'a8818795-d99c-42ac-8158-e5f7a45f4c69';

  AppRouter() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => BaseScreen(child: child),
          routes: [
            GoRoute(path: '/', builder: (context, state) => RecipesView()),
            GoRoute(
              path: '/recipe/:id',
              builder: (context, state) => RecipeDetailView(
                id: state.pathParameters['id']!,
                userId: userId,
              ),
            ),
            GoRoute(
              path: '/favorites',
              builder: (context, state) => FavoriteRecipesView(userId: userId),
            ),
          ],
        ),
      ],
    );
  }
}
