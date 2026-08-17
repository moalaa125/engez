import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engez/features/offer/manager/offer_cubit.dart';
import 'package:engez/features/offer/manager/offer_state.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: Text(
          'عروض إنجز',
          style: TextStyle(
            color: MyColors.myDarkOrange,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: MyColors.myWhite,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: BlocBuilder<OfferCubit, OfferState>(
          builder: (context, state) {
            final isLoading = state is OfferLoading;
            if (state is OfferError) {
              return Center(child: Text('خطأ: ${state.message}'));
            }
            if (isLoading || state is OfferLoaded) {
              final offers = isLoading ? [] : (state as OfferLoaded).offers;
              
              if (!isLoading && offers.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد عروض حالياً',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: MyColors.myTextSecondary,
                    ),
                  ),
                );
              }
              
              final itemsCount = isLoading ? 4 : offers.length;
              
              return Skeletonizer(
                enabled: isLoading,
                child: ListView.builder(
                  itemCount: itemsCount,
                  itemBuilder: (context, index) {
                    if (isLoading) {
                      return _buildOfferCard('20%', 'خصم تجريبي', Icons.local_offer, MyColors.myOrange);
                    }
                    final offer = offers[index];
                    return _buildOfferCard(
                      offer.discount,
                      offer.title,
                      offer.iconData,
                      offer.color,
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    String discount,
    String title,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MyColors.myWhite,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 40.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discount,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: MyColors.myTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
