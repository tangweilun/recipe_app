import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/recipe_type.dart';

class RecipeService {
  late Box<Recipe> _recipeBox;
  static const String _recipeBoxName = 'recipes';
  final _uuid = const Uuid();

  Future<void> init() async {
    // Initialize Hive and register the adapter
    await Hive.initFlutter();
    Hive.registerAdapter(RecipeAdapter());
    _recipeBox = await Hive.openBox<Recipe>(_recipeBoxName);

    // Pre-populate data on first launch
    if (_recipeBox.isEmpty) {
      await _prepopulateRecipes();
    }
  }

  // --- Reactive Programming ---
  // Returns a stream of recipes. The UI will reactively update.
  // Stream<List<Recipe>> getRecipesStream() {
  //   return _recipeBox.watch().map((event) => _recipeBox.values.toList());
  // }
  Stream<List<Recipe>> getRecipesStream() async* {
    yield _recipeBox.values.toList(); // Emit initial values
    yield* _recipeBox.watch().map((event) => _recipeBox.values.toList());
  }

  // --- Initial Data Loading ---
  Future<List<RecipeType>> getRecipeTypes() async {
    final String response = await rootBundle.loadString(
      'assets/json/recipetypes.json',
    );
    final data = await json.decode(response) as List;
    return data.map((item) => RecipeType.fromJson(item)).toList();
  }

  Future<void> _prepopulateRecipes() async {
    final sampleRecipes = [
      Recipe(
        id: _uuid.v4(),
        name: 'Classic Spaghetti Carbonara',
        imagePath:
            '', // Leave empty for pre-populated or use a placeholder asset path
        recipeTypeId: 'main_course',
        ingredients: [
          '1 lb Spaghetti',
          '4 large eggs',
          '1/2 cup grated Pecorino Romano',
          '8 oz pancetta',
          'Black pepper',
        ],
        steps: [
          'Cook pasta.',
          'Fry pancetta.',
          'Mix eggs and cheese.',
          'Combine everything.',
        ],
      ),
      Recipe(
        id: _uuid.v4(),
        name: 'Chocolate Lava Cake',
        recipeTypeId: 'dessert',
        imagePath: '',
        ingredients: [
          '1/2 cup unsalted butter',
          '4 oz bittersweet chocolate',
          '2 large eggs',
          '2 egg yolks',
          '1/4 cup sugar',
          '2 tbsp flour',
        ],
        steps: [
          'Melt butter and chocolate.',
          'Whisk eggs, yolks, and sugar.',
          'Fold in flour and chocolate mixture.',
          'Bake at 450°F for 12-14 minutes.',
        ],
      ),
    ];

    for (var recipe in sampleRecipes) {
      await addRecipe(recipe);
    }
  }

  // --- CRUD Operations ---
  Future<void> addRecipe(Recipe recipe) async {
    await _recipeBox.put(recipe.id, recipe);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await recipe.save(); // HiveObjects can be saved directly
  }

  Future<void> deleteRecipe(String id) async {
    await _recipeBox.delete(id);
  }

  Recipe? getRecipeById(String id) {
    return _recipeBox.get(id);
  }
}
