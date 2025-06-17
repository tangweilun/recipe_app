class RecipeType {
  final String id;
  final String name;

  RecipeType({required this.id, required this.name});

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(id: json['id'], name: json['name']);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
