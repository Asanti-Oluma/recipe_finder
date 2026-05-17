import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final http.Client _client;

  MealApiService({http.Client? client}) : _client = client ?? http.Client();

  // READ - Search meals by name
  Future<List<Meal>> searchMealsByName(String query) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/search.php?s=${Uri.encodeComponent(query)}'),
    );
    _handleResponseError(response);
    final data = json.decode(response.body);
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];
    return meals.map((m) => Meal.fromJson(m)).toList();
  }

  // READ - Get meal by ID
  Future<Meal?> getMealById(String id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/lookup.php?i=$id'),
    );
    _handleResponseError(response);
    final data = json.decode(response.body);
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) return null;
    return Meal.fromJson(meals.first);
  }

  // READ - Get random meal
  Future<Meal?> getRandomMeal() async {
    final response = await _client.get(Uri.parse('$_baseUrl/random.php'));
    _handleResponseError(response);
    final data = json.decode(response.body);
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) return null;
    return Meal.fromJson(meals.first);
  }

  // READ - Filter meals by category
  Future<List<Meal>> filterByCategory(String category) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/filter.php?c=${Uri.encodeComponent(category)}'),
    );
    _handleResponseError(response);
    final data = json.decode(response.body);
    final meals = data['meals'] as List<dynamic>?;
    if (meals == null) return [];
    return meals.map((m) => Meal.fromJson(m)).toList();
  }

  // READ - Get all categories
  Future<List<MealCategory>> getCategories() async {
    final response = await _client.get(Uri.parse('$_baseUrl/categories.php'));
    _handleResponseError(response);
    final data = json.decode(response.body);
    final categories = data['categories'] as List<dynamic>?;
    if (categories == null) return [];
    return categories.map((c) => MealCategory.fromJson(c)).toList();
  }

  // CREATE/UPDATE/DELETE - TheMealDB is read-only publicly, so we simulate
  // these with local state in the provider (favourites, notes, etc.)
  // In a real scenario these would be POST/PUT/DELETE endpoints.

  void _handleResponseError(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        'API Error: ${response.statusCode} - ${response.reasonPhrase}',
        response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}
