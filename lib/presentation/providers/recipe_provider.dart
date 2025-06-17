import 'package:flutter/foundation.dart';
import '../../data/models/recipe_type.dart';

class RecipeProvider with ChangeNotifier {
  RecipeType? _selectedFilter;

  RecipeType? get selectedFilter => _selectedFilter;

  void setFilter(RecipeType? filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
