import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/manager/auth_state.dart';
import 'package:engez/features/auth/presentation/screens/home_screen.dart';
import 'package:engez/widgets/custom_button.dart';
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
  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildButton() {
    return BlocConsumer<AuthCubit, AuthState>(
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
            MaterialPageRoute(builder: (_) => const HomeScreen()),
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

        return Column(
          children: [
            Container(
              height: 180,
              width: 380,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 10,
                    spreadRadius: .5,
                    offset: const Offset(2, 5),
                  ),
                ],
                color: MyColors.myWhite.withValues(alpha: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    textColor: Colors.black,
                    buttonColor: MyColors.myWhite,
                    iconPath: 'assets/images/google.png',
                    text: 'تسجيل الدخول باستخدام Google',
                    function: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                  ),
                  CustomButton(
                    textColor: MyColors.myWhite,
                    buttonColor: Colors.black,
                    iconPath: 'assets/images/apple.png',
                    text: 'تسجيل الدخول باستخدام apple',
                    function: () {
                      // TODO lasa h3mlha
                    },
                  ),
                ],
              ),
            ),
          ],
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
    return const Text(
      'بالمتابعه انت توافق علي\n شروط الاستخدام والخصوصيه',
      textAlign: TextAlign.center,
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
                color: MyColors.myOrange,
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
              ),
            ),
          ),
        ),
        Text(
          'الزحمه مش سكتنا',
          style: TextStyle(
            color: Colors.black,
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
      backgroundColor: MyColors.myBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _introTexts(),
              SizedBox(height: 30.h),
              _buildButton(),
              SizedBox(height: 20.h),
              _buildEndMessage(),
            ],
          ),
        ),
      ),
    );
  }
}
