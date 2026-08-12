import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/constants/place_categories.dart';
import 'package:engez/features/category/select_category_cubit.dart';
import 'package:engez/features/location/manger/location_cubit.dart';
import 'package:engez/features/location/manger/location_state.dart';
import 'package:engez/features/place/place_cubit.dart';
import 'package:engez/features/place/place_state.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/custom_icon_button.dart';
import 'package:engez/widgets/custom_offer_section.dart';
import 'package:engez/widgets/custom_text_field.dart';
import 'package:engez/widgets/nav_bar.dart';
import 'package:engez/widgets/place_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LocationCubit _locationCubit;
  late final SelectCategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    _locationCubit = LocationCubit()..fetchCurrentLocation();
    _categoryCubit = SelectCategoryCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaceCubit>().fetchPlaces();
    });
  }

  @override
  void dispose() {
    _locationCubit.close();
    _categoryCubit.close();
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
            const Spacer(),
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              String? imageUrl = user?.photoURL;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                imageUrl = data['profileImage'] ?? user?.photoURL;
              }
              return GestureDetector(
                onTap: () {
                  context.push('/profile');
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: MyColors.mygrey,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl) as ImageProvider
                        : const AssetImage('assets/images/enterPhoneNumber.png'),
                  ),
                ),
              );
            },
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
    // استخدم القائمة الموحدة من PlaceCategories
    final categories = PlaceCategories.list.where((c) => c != PlaceCategories.all).toList();
    final icons = categories.map((c) => PlaceCategories.icons[c]).toList();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: List.generate(icons.length, (index) {
              return Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: CustomIconButton(
                  iconData: icons[index],
                  onTap: () {
                    final categoryIndex = PlaceCategories.list.indexOf(categories[index]);
                    if (categoryIndex != -1) {
                      _categoryCubit.selectCategory(categoryIndex);
                    }
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferSection() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CarouselSlider(
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
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    final categories = PlaceCategories.list;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أماكن قريبة',
                style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.push('/all-places');
                },
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: MyColors.myDarkText,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CategoryList(categories: categories),
          SizedBox(height: 16.h),
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
                final filteredPlaces = selectedCategory == PlaceCategories.all
                    ? allPlaces
                    : allPlaces.where((p) => p.category == selectedCategory).toList();

                if (filteredPlaces.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد أماكن في هذا التصنيف',
                      style: TextStyle(color: Colors.grey[600]),
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
                        reviewsCount: '',
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

  Widget _buidTextField() {
    return CustomTextField(
      hintText: 'بتدور علي إيه؟',
      suffixIcon: Icons.search,
    );
  }

  Widget _buildBottomNavBar() {
    return const NavBar();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _locationCubit),
        BlocProvider.value(value: _categoryCubit),
      ],
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