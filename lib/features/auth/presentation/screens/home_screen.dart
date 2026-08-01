import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/location/manger/location_cubit.dart';
import 'package:engez/features/location/manger/location_state.dart';
import 'package:engez/widgets/custom_icon_button.dart';
import 'package:engez/widgets/custom_offer_section.dart';
import 'package:engez/widgets/place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  // final String verificationId;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeScreen> {
  late final LocationCubit _locationCubit;
  int _currentIndex = 0;

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
            SizedBox(width: 90.w),
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
          child: CircleAvatar(
            radius: 22.r,
            backgroundImage: const AssetImage(
              'assets/images/enterPhoneNumber.png',
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
        child: const CircularProgressIndicator(strokeWidth: 2),
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
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        child: Row(
          children: [
            const CustomIconButton(iconData: Icons.coffee_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.breakfast_dining),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.icecream_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.local_pizza_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.food_bank_outlined),
            SizedBox(width: 20.w),
            const CustomIconButton(iconData: Icons.apple),
            SizedBox(width: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomOfferSection(
            colorOfTheCard: MyColors.myOrange,
            howMuchOffer: '10',
            tittleOfTheOffer: 'on your first morning coffe.',
            icon: Icons.coffee,
          ),
          CustomOfferSection(
            howMuchOffer: '10',
            tittleOfTheOffer: 'on your first morning coffe.',
            icon: Icons.coffee,
            colorOfTheCard: MyColors.mygrey,
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
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
                onPressed: () {}, // TODO: see all logic
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
          PlaceCard(
            imagePath: 'assets/images/cafe1.jpg',
            title: 'The Daily Roast',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '3 min',
            onFavoriteTap: () {},
          ),
          SizedBox(height: 20.h),
          PlaceCard(
            imagePath: 'assets/images/cafe1.jpg',
            title: 'The Daily Roast',
            rating: '4.9',
            reviewsCount: '210',
            category: 'Coffee',
            distanceTime: '3 min',
            onFavoriteTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buidTextField() {
    return TextField(
      textAlign: TextAlign.right,
      cursorColor: MyColors.myOrange,
      decoration: InputDecoration(
        hintText: 'بتدور علي ايه ؟',
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontFamily: 'cairo',
          fontSize: 15.sp,
        ),
        suffixIcon: Icon(Icons.search, color: MyColors.myOrange, size: 24.r),
        filled: true,
        fillColor: MyColors.myBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(
            color: MyColors.myOrange.withValues(alpha: 0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(
            color: MyColors.myOrange.withValues(alpha: 0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(color: MyColors.myOrange, width: 1.5.w),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
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
              color: Colors.grey[500],
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
              selectedIndex: _currentIndex,
              onTabChange: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
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
