import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/services/recipe_service.dart';
import 'presentation/providers/recipe_provider.dart';
import 'presentation/screens/recipe_list_screen.dart';

// Asynchronously initialize services and then run the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize RecipeService (which includes Hive)
  final recipeService = RecipeService();
  await recipeService.init();

  runApp(MyApp(recipeService: recipeService));
}

class MyApp extends StatelessWidget {
  final RecipeService recipeService;

  const MyApp({super.key, required this.recipeService});

  @override
  Widget build(BuildContext context) {
    // Using MultiProvider to make services and providers available in the widget tree
    // This is a form of Dependency Injection
    return MultiProvider(
      providers: [
        // Provides the RecipeService instance to the app
        Provider<RecipeService>.value(value: recipeService),
        // Provides state for the UI, like filters
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
        title: 'Recipe App',
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const RecipeListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
