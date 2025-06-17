import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_type.dart';
import '../../data/services/recipe_service.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_list_item.dart';
import 'add_edit_recipe_screen.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _buildFilterDropdown(context, recipeService, recipeProvider),
          Expanded(
            // --- Reactive Programming: StreamBuilder listens for changes in the database ---
            child: StreamBuilder<List<Recipe>>(
              stream: recipeService.getRecipesStream(),
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final recipes = snapshot.data ?? [];
                final filteredRecipes =
                    recipes.where((recipe) {
                      final filter = recipeProvider.selectedFilter;
                      return filter == null || recipe.recipeTypeId == filter.id;
                    }).toList()..sort(
                      (a, b) => b.lastModified.compareTo(a.lastModified),
                    );

                if (filteredRecipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recipes found.\nTap the + button to add one!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return RecipeListItem(recipe: filteredRecipes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditRecipeScreen(),
            ),
          );
        },
        tooltip: 'Add Recipe',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    RecipeService recipeService,
    RecipeProvider recipeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<RecipeType>>(
        future: recipeService.getRecipeTypes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 56,
            ); // Placeholder for dropdown height
          }
          final recipeTypes = snapshot.data!;

          // Add a "All Recipes" option at the beginning
          final allTypes = [
            RecipeType(id: 'all', name: 'All Recipes'),
            ...recipeTypes,
          ];

          return DropdownButtonFormField<RecipeType>(
            decoration: InputDecoration(
              labelText: 'Filter by Recipe Type',
              border: const OutlineInputBorder(),
              suffixIcon:
                  recipeProvider.selectedFilter != null &&
                      recipeProvider.selectedFilter!.id != 'all'
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => recipeProvider.setFilter(null),
                    )
                  : null,
            ),
            value: recipeProvider.selectedFilter ?? allTypes.first,
            items: allTypes.map((type) {
              return DropdownMenuItem<RecipeType>(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (RecipeType? newValue) {
              if (newValue != null) {
                recipeProvider.setFilter(
                  newValue.id == 'all' ? null : newValue,
                );
              }
            },
          );
        },
      ),
    );
  }
}
