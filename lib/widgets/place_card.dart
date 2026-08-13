import 'package:flutter/material.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/custom_image.dart';

class PlaceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String rating;
  final String? reviewsCount; // يمكن أن يكون null أو فارغ
  final String category;
  final String distanceTime;
  final VoidCallback? onFavoriteTap;
  final void Function()? onTab;
  final String heroTag;

  const PlaceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.rating,
    this.reviewsCount,
    required this.category,
    required this.distanceTime,
    this.onFavoriteTap,
    this.onTab,
    required this.heroTag,
  });



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: SizedBox(
        height: 220,
        width: 400,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: heroTag,
                  child: CustomImage(imagePath: imagePath),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE8E9).withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (reviewsCount != null && reviewsCount!.isNotEmpty) ...[
                                Text(
                                  ' ($reviewsCount)',
                                  style: const TextStyle(
                                    color: MyColors.myTextSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 12),
                              Text(
                                category,
                                style: const TextStyle(
                                  color: MyColors.myTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 18,
                              color: Colors.brown,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              distanceTime,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}