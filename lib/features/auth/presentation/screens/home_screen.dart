import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  // final String verificationId;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

Widget _introImage() {
  return Hero(
    tag: 'animationForIntroImage',
    child: CustomImage(image: 'assets/images/otp.png', height: 330.h),
  );
}




class _MyWidgetState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Hero(
                tag: 'animationForEngezTxt',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'إنجز',
                    style: TextStyle(
                      color: MyColors.myLighterGreen,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'aref',
                    ),
                  ),
                ),
              ),
              _introImage(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
