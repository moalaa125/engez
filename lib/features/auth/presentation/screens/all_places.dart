import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/place_details.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/services/place_service.dart';
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
          FutureBuilder<List<Place>>(
            future: PlaceService().fetchPlaces(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: const CircularProgressIndicator(color: Colors.deepOrange),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final places = snapshot.data!;
              if (places.isEmpty) {
                return const Center(child: Text('No places found'));
              }
              return Column(
                children: places.map((place) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: PlaceCard(
                      heroTag: place.id,

                      onTab: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PlaceDetailsScreen(place: place),
                          ),
                        );
                      },
                      imagePath: place.imagePath,
                      title: place.title,
                      rating: place.rating.toString(),
                      reviewsCount: '200',
                      category: place.category,
                      distanceTime: '20 min',
                      onFavoriteTap: () {},
                    ),
                  );
                }).toList(),
              );
            },
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
