import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/otp_screen.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/auth_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String phoneNumber = '';

  Widget _buildPhoneNumberField() {
    return Row(
      children: [
        Expanded(
          flex: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                generateCountryFlag() + ' +20',
                style: TextStyle(fontSize: 18.sp, letterSpacing: 2.0),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
            child: TextFormField(
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),

              validator: (value) {
                if (value!.isEmpty) {
                  return 'من فضلك دخل رقم موبايلك';
                } else if (value.length < 11) {
                  return 'دخل رقم موبايل صحيح';
                } else {
                  return null;
                }
              },
              onSaved: (value) {
                phoneNumber = value!;
              },
              keyboardType: TextInputType.phone,
              cursorColor: Colors.green,
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 18.sp, letterSpacing: 2.0),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey.shade500),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 40, 75, 41),
                    width: 2.w,
                  ),
                ),
                hint: Center(
                  child: Text(
                    'اكتب رقم موبايلك',
                    style: TextStyle(color: Colors.black, fontSize: 18.sp),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return CustomButton(
      text: 'ابعت اكود',
      function: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpScreen()),
        );
      },
    );
  }

  String generateCountryFlag() {
    String countryCode = 'eg';

    String flag = countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
    return flag;
  }

  Widget _buildEndMessage() {
    return Text(
      'بالمتابعه انت توافق علي\n شروط الاستخدام والخصوصيه',
      textAlign: TextAlign.center,
    );
  }

  Widget _introImage() {
    return Hero(
      tag: 'animationForIntroImage',
      child: CustomImage(image: 'assets/images/joinUs.png', height: 330.h),
    );
  }

  Widget _introTexts() {
    return Column(
      children: [
        Hero(
          tag: 'animationForEngezTxt',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              'إنجز',
              style: TextStyle(
                color: MyColors.myGreen,
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'aref',
              ),
            ),
          ),
        ),
        Text(
          'الزحمه مش سكتنا',
          style: TextStyle(
            color: MyColors.myGreen,
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'cairo',
          ),
        ),
        SizedBox(height: 60.h),
        Text(
          'دخل رقم تليفونك عشان نكمل',
          style: TextStyle(
            color: const Color(0xFF404944),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                _introImage(),
                _introTexts(),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.only(right: 11.w, left: 11.w),
                  child: _buildPhoneNumberField(),
                ),
                SizedBox(height: 35.h),
                _buildButton(),
                SizedBox(height: 20.h),
                _buildEndMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
