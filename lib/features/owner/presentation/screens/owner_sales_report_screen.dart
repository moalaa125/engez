import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/order/manager/order_state.dart';
import 'package:engez/features/order/models/order_model.dart';
import 'package:engez/models/place_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class OwnerSalesReportScreen extends StatefulWidget {
  final Place place;
  const OwnerSalesReportScreen({super.key, required this.place});

  @override
  State<OwnerSalesReportScreen> createState() => _OwnerSalesReportScreenState();
}

class _OwnerSalesReportScreenState extends State<OwnerSalesReportScreen> {
  String _selectedFilter = 'today'; // 'today', 'month', 'year', 'all'

  @override
  void initState() {
    super.initState();
    context.read<OrderCubit>().fetchPlaceOrders(widget.place.id);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  bool _isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }

  List<OrderModel> _filterOrders(List<OrderModel> allOrders) {
    final now = DateTime.now();
    return allOrders.where((order) {
      if (order.status != 'delivered') return false; // Only count completed orders for revenue
      
      switch (_selectedFilter) {
        case 'today':
          return _isSameDay(order.createdAt, now);
        case 'month':
          return _isSameMonth(order.createdAt, now);
        case 'year':
          return _isSameYear(order.createdAt, now);
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  Map<String, List<OrderModel>> _groupOrdersByDate(List<OrderModel> orders) {
    Map<String, List<OrderModel>> grouped = {};
    for (var order in orders) {
      String dateStr = DateFormat('yyyy-MM-dd').format(order.createdAt);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(order);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: const Text(
          'تقارير المبيعات',
          style: TextStyle(fontFamily: 'cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: MyColors.myWhite,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MyColors.myDarkText),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/owner-dashboard');
            }
          },
        ),
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
            final filteredOrders = _filterOrders(state.orders);
            final double totalRevenue = filteredOrders.fold(0, (sum, item) => sum + item.totalPrice);
            final groupedOrders = _groupOrdersByDate(filteredOrders);
            
            // Sort dates descending
            final sortedDates = groupedOrders.keys.toList()..sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                _buildFilterChips(),
                _buildSummaryCards(totalRevenue, filteredOrders.length),
                Expanded(
                  child: filteredOrders.isEmpty
                      ? const Center(child: Text('لا توجد مبيعات في هذه الفترة'))
                      : ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            final date = sortedDates[index];
                            final dayOrders = groupedOrders[date]!;
                            final dayTotal = dayOrders.fold(0.0, (sum, item) => sum + item.totalPrice);
                            
                            return _buildDateGroup(date, dayOrders, dayTotal);
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: MyColors.myWhite,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('today', 'اليوم'),
            SizedBox(width: 8.w),
            _buildChip('month', 'هذا الشهر'),
            SizedBox(width: 8.w),
            _buildChip('year', 'هذا العام'),
            SizedBox(width: 8.w),
            _buildChip('all', 'كل الأوقات'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        }
      },
      selectedColor: MyColors.myOrange,
      labelStyle: TextStyle(
        color: isSelected ? MyColors.myWhite : MyColors.myDarkText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSummaryCards(double revenue, int orderCount) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: MyColors.mySuccess.withValues(alpha: 0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r), side: const BorderSide(color: MyColors.mySuccess)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Icon(Icons.attach_money, color: MyColors.mySuccess, size: 32.r),
                    SizedBox(height: 8.h),
                    Text('إجمالي المبيعات', style: TextStyle(color: MyColors.myTextSecondary, fontSize: 14.sp)),
                    Text('ج.م ${revenue.toStringAsFixed(0)}', style: TextStyle(color: MyColors.mySuccess, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Card(
              color: MyColors.myOrange.withValues(alpha: 0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r), side: const BorderSide(color: MyColors.myOrange)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long, color: MyColors.myOrange, size: 32.r),
                    SizedBox(height: 8.h),
                    Text('الطلبات المكتملة', style: TextStyle(color: MyColors.myTextSecondary, fontSize: 14.sp)),
                    Text('$orderCount', style: TextStyle(color: MyColors.myOrange, fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(String date, List<OrderModel> orders, double dayTotal) {
    // Format date nicely
    final DateTime parsedDate = DateTime.parse(date);
    final String displayDate = DateFormat('EEEE, d MMM yyyy', 'ar').format(parsedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayDate,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: MyColors.myDarkOrange),
              ),
              Text(
                'ج.م ${dayTotal.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: MyColors.mySuccess),
              ),
            ],
          ),
        ),
        ...orders.map((order) => Card(
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              child: ListTile(
                title: Text('طلب #${order.id.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('hh:mm a', 'ar').format(order.createdAt)),
                trailing: Text('ج.م ${order.totalPrice}', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.myOrange, fontSize: 16.sp)),
              ),
            )),
        Divider(height: 24.h),
      ],
    );
  }
}
