import 'dart:ui';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:engez/features/cart/manager/cart_state.dart';
import 'package:engez/features/cart/models/cart_item.dart';
import 'package:engez/features/category/select_category_cubit.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/widgets/category_list.dart';
import 'package:engez/widgets/menu_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
        title: 'مشاوي مشكلة',
        imagePath: 'assets/images/burger_kbab.jpeg',
        price: 250,
      ),
      CartItem(
        id: 'shish_taouk_wrap',
        title: 'شيش طاووق ساندوتش',
        imagePath: 'assets/images/burger2.jpg',
        price: 120,
      ),
      CartItem(
        id: 'kofta_platter',
        title: 'طبق كفتة',
        imagePath: 'assets/images/burger3.jpg',
        price: 200,
      ),
    ],
    'bob_wich': const [
      CartItem(
        id: 'bob_wich_burger',
        title: 'برجر بوب ويتش',
        imagePath: 'assets/images/bob.jpeg',
        price: 150,
      ),
    ],
    'rolz': const [
      CartItem(
        id: 'rolz',
        title: 'برجر رولز',
        imagePath: 'assets/images/rolz.png',
        price: 150,
      ),
    ],
  };

  final Map<String, String> _descriptions = {
    'kbab_basha': 'مشاوي وبرجر مشوي',
    'bob_wich': 'ساندوتشات طازجة وصحية',
  };

  final Map<String, String> _descriptionsItems = {
    'mix_grill_platter': 'كفتة طريه، شيش طاووق وكباب مشوي مع أرز...',
    'shish_taouk_wrap': 'مكعبات دجاج مشوية في خبز طازج مع ثومية...',
    'kofta_platter': 'كفتة لحم مفروم فاخر مشوية إلى الكمال...',
    'bob_wich_burger': 'برجر كلاسيكي لذيذ مع صوص سري...',
    'rolz': 'برجر رولز',
  };

  Widget _buildPlaceImage(String imagePath, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(height: height, width: width);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: MyColors.myOrange,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(height: height, width: width);
        },
      );
    }
  }

  Widget _buildPlaceholderImage({double? height, double? width}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showPdfMenu(BuildContext context) {
    final String? pdfPath = _pdfPaths[place.id];
    if (pdfPath == null || pdfPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد قائمة PDF لهذا المكان حالياً.')),
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
                : () => context.push('/cart'),
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
                          ? 'السلة فارغة'
                          : 'عرض السلة (${state.totalItemsCount})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'ج.م ${state.totalPrice.toStringAsFixed(0)}',
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
            'الأصناف الأكثر طلباً',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: MyColors.myDarkText,
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
    return BlocProvider(
      create: (_) => SelectCategoryCubit(),
      child: const CategoryList(
        categories: ['الأكثر طلباً', 'وجبات', 'عصائر', 'حلويات'],
      ),
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
              child: _buildPlaceImage(place.imagePath),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 16.w,
            right: 16.w,
            child: Container(
              height: 150.h, 
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              place.title,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPdfMenu(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
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
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'القائمة',
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
                            fontSize: 13.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Divider(
                          color: Colors.grey.withValues(alpha: .3),
                          height: 1,
                          thickness: 1,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Colors.brown,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '30 دقيقة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            const CircleAvatar(
                              radius: 2.5,
                              backgroundColor: Colors.grey,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'التوصيل متاح',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13.sp,
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
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          place.rating.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
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
            SizedBox(height: 16.h),
            _buildListOfTextButtons(),
            SizedBox(height: 16.h),
            _buildPopularItemsSection(context),
          ],
        ),
      ),
    );
  }
}