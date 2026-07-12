import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.function,
    required this.iconPath,
  });

  final String text;
  final void Function()? function;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 60.h,
          width: 380.w,
          decoration: BoxDecoration(
            color: MyColors.myGreen,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(iconPath, height: 28.h),
                Text(
                  text,
                  style: TextStyle(color: Colors.white, fontSize: 20.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
