import 'package:carousel_slider/carousel_slider.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/all_places.dart';
import 'package:engez/features/auth/presentation/screens/profile.dart';
import 'package:engez/features/auth/presentation/screens/place_details.dart';
import 'package:engez/features/location/manger/location_cubit.dart';
import 'package:engez/features/location/manger/location_state.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/services/place_service.dart';
import 'package:engez/widgets/custom_icon_button.dart';
import 'package:engez/widgets/custom_offer_section.dart';
import 'package:engez/widgets/custom_text_field.dart';
import 'package:engez/widgets/nav_bar.dart';
import 'package:engez/widgets/place_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  late final LocationCubit _locationCubit;

  @override
  void initState() {
    super.initState();
    _locationCubit = LocationCubit()..fetchCurrentLocation();
  }

  @override
  void dispose() {
    _locationCubit.close();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
     final User? user = FirebaseAuth.instance.currentUser;
    return AppBar(
      scrolledUnderElevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          color: Colors.black.withValues(alpha: .1),
          height: 1.h,
        ),
      ),
      backgroundColor: MyColors.myWhite,
      title: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: MyColors.myOrange,
              size: 24.r,
            ),
            SizedBox(width: 4.w),
            BlocBuilder<LocationCubit, LocationState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'موقعك هو',
                      style: TextStyle(fontFamily: 'cairo', fontSize: 15.sp),
                    ),
                    _buildLocationText(state),
                  ],
                );
              },
            ),
            Spacer(),
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
          padding: EdgeInsets.only(right: 10.w),
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
            },
            child: CircleAvatar(
              radius: 22.r,
              backgroundImage: const AssetImage(
                'assets/images/enterPhoneNumber.png',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationText(LocationState state) {
    if (state is LocationLoading || state is LocationInitial) {
      return SizedBox(
        height: 16.h,
        width: 16.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.deepOrange,
        ),
      );
    }

    if (state is LocationLoaded) {
      return Text(
        state.address,
        style: TextStyle(fontFamily: 'cairo', fontSize: 18.sp),
      );
    }

    if (state is LocationError) {
      return GestureDetector(
        onTap: () => _locationCubit.fetchCurrentLocation(),
        child: Text(
          'اضغط لإعادة المحاولة',
          style: TextStyle(
            fontFamily: 'cairo',
            fontSize: 13.sp,
            color: Colors.red,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildListOfIcons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            CustomIconButton(iconData: Icons.coffee_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.breakfast_dining),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.icecream_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.local_pizza_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.food_bank_outlined),
            SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 180.h,
        viewportFraction: 0.9,
        enableInfiniteScroll: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false,
        padEnds: false,
      ),
      items: const [
        CustomOfferSection(
          howMuchOffer: '10',
          tittleOfTheOffer: 'on your first morning coffee.',
          icon: Icons.coffee,
          colorOfTheCard: Color(0xFFFF7A00),
        ),
        CustomOfferSection(
          howMuchOffer: '20',
          tittleOfTheOffer: 'on your lunch meal today.',
          icon: Icons.fastfood,
          colorOfTheCard: Colors.grey,
        ),
        CustomOfferSection(
          howMuchOffer: '15',
          tittleOfTheOffer: 'on fresh baked pastries.',
          icon: Icons.bakery_dining,
          colorOfTheCard: Color(0xFFFFB74D),
        ),
      ],
    );
  }

  Widget _buildNearbyPlaces() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Places',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllPlaces()),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: const Color(0xFF572000),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          FutureBuilder<List<Place>>(
            future: PlaceService().fetchPlaces(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.deepOrange),
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

  Widget _buidTextField() {
    return CustomTextField(
      hintText: 'بتدور علي ايه ؟',
      suffixIcon: Icons.search,
    );
  }

  Widget _buildBottomNavBar() {
    return NavBar();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _locationCubit,
      child: Scaffold(
        backgroundColor: MyColors.myWhite,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(16.w), child: _buidTextField()),
              _buildListOfIcons(),
              _buildOfferSection(),
              _buildNearbyPlaces(),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }
}
