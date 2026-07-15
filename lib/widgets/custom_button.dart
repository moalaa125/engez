import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.function,
    required this.iconPath,
    required this.buttonColor,
    required this.textColor,
  });

  final String text;
  final void Function()? function;
  final String iconPath;
  final Color buttonColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 20 , left: 20),
        child: GestureDetector(
          onTap: function,
          child: Container(
            height: 60.h,
            width: 380.w,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                width: 1,
                color: Colors.black,
              )
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    text,
                    style: TextStyle(color: textColor, fontSize: 20.sp),
                  ),
                  Image.asset(iconPath, height: 28.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
