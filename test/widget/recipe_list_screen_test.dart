import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/data/models/recipe.dart';
import 'package:recipe_app/data/models/recipe_type.dart';
import 'package:recipe_app/data/services/recipe_service.dart';
import 'package:recipe_app/presentation/providers/recipe_provider.dart';
import 'package:recipe_app/presentation/screens/recipe_list_screen.dart';
import 'package:recipe_app/presentation/screens/add_edit_recipe_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';
import 'recipe_list_screen_test.mocks.dart';

@GenerateMocks([RecipeService])
void main() {
  late MockRecipeService mockRecipeService;
  late RecipeProvider recipeProvider;

  setUp(() {
    mockRecipeService = MockRecipeService();
    recipeProvider = RecipeProvider();

    // Mock the recipe types stream
    when(mockRecipeService.getRecipeTypes()).thenAnswer(
      (_) async => [
        RecipeType(id: '1', name: 'Breakfast'),
        RecipeType(id: '2', name: 'Lunch'),
      ],
    );

    // Mock the recipes stream
    when(mockRecipeService.getRecipesStream()).thenAnswer(
      (_) => Stream.value([
        Recipe(
          id: '1',
          name: 'Test Recipe 1',
          imagePath: '',
          recipeTypeId: '1',
          ingredients: ['ingredient 1', 'ingredient 2'],
          steps: ['step 1', 'step 2'],
        ),
        Recipe(
          id: '2',
          name: 'Test Recipe 2',
          imagePath: '',
          recipeTypeId: '2',
          ingredients: ['ingredient 1'],
          steps: ['step 1'],
        ),
      ]),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<RecipeService>.value(value: mockRecipeService),
          ChangeNotifierProvider<RecipeProvider>.value(value: recipeProvider),
        ],
        child: const RecipeListScreen(),
      ),
    );
  }

  group('RecipeListScreen Widget Tests', () {
    testWidgets('displays app bar with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('My Recipes'), findsOneWidget);
    });

    testWidgets('displays recipe list when data is available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Test Recipe 1'), findsOneWidget);
      expect(find.text('Test Recipe 2'), findsOneWidget);
      expect(find.text('2 ingredients'), findsOneWidget);
      expect(find.text('1 ingredients'), findsOneWidget);
    });

    testWidgets('displays filter dropdown with recipe types', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // First pump for initial build
      await tester.pump(); // Second pump for FutureBuilder
      await tester.pumpAndSettle();

      expect(find.text('Filter by Recipe Type'), findsOneWidget);

      // Find the dropdown button
      final dropdownFinder = find.byType(DropdownButtonFormField<RecipeType>);
      expect(dropdownFinder, findsOneWidget);

      // Verify the selected value is shown
      expect(find.text('All Recipes'), findsOneWidget);

      // Tap the dropdown to open it
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Verify dropdown items
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('filters recipes by type', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // First pump for initial build
      await tester.pump(); // Second pump for FutureBuilder
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<RecipeType>));
      await tester.pumpAndSettle();

      // Select Breakfast type
      await tester.tap(find.text('Breakfast').last);
      await tester.pumpAndSettle();

      // Verify only Breakfast recipe is shown
      expect(find.text('Test Recipe 1'), findsOneWidget);
      expect(find.text('Test Recipe 2'), findsNothing);
    });

    testWidgets('shows error message when stream has error', (
      WidgetTester tester,
    ) async {
      when(
        mockRecipeService.getRecipesStream(),
      ).thenAnswer((_) => Stream.error('Test error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Error: Test error'), findsOneWidget);
    });

    testWidgets('shows empty state message when no recipes', (
      WidgetTester tester,
    ) async {
      when(
        mockRecipeService.getRecipesStream(),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(
        find.text('No recipes found.\nTap the + button to add one!'),
        findsOneWidget,
      );
    });

    testWidgets('clears filter when clear button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // First pump for initial build
      await tester.pump(); // Second pump for FutureBuilder
      await tester.pumpAndSettle();

      // Select a filter
      await tester.tap(find.byType(DropdownButtonFormField<RecipeType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Breakfast').last);
      await tester.pumpAndSettle();

      // Verify clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Verify all recipes are shown again
      expect(find.text('Test Recipe 1'), findsOneWidget);
      expect(find.text('Test Recipe 2'), findsOneWidget);
    });
  });
}
