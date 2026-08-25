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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/features/location/manger/location_cubit.dart';
import 'package:engez/features/location/manger/location_state.dart';
import 'package:geolocator/geolocator.dart';
import 'package:engez/core/utils/distance_utils.dart';

class AllPlaces extends StatelessWidget {
  const AllPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => SelectCategoryCubit())],
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
              const CategoryList(categories: ['الكل', 'قهوة', 'مخبز', 'فطار']),
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
              final isLoading = placeState is PlaceLoading;
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
              if (isLoading || placeState is PlaceLoaded) {
                final selectedIndex = context
                    .watch<SelectCategoryCubit>()
                    .state
                    .selectedIndex;
                final selectedCategory = categories[selectedIndex];

                final allPlaces = isLoading ? <Place>[] : (placeState as PlaceLoaded).places;
                var filteredPlaces = selectedCategory == 'الكل'
                    ? allPlaces
                    : allPlaces
                          .where((p) => p.category == selectedCategory)
                          .toList();

                if (!isLoading) {
                  final locationState = context.read<LocationCubit>().state;
                  if (locationState is LocationLoaded) {
                    final userLat = locationState.latitude;
                    final userLng = locationState.longitude;
                    
                    filteredPlaces = filteredPlaces.where((place) {
                      if (place.branches.isEmpty) return true; // keep for backward compatibility
                      
                      bool isNear = false;
                      for (var branch in place.branches) {
                        double distance = Geolocator.distanceBetween(
                          userLat, userLng, branch.latitude, branch.longitude
                        );
                        if (distance <= 30000) { // 30 km radius
                          isNear = true;
                          break;
                        }
                      }
                      return isNear;
                    }).toList();
                  }
                }

                if (!isLoading && filteredPlaces.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أماكن في هذا التصنيف',
                      style: TextStyle(
                        color: MyColors.myTextSecondary,
                        fontFamily: 'cairo',
                      ),
                    ),
                  );
                }

                final itemsCount = isLoading ? 6 : filteredPlaces.length;

                final locationState = context.read<LocationCubit>().state;
                double? uLat, uLng;
                if (locationState is LocationLoaded) {
                  uLat = locationState.latitude;
                  uLng = locationState.longitude;
                }

                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: itemsCount,
                    itemBuilder: (context, index) {
                      if (isLoading) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: const FakePlaceCard(),
                        );
                      }
                      final place = filteredPlaces[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: PlaceCard(
                          heroTag: place.id,
                          onTab: () {
                            context.push('/place-details', extra: place);
                          },
                          imagePath: place.imagePath,
                          title: place.title,
                          rating: place.rating.toString(),
                          reviewsCount: '',
                          category: place.category,
                          distanceTime: DistanceUtils.calculateETA(uLat, uLng, place),
                          onFavoriteTap: () {},
                        ),
                      );
                    },
                  ),
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
