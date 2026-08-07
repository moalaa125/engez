import 'dart:ui';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/auth/presentation/screens/cart_screen.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:engez/features/cart/manager/cart_state.dart';
import 'package:engez/features/cart/models/cart_item.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  PlaceDetailsScreen({super.key, required this.place});

  final Map<String, String> _pdfPaths = {
    'kbab_basha': 'menu/menukbab.pdf',
    'bob_wich': 'menu/menubob.pdf',
  };

  final Map<String, List<CartItem>> _menuItemsData = {
    'kbab_basha': const [
      CartItem(
        id: 'mix_grill_platter',
        title: 'Mix Grill Platter',
        imagePath: 'assets/images/burger_kbab.jpeg',
        price: 250,
      ),
      CartItem(
        id: 'shish_taouk_wrap',
        title: 'Shish Taouk Wrap',
        imagePath: 'assets/images/burger2.jpg',
        price: 120,
      ),
      CartItem(
        id: 'kofta_platter',
        title: 'Kofta Platter',
        imagePath: 'assets/images/burger3.jpg',
        price: 200,
      ),
    ],
    'bob_wich': const [
      CartItem(
        id: 'bob_wich_burger',
        title: 'Bob Wich Burger',
        imagePath: 'assets/images/bob.jpeg',
        price: 150,
      ),
    ],
    'rolz': const [
      CartItem(
        id: 'rolz',
        title: 'Rolz Burger',
        imagePath: 'assets/images/rolz.png',
        price: 150,
      ),
    ],
  };

  final Map<String, String> _descriptions = {
    'kbab_basha': 'Grill & smash burger',
    'bob_wich': 'Fresh & healthy sandwiches',
  };

  final Map<String, String> _descriptionsItems = {
    'mix_grill_platter': 'Tender kofta, shish taouk, and kebab served with rice and...',
    'shish_taouk_wrap': 'Grilled chicken cubes wrapped in fresh bread with garlic...',
    'kofta_platter': 'Premium minced meat kofta grilled to perfection, served...',
    'bob_wich_burger': 'Delicious classic burger with secret sauce...',
    'rolz' : 'rolz burger',
  };

  void _showPdfMenu(BuildContext context) {
    final String? pdfPath = _pdfPaths[place.id];
    if (pdfPath == null || pdfPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No menu PDF available for this place yet.')),
      );
      return;
    }

    final PdfViewerController pdfViewerController = PdfViewerController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .3),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              height: 600.h,
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_in, color: Colors.black),
                            onPressed: () {
                              pdfViewerController.zoomLevel = pdfViewerController.zoomLevel + 1;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out, color: Colors.black),
                            onPressed: () {
                              pdfViewerController.zoomLevel = pdfViewerController.zoomLevel - 1;
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: SfPdfViewerTheme(
                        data: SfPdfViewerThemeData(
                          backgroundColor: MyColors.myWhite,
                        ),
                        child: SfPdfViewer.asset(
                          pdfPath,
                          controller: pdfViewerController,
                          canShowScrollHead: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return SizedBox(
          height: 60.h,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors.myOrange,
              disabledBackgroundColor: MyColors.myOrange.withValues(alpha: .4),
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
                      state.isEmpty
                          ? 'Cart is empty'
                          : 'View Cart (${state.totalItemsCount})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'EGP ${state.totalPrice.toStringAsFixed(0)}',
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
      },
    );
  }

  Widget _buildPopularItemsSection(BuildContext context) {
    final List<CartItem> menuItems = _menuItemsData[place.id] ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: menuItems.map((item) {
                  int currentQuantity =
                      state.items.where((e) => e.id == item.id).firstOrNull?.quantity ?? 0;

                  return MenuItemCard(
                    imagePath: item.imagePath,
                    title: item.title,
                    description: _descriptionsItems[item.id] ?? '',
                    price: item.price.toStringAsFixed(0),
                    quantity: currentQuantity,
                    onAddTap: () {
                      context.read<CartCubit>().addItem(item);
                    },
                    onRemoveTap: () {
                      context.read<CartCubit>().decrementItem(item.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListOfTextButtons() {
    return const CategoryList(
      categories: ['Popular', 'Meals', 'Juices', 'Desserts'],
    );
  }

  Widget _buildImageAndDetailsBar(BuildContext context) {
    return SizedBox(
      height: 400.h,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 330.h,
            child: Hero(
              tag: place.id,
              child: Image.asset(
                place.imagePath,
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              place.title,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPdfMenu(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: MyColors.myOrange.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_rounded,
                                      color: MyColors.myOrange,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Menu',
                                      style: TextStyle(
                                        color: MyColors.myOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _descriptions[place.id] ?? place.category,
                          style: TextStyle(
                            fontSize: 14.sp,
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
                  SizedBox(width: 12.w),
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
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          place.rating.toString(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MyColors.myWhite,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: _buildBottomBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageAndDetailsBar(context),
            SizedBox(height: 20.h),
            _buildListOfTextButtons(),
            SizedBox(height: 20.h),
            _buildPopularItemsSection(context),
          ],
        ),
      ),
    );
  }
}