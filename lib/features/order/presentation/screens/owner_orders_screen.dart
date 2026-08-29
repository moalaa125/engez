import 'package:engez/constants/my_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/order/manager/order_state.dart';
import 'package:engez/models/place_model.dart';
  import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:engez/features/order/models/order_model.dart';
import 'package:audioplayers/audioplayers.dart';

class OwnerOrdersScreen extends StatefulWidget {
  final Place place;
  const OwnerOrdersScreen({super.key, required this.place});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _previousPendingCount = -1;

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchPlaceOrders(widget.place.id);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderLoaded) {
            final pendingCount = state.orders.where((o) => o.status == 'pending').length;
            
            if (pendingCount > 0) {
              // Start looping if it wasn't playing before
              if (_previousPendingCount == 0 || _previousPendingCount == -1) {
                _audioPlayer.setReleaseMode(ReleaseMode.loop);
                _audioPlayer.play(AssetSource('audio/alarm.mp3'));
              }
            } else {
              // Stop if there are no pending orders
              _audioPlayer.stop();
            }
            
            _previousPendingCount = pendingCount;
          }
        },
        builder: (context, state) {
          final isLoading = state is OrderLoading;
          if (state is OrderError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }
          if (isLoading || state is OrderLoaded) {
            final orders = isLoading ? List.generate(4, (index) => OrderModel(
              id: '12345678',
              customerId: '',
              placeId: '',
              items: [OrderItem(menuItemId: '', title: 'عنصر تجريبي', price: 100, quantity: 2)],
              totalPrice: 200,
              status: 'pending',
              createdAt: DateTime.now(),
            )) : (state as OrderLoaded).orders;
            
            if (!isLoading && orders.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد طلبات واردة حالياً',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: MyColors.myTextSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            
            return Skeletonizer(
              enabled: isLoading,
              child: ListView.builder(
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
                                  onPressed: () => _showAcceptOrderBottomSheet(context, order.id),
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
                                  onPressed: () {
                                    context
                                        .read<OrderCubit>()
                                        .updateOrderStatus(order.id, 'cancelled');
                                        
                                    FirebaseAnalytics.instance.logEvent(
                                      name: 'order_cancelled',
                                      parameters: {
                                        'order_id': order.id,
                                        'total_price': order.totalPrice,
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'رفض',
                                    style: TextStyle(color: MyColors.myWhite),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (order.status == 'confirmed') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.myOrange,
                              ),
                              onPressed: () => context
                                  .read<OrderCubit>()
                                  .updateOrderStatus(order.id, 'ready'),
                              child: const Text(
                                'جاهز للاستلام',
                                style: TextStyle(color: MyColors.myWhite, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ] else if (order.status == 'ready') ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.mySuccess,
                              ),
                              onPressed: () => context
                                  .read<OrderCubit>()
                                  .updateOrderStatus(order.id, 'delivered'),
                              child: const Text(
                                'تم التسليم بنجاح',
                                style: TextStyle(color: MyColors.myWhite, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  void _showAcceptOrderBottomSheet(BuildContext context, String orderId) {
    int selectedMinutes = 15;
    final customTimeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColors.myWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.symmetric(horizontal: 140.w),
                    decoration: BoxDecoration(
                      color: MyColors.myBorder,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'وقت التجهيز المتوقع',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: MyColors.myDarkText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    alignment: WrapAlignment.center,
                    children: [5, 10, 15, 20, 30].map((mins) {
                      final isSelected = selectedMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins دقيقة', style: TextStyle(
                          color: isSelected ? MyColors.myWhite : MyColors.myDarkText,
                          fontWeight: FontWeight.bold,
                        )),
                        selected: isSelected,
                        selectedColor: MyColors.myOrange,
                        backgroundColor: MyColors.myBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          side: BorderSide.none,
                        ),
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedMinutes = mins;
                              customTimeController.clear();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: customTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'وقت مخصص (بالدقائق)',
                      filled: true,
                      fillColor: MyColors.myBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          selectedMinutes = int.tryParse(value) ?? 15;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrderCubit>().acceptOrder(orderId, selectedMinutes);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.myOrange,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'تأكيد واستلام الطلب',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: MyColors.myWhite,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
