import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text , required this.function});

  final String text;
  final void Function()? function;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function, // TODO lsa h3mlha
      child: Container(
        height: 60,
        width: 380,
        decoration: BoxDecoration(
          color: MyColors.myGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
