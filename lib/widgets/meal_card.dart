import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/meal.dart';

const _kPrimary = Color(0xFF2D1B69);
const _kAccent = Color(0xFFE8445A);
//const _kTextDim = Color(0xFF9497A8);

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final Widget? trailing;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 62,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (meal.strMealThumb != null)
                    CachedNetworkImage(
                      imageUrl: meal.strMealThumb!,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      memCacheHeight: 400,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _kAccent),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.restaurant,
                            size: 40, color: Colors.grey.shade300),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade100,
                      child: Icon(Icons.restaurant,
                          size: 40, color: Colors.grey.shade300),
                    ),
                  if (trailing != null)
                    Positioned(top: 6, right: 6, child: trailing!),
                ],
              ),
            ),
            Expanded(
              flex: 38,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.strMeal,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _kPrimary),
                    ),
                    if (meal.strCategory != null) ...[
                      const SizedBox(height: 3),
                      Text(meal.strCategory!,
                          style: const TextStyle(
                              fontSize: 11,
                              color: _kAccent,
                              fontWeight: FontWeight.w500)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
