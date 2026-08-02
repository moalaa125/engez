import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Kbab extends StatelessWidget {
  const Kbab({super.key});

  Widget _buildBottomBar() {
    return SizedBox(
      height: 60.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.myOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 30,
                  color: MyColors.myWhite,
                ),
                SizedBox(width: 10.w),
                Text(
                  'View Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              'EGP 250',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItemsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            'Popular Items',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF572000),
            ),
          ),
          SizedBox(height: 16.h),
          ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              MenuItemCard(
                imagePath: 'assets/images/burger_kbab.jpeg',
                title: 'Mix Grill Platter',
                description:
                    'Tender kofta, shish taouk, and kebab served with rice and...',
                price: '250',
                onAddTap: () {},
              ),
              MenuItemCard(
                imagePath: 'assets/images/burger2.jpg',
                title: 'Shish Taouk Wrap',
                description:
                    'Grilled chicken cubes wrapped in fresh bread with garlic...',
                price: '120',
                onAddTap: () {},
              ),
              MenuItemCard(
                imagePath: 'assets/images/burger3.jpg',
                title: 'Kofta Platter',
                description:
                    'Premium minced meat kofta grilled to perfection, served...',
                price: '200',
                onAddTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListOfTextButtons() {
    return const CategoryList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildBottomBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 400.h,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 330.h,
                    child: Hero(
                      tag: 'kbab_basha_tag',
                      child: Image.asset(
                        'assets/images/kbabbasha.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 140.h,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: MyColors.myWhite,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .1),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kbab Basha',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Grill & smash burger',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Divider(
                                  color: Colors.grey.withValues(alpha: .3),
                                  height: 2,
                                  thickness: 1,
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.directions_walk,
                                      size: 18,
                                      color: Colors.brown,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '30 min',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    const CircleAvatar(
                                      radius: 3,
                                      backgroundColor: Colors.grey,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Delivery available',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildListOfTextButtons(),
            SizedBox(height: 20.h),
            _buildPopularItemsSection(),
          ],
        ),
      ),
    );
  }
}
