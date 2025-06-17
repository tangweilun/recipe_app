import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recipe.dart';
import '../../data/services/recipe_service.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    // Using a Watch stream from Hive is a bit complex here, so we'll re-fetch on build
    // A more advanced solution could use a dedicated provider for this screen.
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final Recipe? recipe = recipeService.getRecipeById(recipeId);

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Recipe not found! It may have been deleted.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditRecipeScreen(recipe: recipe),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, recipeService, recipe),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imagePath.isNotEmpty)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: Image.file(File(recipe.imagePath)),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            for (var ingredient in recipe.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('• $ingredient'),
              ),
            const SizedBox(height: 24),
            Text('Steps', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            for (int i = 0; i < recipe.steps.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('${i + 1}. ${recipe.steps[i]}'),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RecipeService service,
    Recipe recipe,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Do you want to delete the recipe "${recipe.name}"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              service.deleteRecipe(recipe.id);
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to list screen
            },
          ),
        ],
      ),
    );
  }
}
