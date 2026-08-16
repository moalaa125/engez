import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/models/place_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:engez/widgets/dashboard_menu_tile.dart';
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

Future<void> _navigateToManageMenu(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final placeId = doc.data()?['placeId'] as String?;
  if (!context.mounted) return;
  if (placeId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لم يتم العثور على مكان مرتبط بحسابك')),
    );
    return;
  }
  final placeDoc = await FirebaseFirestore.instance
      .collection('places')
      .doc(placeId)
      .get();
  if (!placeDoc.exists) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('المكان غير موجود')));
    return;
  }
  final place = Place.fromDoc(placeDoc);
  if (!context.mounted) return;
  context.push('/owner-dashboard/manage-menu', extra: place);
}

Future<void> _navigateToOwnerOrders(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final placeId = doc.data()?['placeId'] as String?;
  if (!context.mounted) return;
  if (placeId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لم يتم العثور على مكان مرتبط بحسابك')),
    );
    return;
  }
  final placeDoc = await FirebaseFirestore.instance
      .collection('places')
      .doc(placeId)
      .get();
  if (!placeDoc.exists) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('المكان غير موجود')));
    return;
  }
  final place = Place.fromDoc(placeDoc);
  if (!context.mounted) return;
  context.push('/owner-dashboard/orders', extra: place);
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String? _placeName;

  @override
  void initState() {
    super.initState();
    _loadPlaceData();
  }

  Future<void> _loadPlaceData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _placeName = data?['placeName'] ?? 'مطعمي';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        title: Text(
          'لوحة التحكم',
          style: TextStyle(
            color: MyColors.myDarkOrange,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/profile');
            },
            icon: Icon(Icons.person_outline, color: MyColors.myDarkOrange),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: MyColors.myOrange,
                  child: Icon(
                    Icons.storefront,
                    color: MyColors.myWhite,
                    size: 30.r,
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك في',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: MyColors.myTextSecondary,
                      ),
                    ),
                    Text(
                      _placeName ?? 'مطعمي',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: MyColors.myDarkOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                _buildStatCard('المنتجات', '12', Icons.fastfood),
                SizedBox(width: 12.w),
                _buildStatCard('الطلبات', '8', Icons.shopping_bag),
                SizedBox(width: 12.w),
                _buildStatCard('التقييم', '4.5', Icons.star),
              ],
            ),
            SizedBox(height: 24.h),

            Text(
              'إدارة المطعم',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myDarkOrange,
              ),
            ),
            SizedBox(height: 12.h),

            DashboardMenuTile(
              icon: Icons.add_location,
              title: 'إضافة مكان',
              subtitle: 'أضف مطعمك أو مقهىك الجديد',
              color: MyColors.myOrange,
              onTap: () {
                context.push('/owner-dashboard/add-place');
              },
            ),

            DashboardMenuTile(
              icon: Icons.edit_location,
              title: 'تعديل المكان',
              subtitle: 'تحديث معلومات مطعمك',
              color: Colors.blue,
              onTap: () {},
            ),

            DashboardMenuTile(
              icon: Icons.menu_book,
              title: 'إدارة القائمة',
              subtitle: 'أضف أو عدل عناصر القائمة',
              color: MyColors.mySuccess,
              onTap: () => _navigateToManageMenu(context),
            ),

            DashboardMenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'الطلبات الواردة',
              subtitle: 'شاهد الطلبات الجديدة',
              color: Colors.purple,
              onTap: () => _navigateToOwnerOrders(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: MyColors.myWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: MyColors.myOrange, size: 24.r),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myDarkOrange,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: MyColors.myTextSecondary),
            ),
          ],
        ),
      ),
    );
  }


}
