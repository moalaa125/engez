import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/models/place_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:engez/features/order/manager/order_cubit.dart';
import 'package:engez/features/order/manager/order_state.dart';
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

Future<void> _navigateToEditPlace(BuildContext context) async {
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
  context.push('/owner-dashboard/edit-place', extra: place);
}

Future<void> _navigateToSalesReport(BuildContext context) async {
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
  context.push('/owner-dashboard/sales-report', extra: place);
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  String? _placeName;
  String? _placeId;
  bool _isOpen = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _previousPendingCount = -1;

  @override
  void initState() {
    super.initState();
    _loadPlaceData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
      final pId = data?['placeId'] as String?;
      
      bool placeIsOpen = true;
      String? actualPlaceName;
      if (pId != null) {
        final placeDoc = await FirebaseFirestore.instance.collection('places').doc(pId).get();
        if (placeDoc.exists) {
          placeIsOpen = placeDoc.data()?['isOpen'] ?? true;
          actualPlaceName = placeDoc.data()?['title'] ?? placeDoc.data()?['name']; // Fallback to name just in case
        }
      }

      setState(() {
        _placeId = pId;
        _placeName = actualPlaceName ?? data?['placeName'] ?? 'مطعمي';
        _isOpen = placeIsOpen;
      });
      
      if (pId != null && mounted) {
        context.read<OrderCubit>().fetchPlaceOrders(pId);
      }
    }
  }

  Future<void> _toggleOpenStatus(bool value) async {
    if (_placeId == null) return;
    setState(() {
      _isOpen = value;
    });
    await FirebaseFirestore.instance
        .collection('places')
        .doc(_placeId)
        .update({'isOpen': value});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          final pendingCount = state.orders.where((o) => o.status == 'pending').length;
          
          if (pendingCount > 0) {
            if (_previousPendingCount == 0 || _previousPendingCount == -1) {
              _audioPlayer.setReleaseMode(ReleaseMode.loop);
              _audioPlayer.play(AssetSource('audio/alarm.mp3'));
            }
          } else {
            _audioPlayer.stop();
          }
          _previousPendingCount = pendingCount;
        }
      },
      child: Scaffold(
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
              context.push('/owner-profile');
            },
            icon: Icon(Icons.person_outline, color: MyColors.myDarkOrange),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
            SizedBox(height: 16.h),
            Card(
              color: MyColors.myWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              child: SwitchListTile(
                title: Text(
                  'حالة المطعم',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _isOpen ? 'مفتوح ويستقبل الطلبات' : 'مغلق حالياً',
                  style: TextStyle(
                    color: _isOpen ? MyColors.mySuccess : MyColors.myError,
                    fontSize: 12.sp,
                  ),
                ),
                value: _isOpen,
                activeColor: MyColors.mySuccess,
                onChanged: _toggleOpenStatus,
                secondary: Icon(
                  _isOpen ? Icons.door_front_door : Icons.door_front_door_outlined,
                  color: _isOpen ? MyColors.mySuccess : MyColors.myError,
                ),
              ),
            ),
            SizedBox(height: 16.h),

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

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.1,
              children: [
                DashboardGridTile(
                  icon: Icons.add_location,
                  title: 'إضافة مكان',
                  color: MyColors.myOrange,
                  onTap: () {
                    context.push('/owner-dashboard/add-place');
                  },
                ),
                DashboardGridTile(
                  icon: Icons.edit_location,
                  title: 'تعديل المكان',
                  color: Colors.blue,
                  onTap: () => _navigateToEditPlace(context),
                ),
                DashboardGridTile(
                  icon: Icons.menu_book,
                  title: 'إدارة القائمة',
                  color: MyColors.mySuccess,
                  onTap: () => _navigateToManageMenu(context),
                ),
                DashboardGridTile(
                  icon: Icons.bar_chart,
                  title: 'تقارير المبيعات',
                  color: MyColors.myDarkOrange,
                  onTap: () => _navigateToSalesReport(context),
                ),
                DashboardGridTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'الطلبات الواردة',
                  color: Colors.purple,
                  onTap: () => _navigateToOwnerOrders(context),
                ),
              ],
            ),
          ],
        ),
      ),
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

class DashboardGridTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DashboardGridTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32.r),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
