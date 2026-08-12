import 'package:engez/features/auth/presentation/screens/offers_screen.dart';
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
    // Forced to LTR so this card keeps its original layout (text on the
    // left, icon on the right) even though the app's global locale is now
    // Arabic/RTL. Remove this wrapper if you ever want this card to mirror
    // along with the rest of the app.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OffersScreen()),
          );
        },
        child: Container(
          height: 180.h,
          width: 350.w,
          margin: EdgeInsets.only(left: 10.w),
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
                        letterSpacing: 1.2,
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
                const Spacer(),
                Icon(icon, size: 100.r, color: const Color(0xFFDC5C00)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}