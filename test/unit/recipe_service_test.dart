import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/data/services/recipe_service.dart';
import 'package:recipe_app/data/models/recipe.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'recipe_service_test.mocks.dart';

@GenerateMocks([RecipeService])
void main() {
  late MockRecipeService mockRecipeService;

  setUp(() {
    mockRecipeService = MockRecipeService();
  });

  group('RecipeService Tests', () {
    test('getRecipesStream returns sorted stream of recipes', () async {
      // Arrange
      final recipes = [
        Recipe(
          id: '1',
          name: 'Recipe 1',
          imagePath: '',
          recipeTypeId: 'main_course',
          ingredients: ['ingredient 1'],
          steps: ['step 1'],
        ),
        Recipe(
          id: '2',
          name: 'Recipe 2',
          imagePath: '',
          recipeTypeId: 'dessert',
          ingredients: ['ingredient 1'],
          steps: ['step 1'],
        ),
      ];

      when(
        mockRecipeService.getRecipesStream(),
      ).thenAnswer((_) => Stream.value(recipes));

      // Act
      final result = await mockRecipeService.getRecipesStream().first;

      // Assert
      expect(result, isA<List<Recipe>>());
      expect(result.length, 2);
      verify(mockRecipeService.getRecipesStream()).called(1);
    });

    test('getRecipeById returns null when recipe does not exist', () async {
      // Arrange
      const recipeId = 'non_existent_id';
      when(mockRecipeService.getRecipeById(recipeId)).thenReturn(null);

      // Act
      final result = mockRecipeService.getRecipeById(recipeId);

      // Assert
      expect(result, isNull);
      verify(mockRecipeService.getRecipeById(recipeId)).called(1);
    });

    test('getRecipeById returns recipe when it exists', () async {
      // Arrange
      const recipeId = '1';
      final recipe = Recipe(
        id: recipeId,
        name: 'Test Recipe',
        imagePath: '',
        recipeTypeId: 'main_course',
        ingredients: ['ingredient 1'],
        steps: ['step 1'],
      );
      when(mockRecipeService.getRecipeById(recipeId)).thenReturn(recipe);

      // Act
      final result = mockRecipeService.getRecipeById(recipeId);

      // Assert
      expect(result, isNotNull);
      expect(result?.id, equals(recipeId));
      expect(result?.name, equals('Test Recipe'));
      verify(mockRecipeService.getRecipeById(recipeId)).called(1);
    });

    test('addRecipe adds a new recipe', () async {
      // Arrange
      final recipe = Recipe(
        id: '1',
        name: 'New Recipe',
        imagePath: '',
        recipeTypeId: 'main_course',
        ingredients: ['ingredient 1'],
        steps: ['step 1'],
      );
      when(mockRecipeService.addRecipe(recipe)).thenAnswer((_) async {});

      // Act
      await mockRecipeService.addRecipe(recipe);

      // Assert
      verify(mockRecipeService.addRecipe(recipe)).called(1);
    });

    test('updateRecipe updates existing recipe', () async {
      // Arrange
      final recipe = Recipe(
        id: '1',
        name: 'Updated Recipe',
        imagePath: '',
        recipeTypeId: 'main_course',
        ingredients: ['ingredient 1'],
        steps: ['step 1'],
      );
      when(mockRecipeService.updateRecipe(recipe)).thenAnswer((_) async {});

      // Act
      await mockRecipeService.updateRecipe(recipe);

      // Assert
      verify(mockRecipeService.updateRecipe(recipe)).called(1);
    });

    test('deleteRecipe removes recipe', () async {
      // Arrange
      const recipeId = '1';
      when(mockRecipeService.deleteRecipe(recipeId)).thenAnswer((_) async {});

      // Act
      await mockRecipeService.deleteRecipe(recipeId);

      // Assert
      verify(mockRecipeService.deleteRecipe(recipeId)).called(1);
    });
  });
}
