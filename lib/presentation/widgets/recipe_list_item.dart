import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/recipe.dart';
import '../screens/recipe_detail_screen.dart';

class RecipeListItem extends StatelessWidget {
  final Recipe recipe;

  const RecipeListItem({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          child: recipe.imagePath.isNotEmpty
              ? Image.file(
                  File(recipe.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.restaurant_menu),
                )
              : const Icon(Icons.restaurant_menu, size: 40),
        ),
        title: Text(
          recipe.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('${recipe.ingredients.length} ingredients'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
            ),
          );
        },
      ),
    );
  }
}
