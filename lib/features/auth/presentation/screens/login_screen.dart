import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/otp_screen.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manager/auth_cubit.dart';

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
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              generateCountryFlag() + ' +20',
              style: TextStyle(fontSize: 18, letterSpacing: 2.0),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: TextFormField(
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
              style: TextStyle(fontSize: 18, letterSpacing: 2.0),
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade500),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 40, 75, 41),
                    width: 2,
                  ),
                ),
                hint: Text(
                  'اكتب رقم موبايلك',
                  style: TextStyle(color: Colors.black, fontSize: 18),
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

      child: CustomImage(image: 'assets/images/joinUs.png', height: 330),
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
                fontSize: 40,
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
            fontSize: 25,
            fontWeight: FontWeight.bold,
            
            fontFamily: 'cairo',
          ),
        ),
        SizedBox(height: 60),
        Text(
          'دخل رقم تليفونك عشان نكمل',
          style: TextStyle(
            color: Color(0xFF404944),
            fontSize: 20,
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
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(right: 11, left: 11),
                  child: _buildPhoneNumberField(),
                ),
                SizedBox(height: 35),
                _buildButton(),
                SizedBox(height: 20),
                _buildEndMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
