import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String imagePath; // Store path to the image on the device

  @HiveField(3)
  late String recipeTypeId;

  @HiveField(4)
  late List<String> ingredients;

  @HiveField(5)
  late List<String> steps;

  Recipe({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.recipeTypeId,
    required this.ingredients,
    required this.steps,
  });
}
