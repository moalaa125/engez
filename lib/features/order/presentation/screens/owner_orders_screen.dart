import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/order/manager/order_state.dart';
import 'package:engez/models/place_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OwnerOrdersScreen extends StatefulWidget {
  final Place place;
  const OwnerOrdersScreen({super.key, required this.place});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchPlaceOrders(widget.place.id);
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'delivered':
        return 'تم التوصيل';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: const Text(
          'الطلبات الواردة',
          style: TextStyle(fontFamily: 'cairo'),
        ),
        backgroundColor: MyColors.myWhite,
        centerTitle: true,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }
          if (state is OrderLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد طلبات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: MyColors.myTextSecondary,
                  ),
                ),
              );
            }
            return ListView.builder(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                _getStatusText(order.status),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.title}',
                                  style: TextStyle(fontSize: 14.sp),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        SizedBox(height: 16.h),
                        if (order.status == 'pending') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.mySuccess,
                                  ),
                                  onPressed: () => context
                                      .read<OrderCubit>()
                                      .updateOrderStatus(order.id, 'confirmed'),
                                  child: const Text(
                                    'تأكيد',
                                    style: TextStyle(color: MyColors.myWhite),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.myError,
                                  ),
                                  onPressed: () => context
                                      .read<OrderCubit>()
                                      .updateOrderStatus(order.id, 'cancelled'),
                                  child: const Text(
                                    'رفض',
                                    style: TextStyle(color: MyColors.myWhite),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
