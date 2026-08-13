import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/widgets/custom_image.dart';

class MenuItemCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final VoidCallback onAddTap;

  final int quantity;
  final VoidCallback onRemoveTap;

  const MenuItemCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.onAddTap,
    this.quantity = 0,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: CustomImage(
              imagePath: imagePath,
              height: 90.h,
              width: 90.w,
              fit: BoxFit.cover,
              errorWidget: Container(
                height: 90.h,
                width: 90.w,
                color: MyColors.myBorder,
                child: Icon(Icons.fastfood, color: MyColors.myTextSecondary),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF572000),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: MyColors.myTextSecondary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'EGP $price',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: MyColors.myOrange,
                        ),
                      ),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                      child: quantity == 0
                          ? GestureDetector(
                              key: const ValueKey('add_button_only'),
                              onTap: onAddTap,
                              child: CircleAvatar(
                                radius: 15.r,
                                backgroundColor: MyColors.myOrange,
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            )
                          : Row(
                              key: const ValueKey('quantity_controls'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: onRemoveTap,
                                  child: Container(
                                    width: 30.r,
                                    height: 30.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: MyColors.myOrange,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: MyColors.myOrange,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '$quantity',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF572000),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: onAddTap,
                                  child: CircleAvatar(
                                    radius: 15.r,
                                    backgroundColor: MyColors.myOrange,
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
