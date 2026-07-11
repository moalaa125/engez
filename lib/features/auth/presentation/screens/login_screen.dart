import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/manager/auth_state.dart';
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
  // 1. تعريف الكنترولر والـ Form Key بشكل صحيح
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    // 2. تنظيف الكنترولر الصح
    _phoneController.dispose();
    super.dispose();
  }

 

  Widget _buildButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.w),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تسجيل الدخول بنجاح'),
                backgroundColor: Color(0xFF003527),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OtpScreen(verificationId: ''),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF003527)),
            );
          }

          return CustomButton(
            text: 'تسجيل الدخول باستخدام Google',
            function: () {
              context.read<AuthCubit>().signInWithGoogle();
            },
          );
        },
      ),
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
    return const Text(
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
          'سجل دخول عشان نكمل',
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
