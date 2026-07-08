import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _MyWidgetState();
}

Widget _introImage() {
  return Hero(
    tag: 'animationForIntroImage',
    child: CustomImage(image: 'assets/images/otp.png', height: 330),
  );
}

Widget _buildOtpCodeSection() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
    child: MaterialPinField(
      autoDismissKeyboard: true,
      keyboardType: TextInputType.number,
      length: 6,
       onCompleted: null ,  // TODO : lsa h3mlha 
      onChanged: (value) => print('Changed: $value'),
      theme: MaterialPinTheme(
        borderColor: MyColors.myGreen,
        filledFillColor: MyColors.myLighterGreen,
        focusedBorderColor: MyColors.myLighterGreen,
        cursorColor: Colors.black,
        fillColor: Colors.white,
        disabledColor: Colors.white,
        focusedFillColor: Colors.white,
        animateCursor: true,
        animationDuration: Duration(milliseconds: 200),
        shape: MaterialPinShape.outlined,
        cellSize: Size(50, 50),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget _buildButton() {
  return CustomButton(text: 'تأكيد الكود' , function: null,);
}

Widget _buildEndTexts() {
  return Column(
    children: [
      TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: null,
        child: Text(
          'لم يصلك الكود ؟',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
      ),
      SizedBox(height: 10,),
      TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: null,
        child: Text(
          'اعاده ارسال الكود',
          style: TextStyle(
            color: MyColors.myLighterGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

class _MyWidgetState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'aref',
                  ),
                ),
              ),
            ),
            _introImage(),
            _buildOtpCodeSection(),
            SizedBox(height: 30),
            _buildButton(),
            SizedBox(height: 10,),
            _buildEndTexts(),
          ],
        ),
      ),
    );
  }
}
