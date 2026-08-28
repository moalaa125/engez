import 'dart:async';
import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:engez/features/order/models/order_model.dart';
import 'package:go_router/go_router.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  int _getStatusIndex(String status) {
    switch (status) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'delivered':
        return 2;
      case 'cancelled':
        return -1;
      default:
        return 0;
    }
  }

  String _formatExpectedTime(DateTime? acceptedAt, int? estimatedMinutes) {
    if (acceptedAt == null || estimatedMinutes == null) return 'في انتظار المطعم...';
    
    final expected = acceptedAt.add(Duration(minutes: estimatedMinutes));
    int hour = expected.hour;
    int minute = expected.minute;
    String period = hour >= 12 ? 'مساءً' : 'صباحاً';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    String minStr = minute.toString().padLeft(2, '0');
    return '$hour:$minStr $period';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: MyColors.myWhite,
            body: Center(
              child: CircularProgressIndicator(color: MyColors.myOrange),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: MyColors.myWhite,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: MyColors.myDarkText),
                onPressed: () => context.go('/home'),
              ),
            ),
            body: Center(
              child: Text(
                'الطلب غير موجود',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: MyColors.myTextSecondary,
                ),
              ),
            ),
          );
        }

        final order = OrderModel.fromDocument(snapshot.data!);
        final statusIndex = _getStatusIndex(order.status);

        return Scaffold(
          backgroundColor: MyColors.myWhite,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: MyColors.myDarkText),
              onPressed: () => context.go('/home'),
            ),
            title: (order.status == 'delivered' || order.status == 'cancelled')
                ? const SizedBox()
                : _OrderCountdownTimer(
                    acceptedAt: order.acceptedAt,
                    estimatedMinutes: order.estimatedPreparationTime,
                  ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(right: 20.w, left: 20.w, top: 0, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 220.h,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/CookingLoopAnimation.lottie',
                      height: 180.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Timer / Status Card
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  decoration: BoxDecoration(
                    color: MyColors.myWhite,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(
                      color: MyColors.myOrange.withValues(alpha: .3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.myOrange.withValues(alpha: .1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (order.status == 'cancelled')
                        Text(
                          'تم إلغاء الطلب',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: MyColors.myError,
                          ),
                        )
                      else if (order.status == 'delivered')
                        Text(
                          'تم استلام الطلب بنجاح',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: MyColors.mySuccess,
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'يتم التجهيز النهائي...',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.myOrange,
                                ),
                              ),
                            ),
                            Lottie.asset(
                              'assets/animations/Cookingloader.lottie',
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'طلب #${order.id.substring(0, 5)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: MyColors.myTextSecondary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: MyColors.myBackground,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  order.acceptedAt == null 
                                      ? 'في انتظار المطعم...'
                                      : 'الاستلام المتوقع: ${_formatExpectedTime(order.acceptedAt, order.estimatedPreparationTime)}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: MyColors.myDarkText,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 36.h),

                if (order.status != 'cancelled') ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      children: [
                        _buildStep(
                          title: 'قيد المراجعة',
                          subtitle: 'ننتظر تأكيد المطعم للطلب',
                          isActive: statusIndex >= 0,
                          isLast: false,
                        ),
                        _buildStep(
                          title: 'جاري التجهيز',
                          subtitle: 'المطعم يقوم بتحضير طلبك الآن',
                          isActive: statusIndex >= 1,
                          isLast: false,
                        ),
                        _buildStep(
                          title: 'جاهز الان',
                          subtitle: 'يمكنك الاستلام الان',
                          isActive: statusIndex >= 1,
                          isLast: false,
                        ),
                        _buildStep(
                          title: 'تم التسليم',
                          subtitle: 'تم استلام طلبك بنجاح',
                          isActive: statusIndex >= 2,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                  
                  ElevatedButton.icon(
                    onPressed: () => _showOrderDetails(context, order),
                    icon: const Icon(Icons.receipt_long, color: MyColors.myOrange),
                    label: Text(
                      'عرض تفاصيل الفاتورة',
                      style: TextStyle(
                        color: MyColors.myDarkText,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.myBackground,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: const BorderSide(color: MyColors.myBorder),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? MyColors.myOrange : MyColors.myBackground,
                border: Border.all(
                  color: isActive ? MyColors.myOrange : MyColors.myBorder,
                  width: 2.5,
                ),
              ),
              child: isActive
                  ? Icon(Icons.check, size: 18.sp, color: MyColors.myWhite)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.5.w,
                height: 44.h,
                color: isActive ? MyColors.myOrange : MyColors.myBorder,
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? MyColors.myDarkText : MyColors.myTextSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isActive ? MyColors.myTextSecondary : MyColors.myTextSecondary.withValues(alpha: 0.5),
                  height: 1.3,
                ),
              ),
              if (!isLast) SizedBox(height: 30.h),
            ],
          ),
        ),
      ],
    );
  }

  void _showOrderDetails(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.myWhite,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.h,
            bottom: MediaQuery.of(context).padding.bottom + 24.h,
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
                'تفاصيل الفاتورة',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: MyColors.myDarkText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => Divider(height: 24.h, color: MyColors.myBorder),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.title}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: MyColors.myDarkText,
                            ),
                          ),
                        ),
                        Text(
                          '${item.price * item.quantity} ج.م',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: MyColors.myOrange,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Divider(height: 32.h, color: MyColors.myBorder, thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي:',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: MyColors.myDarkText,
                    ),
                  ),
                  Text(
                    '${order.totalPrice} ج.م',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: MyColors.myOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderCountdownTimer extends StatefulWidget {
  final DateTime? acceptedAt;
  final int? estimatedMinutes;
  
  const _OrderCountdownTimer({
    Key? key,
    required this.acceptedAt,
    required this.estimatedMinutes,
  }) : super(key: key);

  @override
  State<_OrderCountdownTimer> createState() => _OrderCountdownTimerState();
}

class _OrderCountdownTimerState extends State<_OrderCountdownTimer> {
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemainingTime();
    });
  }
  
  void _calculateRemainingTime() {
    if (widget.acceptedAt == null || widget.estimatedMinutes == null) {
      if (mounted) {
        setState(() {
          _secondsRemaining = -1;
        });
      }
      return;
    }
    
    final expectedTime = widget.acceptedAt!.add(Duration(minutes: widget.estimatedMinutes!));
    final remaining = expectedTime.difference(DateTime.now()).inSeconds;
    if (mounted) {
      setState(() {
        _secondsRemaining = remaining > 0 ? remaining : 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsRemaining == -1) {
      return Text(
        'في الانتظار...',
        style: TextStyle(
          color: MyColors.myOrange,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    if (_secondsRemaining <= 0) {
      return Text(
        '00:00',
        style: TextStyle(
          color: MyColors.myError,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      );
    }
    
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    
    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        color: MyColors.myDarkText,
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }
}
