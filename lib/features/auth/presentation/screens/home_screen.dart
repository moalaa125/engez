import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  // final String verificationId;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

PreferredSizeWidget _buildAppBar() {
  return AppBar(
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(color: Colors.black.withValues(alpha: .1), height: 1),
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
  );
}

Widget _buildListOfIcons() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomIconButton(iconData: Icons.coffee_outlined),
          SizedBox(width: 20),
          CustomIconButton(iconData: Icons.breakfast_dining),
          SizedBox(width: 20),
      
          CustomIconButton(iconData: Icons.icecream_outlined),
          SizedBox(width: 20),
      
          CustomIconButton(iconData: Icons.local_pizza_outlined),
          SizedBox(width: 20),
      
          CustomIconButton(iconData: Icons.food_bank_outlined),
          SizedBox(width: 20),
      
          CustomIconButton(iconData: Icons.apple),
          SizedBox(width: 20),
        ],
      ),
    ),
  );
}

Widget _buidTextField() {
  return TextField(
    textAlign: TextAlign.right,
    decoration: InputDecoration(
      hintText: 'بتدور علي ايه ؟',
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontFamily: 'cairo',
        fontSize: 15,
      ),
      suffixIcon: Icon(Icons.search, color: MyColors.myOrange),
      filled: true,
      fillColor: const Color(0xFFF3F4F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.15)),
      ),
    ),
  );
}

class _MyWidgetState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: _buidTextField()),
            _buildListOfIcons(),
          ],
        ),
      ),
    );
  }
}
