import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.myWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: GNav(
              rippleColor: MyColors.myOrange.withValues(alpha: 0.1),
              hoverColor: MyColors.myOrange.withValues(alpha: 0.05),
              gap: 6.w,
              activeColor: MyColors.myOrange,
              iconSize: 25.sp,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutExpo,
              color: MyColors.myTextSecondary,
              tabBackgroundColor: MyColors.myOrange.withValues(alpha: 0.1),
              backgroundColor: MyColors.myWhite,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              tabBorderRadius: 16,
              tabs: [
                GButton(
                  icon: Icons.home_outlined,
                  text: 'الرئيسية',
                  textStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                    color: MyColors.myOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GButton(
                  icon: Icons.search,
                  text: 'بحث',
                  textStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                    color: MyColors.myOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GButton(
                  icon: Icons.help_outline,
                  text: 'طلباتي',
                  textStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                    color: MyColors.myOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GButton(
                  icon: Icons.person_outline,
                  text: 'حسابي',
                  textStyle: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 13.sp,
                    color: MyColors.myOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              selectedIndex: currentIndex,
              onTabChange: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
