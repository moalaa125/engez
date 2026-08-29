import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.suffixIcon,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
  });
  final String hintText;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      cursorColor: MyColors.myOrange,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: MyColors.myTextSecondary,
          fontFamily: 'cairo',
          fontSize: 15.sp,
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: MyColors.myOrange, size: 24.r) : null,
        filled: true,
        fillColor: MyColors.myBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(
            color: MyColors.myOrange.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(
            color: MyColors.myOrange.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: MyColors.myOrange, width: 1.5.w),
        ),
      ),
    );
  }
}
