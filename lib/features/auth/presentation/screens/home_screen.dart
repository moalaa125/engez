import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  // final String verificationId;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.black.withValues(alpha: .1),
            height: 1,
          ),
        ),
        backgroundColor: MyColors.myWhite,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, color: MyColors.myOrange),
              const SizedBox(width: 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'موقعك هو',
                    style: TextStyle(fontFamily: 'cairo', fontSize: 15),
                  ),
                  Text(
                    'مساكن البترول',
                    style: TextStyle(fontFamily: 'cairo', fontSize: 18),
                  ),
                ],
              ),
              SizedBox(width: 100.w),
              Text(
                'إنجز',
                style: TextStyle(
                  color: MyColors.myOrange,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'cairo',
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/enterPhoneNumber.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(child: Column(children: [
                       ],
          )),
      ),
    );
  }
}
