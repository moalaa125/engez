import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomOfferSection extends StatelessWidget {
  const CustomOfferSection({
    super.key,
    required this.howMuchOffer,
    required this.tittleOfTheOffer,
    required this.icon,
    required this.colorOfTheCard,
  });

  final String howMuchOffer;
  final String tittleOfTheOffer;
  final IconData icon;
  final Color colorOfTheCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Container(
        height: 180.h,
        width: 330.w,
        decoration: BoxDecoration(
          color: colorOfTheCard,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENGEZ OFFERS',
                    style: TextStyle(
                      color: const Color(0xFF572000),
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '$howMuchOffer%',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF572000),
                    ),
                  ),
                  Text(
                    tittleOfTheOffer,
                    style: TextStyle(
                      color: const Color(0xFF572000),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Icon(
                icon,
                size: 100.r,
                color: const Color(0xFFDC5C00) ,  //
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* 

    Container(
              height: 180.h,
              width: 300.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE7E8E9),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Grab',
                          style: TextStyle(
                            color: const Color(0xFF572000),
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          'Free Pastry',
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'With any large iced coffee.',
                          style: TextStyle(
                            color: const Color(0xFF572000),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.star_rounded,
                      size: 60.r,
                      color: const Color(0xFFD8D7D6),
                    ),
                  ],
                ),
              ),
            ),


 */