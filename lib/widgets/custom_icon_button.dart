import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({super.key, required this.iconData});

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Color(0xFFA04100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: null,
        icon: Icon(iconData, color: MyColors.myWhite),
      ),
    );
  }
}
