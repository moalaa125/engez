import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/manager/auth_cubit.dart';
import 'package:engez/features/auth/manager/auth_state.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/widgets/result_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
          FirebaseAnalytics.instance.logEvent(name: 'sign_up');

          showResultFeedback(
            context,
            isSuccess: true,
            message: 'تم تسجيل الدخول بنجاح',
            onDone: () {
              if (mounted) {
                context.go('/loading');
              }
            },
          );
        } else if (state is AuthError) {
          showResultFeedback(
            context,
            isSuccess: false,
            message: state.errorMessage,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(
            child: CircularProgressIndicator(color: MyColors.myOrange),
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: .5,
                    offset: const Offset(2, 5),
                  ),
                ],
                color: MyColors.myWhite.withOpacity(1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    textColor: MyColors.myDarkText,
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
                    iconPath: 'assets/images/apple.jpg',
                    text: 'تسجيل الدخول باستخدام apple',
                    function: () {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          context.go('/role-selection');
                        }
                      });
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

  Widget _buildEndMessage() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: MyColors.myDarkText,
          fontSize: 14.sp,
          fontFamily: 'cairo',
        ),
        children: [
          const TextSpan(text: 'بالمتابعه انت توافق علي\n'),
          TextSpan(
            text: 'شروط الاستخدام',
            style: const TextStyle(
              color: MyColors.myOrange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                // TODO: replace with real hosted privacy policy URL before release
                final url = Uri.parse('https://engez.app/terms');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
          ),
          const TextSpan(text: ' و '),
          TextSpan(
            text: 'الخصوصيه',
            style: const TextStyle(
              color: MyColors.myOrange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                // TODO: replace with real hosted privacy policy URL before release
                final url = Uri.parse('https://engez.app/privacy');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
          ),
        ],
      ),
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
            color: MyColors.myDarkText,
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'cairo',
          ),
        ),
        SizedBox(height: 60.h),
        Text(
          'سجل دخول عشان نكمل',
          style: TextStyle(
            color: MyColors.myTextSecondary,
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
