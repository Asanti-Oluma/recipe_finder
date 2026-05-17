class Meal {
  final String idMeal;
  final String strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final List<MapEntry<String, String>> ingredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    this.ingredients = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <MapEntry<String, String>>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(MapEntry(ingredient, measure ?? ''));
      }
    }
    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strInstructions: json['strInstructions'],
      strMealThumb: json['strMealThumb'],
      strYoutube: json['strYoutube'],
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() => {
        'idMeal': idMeal,
        'strMeal': strMeal,
        'strCategory': strCategory,
        'strArea': strArea,
        'strInstructions': strInstructions,
        'strMealThumb': strMealThumb,
        'strYoutube': strYoutube,
      };

  Meal copyWith({
    String? idMeal,
    String? strMeal,
    String? strCategory,
    String? strArea,
    String? strInstructions,
    String? strMealThumb,
    String? strYoutube,
    List<MapEntry<String, String>>? ingredients,
  }) {
    return Meal(
      idMeal: idMeal ?? this.idMeal,
      strMeal: strMeal ?? this.strMeal,
      strCategory: strCategory ?? this.strCategory,
      strArea: strArea ?? this.strArea,
      strInstructions: strInstructions ?? this.strInstructions,
      strMealThumb: strMealThumb ?? this.strMealThumb,
      strYoutube: strYoutube ?? this.strYoutube,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

class MealCategory {
  final String idCategory;
  final String strCategory;
  final String? strCategoryThumb;
  final String? strCategoryDescription;

  MealCategory({
    required this.idCategory,
    required this.strCategory,
    this.strCategoryThumb,
    this.strCategoryDescription,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) => MealCategory(
        idCategory: json['idCategory'] ?? '',
        strCategory: json['strCategory'] ?? '',
        strCategoryThumb: json['strCategoryThumb'],
        strCategoryDescription: json['strCategoryDescription'],
      );
}
