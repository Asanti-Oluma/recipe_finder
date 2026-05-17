import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/meal_card.dart';
import 'meal_detail_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: const Text('My Favourites'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Consumer<RecipeProvider>(
        builder: (_, provider, __) {
          if (provider.favourites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('❤️', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 16),
                  Text('No favourites yet',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Tap ❤️ on any recipe to save it here.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.favourites.length,
            itemBuilder: (_, i) {
              final meal = provider.favourites[i];
              return MealCard(
                meal: meal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailScreen(mealId: meal.idMeal),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    provider.removeFavourite(meal.idMeal);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${meal.strMeal} removed'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => provider.addFavourite(meal),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
