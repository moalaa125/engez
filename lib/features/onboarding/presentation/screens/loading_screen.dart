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
            Image.asset(
              'assets/icon/web/icon-512.png',
              width: 150.w,
              height: 150.h,
            ),
            SizedBox(height: 16.h),
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
            // TODO: أضف كود الأنيميشن (Lottie) الخاص بك هنا لاحقاً
            CircularProgressIndicator(color: MyColors.myOrange, strokeWidth: 4),
          ],
        ),
      ),
    );
  }
}
