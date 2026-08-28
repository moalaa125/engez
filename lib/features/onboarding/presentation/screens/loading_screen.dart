import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/constants/my_colors.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'إنجز',
              style: TextStyle(
                color: MyColors.myOrange,
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
              ),
            ),
            SizedBox(height: 30.h),
            CircularProgressIndicator(color: MyColors.myOrange, strokeWidth: 4),
            SizedBox(height: 20.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                color: MyColors.myTextSecondary,
                fontSize: 16.sp,
                fontFamily: 'cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
