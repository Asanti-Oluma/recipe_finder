import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/meal_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/error_view.dart';
import '../widgets/shimmer_grid.dart';
import 'meal_detail_screen.dart';
import 'favourites_screen.dart';

const _kPrimary    = Color(0xFF2D1B69);
const _kAccent     = Color(0xFFE8445A);
const _kBackground = Color(0xFFF7F7FC);
const _kTextDim    = Color(0xFF9497A8);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryRow(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _kPrimary,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recipe Finder',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    Text('What are you craving today?',
                        style: TextStyle(
                            color: Colors.white60, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded,
                    color: Colors.white, size: 26),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavouritesScreen())),
              ),
              Consumer<RecipeProvider>(
                builder: (_, p, __) => IconButton(
                  icon: p.isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.casino_outlined,
                          color: Colors.white, size: 26),
                  tooltip: 'Random meal',
                  onPressed: () => _onRandomMeal(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          TextField(
            controller: _searchController,
            onSubmitted: (q) =>
                context.read<RecipeProvider>().searchMeals(q),
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.search, color: _kAccent),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade400),
                      onPressed: () {
                        _searchController.clear();
                        context.read<RecipeProvider>().clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Consumer<RecipeProvider>(
      builder: (_, provider, __) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();
        return Container(
          color: _kPrimary,
          child: SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = provider.categories[i];
                return CategoryChip(
                  label: cat.strCategory,
                  selected: provider.selectedCategory == cat.strCategory,
                  onTap: () => provider.filterByCategory(cat.strCategory),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return Consumer<RecipeProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const ShimmerGrid();

        if (provider.state == LoadingState.error) {
          return ErrorView(
            message: provider.errorMessage,
            onRetry: () => provider.loadCategories(),
          );
        }

        if (provider.meals.isEmpty && provider.state == LoadingState.idle) {
          return _buildEmptyHome();
        }

        if (provider.meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No meals found.',
                    style: TextStyle(color: _kTextDim, fontSize: 15)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.meals.length,
          itemBuilder: (_, i) {
            final meal = provider.meals[i];
            return MealCard(
              meal: meal,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) =>
                          MealDetailScreen(mealId: meal.idMeal))),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.07), shape: BoxShape.circle),
            child: const Icon(Icons.restaurant_menu_outlined,
                size: 48, color: _kPrimary),
          ),
          const SizedBox(height: 20),
          const Text('Discover Recipes',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: _kPrimary)),
          const SizedBox(height: 8),
          const Text('Search a dish or pick a category above',
              style: TextStyle(color: _kTextDim, fontSize: 14)),
        ],
      ),
    );
  }

  void _onRandomMeal() {
    context.read<RecipeProvider>().loadRandomMeal().then((_) {
      final meal = context.read<RecipeProvider>().selectedMeal;
      if (meal != null && mounted) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: meal.idMeal),
        ));
      }
    });
  }
}
