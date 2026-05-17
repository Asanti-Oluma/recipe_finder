import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/recipe_provider.dart';
import '../widgets/error_view.dart';
import 'edit_favourite_screen.dart';

const _kPrimary = Color(0xFF2D1B69);
const _kAccent = Color(0xFFE8445A);
const _kBg = Color(0xFFF7F7FC);

class MealDetailScreen extends StatefulWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadMealDetail(widget.mealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(builder: (_, provider, __) {
      if (provider.isLoading) {
        return const Scaffold(
            backgroundColor: _kBg,
            body: Center(child: CircularProgressIndicator(color: _kAccent)));
      }
      if (provider.state == LoadingState.error) {
        return Scaffold(
          backgroundColor: _kBg,
          body: ErrorView(
            message: provider.errorMessage,
            onRetry: () => provider.loadMealDetail(widget.mealId),
          ),
        );
      }
      final meal = provider.selectedMeal;
      if (meal == null) {
        return const Scaffold(
            backgroundColor: _kBg, body: Center(child: Text('Meal not found')));
      }

      final isFav = provider.isFavourite(meal.idMeal);

      return Scaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? _kAccent : Colors.white,
                  ),
                  onPressed: () {
                    if (isFav) {
                      provider.removeFavourite(meal.idMeal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snackBar('Removed from favourites'),
                      );
                    } else {
                      provider.addFavourite(meal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        _snackBar('Added to favourites ❤️'),
                      );
                    }
                  },
                ),
                if (isFav)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditFavouriteScreen(meal: meal)),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  meal.strMeal,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Meal image
                    meal.strMealThumb != null
                        ? CachedNetworkImage(
                            imageUrl: meal.strMealThumb!,
                            fit: BoxFit.cover,
                            memCacheWidth: 800,
                            memCacheHeight: 600,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (_, __) => Container(color: _kPrimary),
                            errorWidget: (_, __, ___) => Container(
                              color: _kPrimary,
                              child: const Icon(Icons.restaurant,
                                  color: Colors.white38, size: 64),
                            ),
                          )
                        : Container(color: _kPrimary),
                    // Dark gradient at bottom so title is always readable
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (meal.strCategory != null)
                          _Tag(meal.strCategory!, _kAccent),
                        if (meal.strArea != null)
                          _Tag(meal.strArea!, _kPrimary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Ingredients'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: meal.ingredients
                            .map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                          color: _kAccent,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '${e.value.trim()} ${e.key}',
                                        style: const TextStyle(
                                            fontSize: 14, color: _kPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Instructions'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        meal.strInstructions ?? 'No instructions available.',
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.7,
                            color: Color(0xFF444444)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  SnackBar _snackBar(String msg) => SnackBar(
        content: Text(msg),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: _kPrimary),
      );
}
