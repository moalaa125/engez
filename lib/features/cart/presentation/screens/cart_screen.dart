import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/cart/manager/cart_cubit.dart';
import 'package:engez/features/cart/manager/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:engez/features/order/models/order_model.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/widgets/custom_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'سلتك',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100.r,
                    color: MyColors.myBorder,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'سلتك فارغة',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: MyColors.myTextSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.myOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      child: const Text(
                        'تصفح القائمة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: CustomImage(
                              imagePath: item.imagePath,
                              height: 60.h,
                              width: 60.w,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                height: 60.h,
                                width: 60.w,
                                color: MyColors.myBorder,
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: MyColors.myDarkText,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'ج.م ${item.price}',
                                  style: TextStyle(
                                    color: MyColors.myOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              InkWell(
                                onTap: () => context
                                    .read<CartCubit>()
                                    .decrementItem(item.id),
                                child: Container(
                                  width: 28.r,
                                  height: 28.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: MyColors.myOrange,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: MyColors.myOrange,
                                    size: 18.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.myDarkText,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              InkWell(
                                onTap: () => context
                                    .read<CartCubit>()
                                    .incrementItem(item.id),
                                child: CircleAvatar(
                                  radius: 14.r,
                                  backgroundColor: MyColors.myOrange,
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18.r,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                context.read<CartCubit>().removeItem(item.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي العناصر:',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: MyColors.myTextSecondary,
                            ),
                          ),
                          Text(
                            '${state.totalItemsCount}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'السعر الإجمالي:',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ج.م ${state.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: MyColors.myOrange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.myOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                          ),
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'يجب تسجيل الدخول لإتمام الطلب',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (state.isEmpty) return;

                            String resolvedPlaceId = '';
                            try {
                              final firstItem = state.items.first;
                              final placesSnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('places')
                                  .get();
                              for (var doc in placesSnapshot.docs) {
                                final menuDoc = await doc.reference
                                    .collection('menuItems')
                                    .doc(firstItem.id)
                                    .get();
                                if (menuDoc.exists) {
                                  resolvedPlaceId = doc.id;
                                  break;
                                }
                              }
                            } catch (e) {}

                            final order = OrderModel(
                              id: '',
                              customerId: user.uid,
                              placeId: resolvedPlaceId,
                              items: state.items
                                  .map(
                                    (cartItem) => OrderItem(
                                      menuItemId: cartItem.id,
                                      title: cartItem.title,
                                      price: cartItem.price,
                                      quantity: cartItem.quantity,
                                    ),
                                  )
                                  .toList(),
                              totalPrice: state.totalPrice,
                              status: 'pending',
                              createdAt: DateTime.now(),
                            );

                            context.read<OrderCubit>().createOrder(order);
                            context.read<CartCubit>().clearCart();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('تم إرسال الطلب بنجاح!'),
                                backgroundColor: MyColors.mySuccess,
                              ),
                            );
                            context.pop();
                          },
                          child: Text(
                            'إتمام الطلب',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
