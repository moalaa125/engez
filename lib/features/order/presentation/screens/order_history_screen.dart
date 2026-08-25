import 'dart:ui';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/place/place_cubit.dart';
import 'package:engez/features/place/place_state.dart';
import 'package:engez/features/order/manager/order_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:engez/features/order/models/order_model.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<OrderCubit>().fetchCustomerOrders(user.uid);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'delivered':
        return 'تم الاستلام';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return MyColors.myWarning;
      case 'confirmed':
        return MyColors.myInfo;
      case 'delivered':
        return MyColors.mySuccess;
      case 'cancelled':
        return MyColors.myError;
      default:
        return MyColors.myTextSecondary;
    }
  }

  Widget _buildSummaryCard(List<OrderModel> orders, bool isLoading) {
    double totalSpent = 0;
    Map<String, int> placeFreq = {};

    for (var order in orders) {
      if (order.status != 'cancelled') {
        totalSpent += order.totalPrice;
        placeFreq[order.placeId] = (placeFreq[order.placeId] ?? 0) + 1;
      }
    }

    String mostFrequentPlaceId = '';
    int maxFreq = 0;
    placeFreq.forEach((key, value) {
      if (value > maxFreq) {
        maxFreq = value;
        mostFrequentPlaceId = key;
      }
    });

    String favoritePlaceName = 'لا يوجد';
    if (mostFrequentPlaceId.isNotEmpty && !isLoading) {
      final placeState = context.read<PlaceCubit>().state;
      if (placeState is PlaceLoaded) {
        try {
          final place = placeState.places.firstWhere(
            (p) => p.id == mostFrequentPlaceId,
          );
          favoritePlaceName = place.title;
        } catch (_) {}
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: MyColors.myOrange.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: .5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        color: MyColors.myOrange,
                        size: 28.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'إجمالي المدفوعات',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: MyColors.myDarkText.withValues(alpha: .7),
                          fontFamily: 'cairo',
                        ),
                      ),
                      Text(
                        '${totalSpent.toStringAsFixed(0)} ج.م',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: MyColors.myDarkText,
                          fontFamily: 'cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60.h,
                  color: Colors.white.withValues(alpha: .5),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: MyColors.myOrange,
                        size: 28.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'المكان المفضل',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: MyColors.myDarkText.withValues(alpha: .7),
                          fontFamily: 'cairo',
                        ),
                      ),
                      Text(
                        isLoading ? 'جاري التحميل...' : favoritePlaceName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: MyColors.myDarkText,
                          fontFamily: 'cairo',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        scrolledUnderElevation: 0,

        title: const Text('سجل الطلبات', style: TextStyle(fontFamily: 'cairo')),
        backgroundColor: MyColors.myWhite,
        centerTitle: true,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final isLoading = state is OrderLoading;
          if (state is OrderError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }
          if (isLoading || state is OrderLoaded) {
            final orders = isLoading
                ? List.generate(
                    4,
                    (index) => OrderModel(
                      id: '12345678',
                      customerId: '',
                      placeId: '',
                      items: [
                        OrderItem(
                          menuItemId: '',
                          title: 'عنصر تجريبي',
                          price: 100,
                          quantity: 2,
                        ),
                      ],
                      totalPrice: 200,
                      status: 'pending',
                      createdAt: DateTime.now(),
                    ),
                  )
                : (state as OrderLoaded).orders;

            return Skeletonizer(
              enabled: isLoading,
              child: Column(
                children: [
                  _buildSummaryCard(orders, isLoading),
                  Expanded(
                    child: (!isLoading && orders.isEmpty)
                        ? Center(
                            child: Text(
                              'لا توجد طلبات سابقة',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: MyColors.myTextSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 16.h),
                                color: MyColors.myWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'طلب #${order.id.length > 5 ? order.id.substring(0, 5) : order.id}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                order.status,
                                              ).withValues(alpha: .1),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Text(
                                              _getStatusText(order.status),
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  order.status,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      ...order.items.map(
                                        (item) => Padding(
                                          padding: EdgeInsets.only(bottom: 4.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${item.quantity}x ${item.title}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                              Text(
                                                'ج.م ${item.price * item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(height: 24.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'الإجمالي',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          Text(
                                            'ج.م ${order.totalPrice}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                              color: MyColors.myOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
