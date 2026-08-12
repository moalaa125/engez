import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final VoidCallback? onTap;

  const CustomIconButton({
    super.key,
    required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: MyColors.myDarkOrange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(iconData, color: MyColors.myWhite),
      ),
    );
  }
}