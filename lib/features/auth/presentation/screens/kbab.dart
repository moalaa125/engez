import 'dart:ui'; // 1. أضفنا هذه المكتبة لعمل تأثير الـ Blur
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:engez/features/cart/manager/cart_state.dart';
import 'package:engez/features/cart/models/cart_item.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class Kbab extends StatelessWidget {
  const Kbab({super.key});

  void _showPdfMenu(BuildContext context) {
    final PdfViewerController pdfViewerController = PdfViewerController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3), // تغميق خفيف للخلفية مع العزل
      builder: (BuildContext context) {
        // 2. استخدام BackdropFilter لعمل الـ Frosted Glass
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // درجة الـ Blur
          child: Dialog(
            backgroundColor: Colors.transparent, // شفاف حتى تظهر حواف الـ Container
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
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
                              pdfViewerController.zoomLevel =
                                  pdfViewerController.zoomLevel + 1;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out, color: Colors.black),
                            onPressed: () {
                              pdfViewerController.zoomLevel =
                                  pdfViewerController.zoomLevel - 1;
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
                      child: SfPdfViewer.asset(
                        'menu/menukbab.pdf',
                        controller: pdfViewerController,
                        canShowScrollHead: false,
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
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cart screen coming soon — ${state.totalItemsCount} item(s), EGP ${state.totalPrice.toStringAsFixed(0)}',
                        ),
                        backgroundColor: MyColors.myOrange,
                      ),
                    );
                  },
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
    final menuItems = const [
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
    ];

    const descriptions = {
      'mix_grill_platter':
          'Tender kofta, shish taouk, and kebab served with rice and...',
      'shish_taouk_wrap':
          'Grilled chicken cubes wrapped in fresh bread with garlic...',
      'kofta_platter':
          'Premium minced meat kofta grilled to perfection, served...',
    };

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
            children: menuItems.map((item) {
              return MenuItemCard(
                imagePath: item.imagePath,
                title: item.title,
                description: descriptions[item.id] ?? '',
                price: item.price.toStringAsFixed(0),
                onAddTap: () {
                  context.read<CartCubit>().addItem(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 800),
                      content: Text('${item.title} added to cart'),
                      backgroundColor: MyColors.myOrange,
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListOfTextButtons() {
    return const CategoryList();
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
                              'Kbab Basha',
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
                                  color: MyColors.myOrange.withValues(
                                    alpha: .1,
                                  ),
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
                  SizedBox(width: 12.w), // 3. المسافة الفاصلة بين المنيو ومربع التقييم
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildBottomBar(context),
      ),
      body: SingleChildScrollView(
        child: Column(
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