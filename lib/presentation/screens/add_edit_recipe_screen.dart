import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/recipe.dart';
import '../../data/models/recipe_type.dart';
import '../../data/services/recipe_service.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  _AddEditRecipeScreenState createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ingredientsController;
  late TextEditingController _stepsController;

  String? _selectedRecipeTypeId;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe?.name ?? '');
    _ingredientsController = TextEditingController(
      text: widget.recipe?.ingredients.join('\n') ?? '',
    );
    _stepsController = TextEditingController(
      text: widget.recipe?.steps.join('\n') ?? '',
    );
    _selectedRecipeTypeId = widget.recipe?.recipeTypeId;
    if (widget.recipe?.imagePath.isNotEmpty ?? false) {
      _imageFile = File(widget.recipe!.imagePath);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);

      final recipe = Recipe(
        id: _isEditing ? widget.recipe!.id : const Uuid().v4(),
        name: _nameController.text,
        imagePath: _imageFile?.path ?? '',
        recipeTypeId: _selectedRecipeTypeId!,
        ingredients: _ingredientsController.text
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
        steps: _stepsController.text
            .split('\n')
            .where((s) => s.isNotEmpty)
            .toList(),
      );

      if (_isEditing) {
        recipeService.updateRecipe(recipe);
      } else {
        recipeService.addRecipe(recipe);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Add Recipe'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveRecipe),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildRecipeTypeDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients (one per line)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter ingredients' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Steps (one per line)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter steps' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null
                ? const Icon(Icons.camera_alt, size: 50)
                : null,
          ),
          FloatingActionButton.small(
            onPressed: _pickImage,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTypeDropdown() {
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    return FutureBuilder<List<RecipeType>>(
      future: recipeService.getRecipeTypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return DropdownButtonFormField<String>(
          value: _selectedRecipeTypeId,
          decoration: const InputDecoration(
            labelText: 'Recipe Type',
            border: OutlineInputBorder(),
          ),
          items: snapshot.data!.map((type) {
            return DropdownMenuItem<String>(
              value: type.id,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedRecipeTypeId = value),
          validator: (value) => value == null ? 'Please select a type' : null,
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}
