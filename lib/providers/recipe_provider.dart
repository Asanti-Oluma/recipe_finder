import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_api_service.dart';

enum LoadingState { idle, loading, success, error }

class RecipeProvider extends ChangeNotifier {
  final MealApiService _apiService;

  RecipeProvider({MealApiService? apiService})
      : _apiService = apiService ?? MealApiService();

  //  State
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  List<Meal> _meals = [];
  List<MealCategory> _categories = [];
  Meal? _selectedMeal;
  String _searchQuery = '';
  String? _selectedCategory;

  // Local CRUD: favourites list (simulates Create / Delete on client side)
  final List<Meal> _favourites = [];

  // Getters
  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  List<Meal> get meals => List.unmodifiable(_meals);
  List<MealCategory> get categories => List.unmodifiable(_categories);
  Meal? get selectedMeal => _selectedMeal;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  List<Meal> get favourites => List.unmodifiable(_favourites);
  bool get isLoading => _state == LoadingState.loading;

  bool isFavourite(String mealId) => _favourites.any((m) => m.idMeal == mealId);

  // READ: Search meals
  Future<void> searchMeals(String query) async {
    if (query.trim().isEmpty) {
      _meals = [];
      _searchQuery = '';
      _setState(LoadingState.idle);
      return;
    }
    _searchQuery = query;
    _setState(LoadingState.loading);
    try {
      _meals = await _apiService.searchMealsByName(query);
      _setState(LoadingState.success);
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  //  READ: Load categories
  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;
    _setState(LoadingState.loading);
    try {
      _categories = await _apiService.getCategories();
      _setState(LoadingState.success);
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  //  READ: Filter by category
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    _setState(LoadingState.loading);
    try {
      _meals = await _apiService.filterByCategory(category);
      _setState(LoadingState.success);
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // READ: Meal detail
  Future<void> loadMealDetail(String id) async {
    _selectedMeal = null;
    _setState(LoadingState.loading);
    try {
      _selectedMeal = await _apiService.getMealById(id);
      _setState(LoadingState.success);
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  //  READ: Random meal
  Future<void> loadRandomMeal() async {
    _setState(LoadingState.loading);
    try {
      final meal = await _apiService.getRandomMeal();
      if (meal != null) {
        _selectedMeal = meal;
        _meals = [meal];
      }
      _setState(LoadingState.success);
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Unexpected error: $e');
    }
  }

  // CREATE (local): Add to favourites
  void addFavourite(Meal meal) {
    if (!isFavourite(meal.idMeal)) {
      _favourites.add(meal);
      notifyListeners();
    }
  }

  // UPDATE (local): Update notes / custom name in favourites
  void updateFavourite(String mealId, {String? customName}) {
    final index = _favourites.indexWhere((m) => m.idMeal == mealId);
    if (index != -1 && customName != null) {
      _favourites[index] = _favourites[index].copyWith(strMeal: customName);
      notifyListeners();
    }
  }

  // DELETE (local): Remove from favourites
  void removeFavourite(String mealId) {
    _favourites.removeWhere((m) => m.idMeal == mealId);
    notifyListeners();
  }

  void clearSearch() {
    _meals = [];
    _searchQuery = '';
    _selectedCategory = null;
    _setState(LoadingState.idle);
  }

  // Helpers
  void _setState(LoadingState s) {
    _state = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _state = LoadingState.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
