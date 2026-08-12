import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/category/select_category_cubit.dart';
import 'package:engez/features/place/place_cubit.dart';
import 'package:engez/features/place/place_state.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AllPlaces extends StatelessWidget {
  const AllPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SelectCategoryCubit()),
      ],
      child: Scaffold(
        backgroundColor: MyColors.myWhite,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: MyColors.myWhite,
          title: Text(
            'جميع الأماكن',
            style: TextStyle(
              fontSize: 30.sp,
              color: MyColors.myDarkOrange,
              fontWeight: FontWeight.bold,
              fontFamily: 'cairo',
            ),
          ),
          centerTitle: true,
       
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              const CategoryList(
                categories: ['الكل', 'قهوة', 'مخبز', 'فطار'],
              ),
              SizedBox(height: 20.h),
              _buildNearbyPlaces(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    final categories = ['الكل', 'قهوة', 'مخبز', 'فطار'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          BlocBuilder<PlaceCubit, PlaceState>(
            builder: (context, placeState) {
              if (placeState is PlaceLoading) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
                );
              }
              if (placeState is PlaceError) {
                return Center(
                  child: Column(
                    children: [
                      Text('خطأ: ${placeState.message}'),
                      TextButton(
                        onPressed: () =>
                            context.read<PlaceCubit>().fetchPlaces(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }
              if (placeState is PlaceLoaded) {
                final selectedIndex = context.watch<SelectCategoryCubit>().state.selectedIndex;
                final selectedCategory = categories[selectedIndex];

                final allPlaces = placeState.places;
                final filteredPlaces = selectedCategory == 'الكل'
                    ? allPlaces
                    : allPlaces.where((p) => p.category == selectedCategory).toList();

                if (filteredPlaces.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أماكن في هذا التصنيف' ,
                      style: TextStyle(color: Colors.grey[600] , fontFamily: 'cairo'),
                    ),
                  );
                }

                return Column(
                  children: filteredPlaces.map((place) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: PlaceCard(
                        heroTag: place.id,
                        onTab: () {
                          context.push(
                            '/place-details',
                            extra: place,
                          );
                        },
                        imagePath: place.imagePath,
                        title: place.title,
                        rating: place.rating.toString(),
                        reviewsCount: '', // مؤقت
                        category: place.category,
                        distanceTime: '20 دقيقة',
                        onFavoriteTap: () {},
                      ),
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}