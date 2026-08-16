import 'package:flutter/material.dart';
import 'package:engez/constants/my_colors.dart';

class CustomImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Widget? errorWidget;

  const CustomImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  Widget _buildPlaceholder() {
    if (errorWidget != null) return errorWidget!;
    return Container(
      height: height,
      width: width,
      color: MyColors.myBorder,
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: MyColors.myTextSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: height,
            width: width,
            child: Center(
              child: CircularProgressIndicator(
                color: MyColors.myOrange,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
  }
}
