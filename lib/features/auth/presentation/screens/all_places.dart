import 'package:engez/constants/my_colors.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllPlaces extends StatelessWidget {
  const AllPlaces({super.key});

  Widget _buildListOfTextButtons() {
    return const CategoryList(
      categories: ['All', 'Coffe', 'Bakery', 'Breakfast'],
    );
  }

  Widget _buildNearbyPlaces() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          PlaceCard(
            heroTag: 'hero1',
            imagePath: 'assets/images/kbabbasha.png',
            title: 'كباب باشا',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '30 min',
            onFavoriteTap: () {},
          ),
          SizedBox(height: 20.h),
          PlaceCard(
            heroTag: 'hero2',
            imagePath: 'assets/images/bob.jpeg',
            title: 'بوب وتش',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '15 min',
            onFavoriteTap: () {},
          ),
          SizedBox(height: 20.h),

          PlaceCard(
            heroTag: 'hero3',
            imagePath: 'assets/images/kbabbasha.png',
            title: 'كباب باشا',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '30 min',
            onFavoriteTap: () {},
          ),
          SizedBox(height: 20.h),
          PlaceCard(
            heroTag: 'hero4',
            imagePath: 'assets/images/bob.jpeg',
            title: 'بوب وتش',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '15 min',
            onFavoriteTap: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: MyColors.myWhite,
        title: Text(
          'All places',
          style: TextStyle(
            fontSize: 30.sp,
            color: MyColors.myDarkOrange,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.search, color: MyColors.myDarkOrange, size: 25),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            _buildListOfTextButtons(),
            SizedBox(height: 20.h),
            _buildNearbyPlaces(),
          ],
        ),
      ),
    );
  }
}
