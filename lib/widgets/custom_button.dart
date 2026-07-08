import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text, required this.function});

  final String text;
  final void Function()? function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function, // TODO lsa h3mlha
      child: Container(
        height: 60.h,
        width: 360.w,
        decoration: BoxDecoration(
          color: MyColors.myGreen,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
        ),
      ),
    );
  }
}