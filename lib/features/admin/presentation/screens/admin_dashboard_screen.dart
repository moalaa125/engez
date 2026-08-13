import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: Text('لوحة الإدارة', style: TextStyle(color: MyColors.myDarkOrange, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
            icon: Icon(Icons.logout, color: MyColors.myError),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildAdminMenuButton(
              context: context,
              icon: Icons.storefront,
              title: 'طلبات الانضمام (مُلاك المطاعم)',
              subtitle: 'الموافقة أو الرفض على طلبات الملاك الجدد',
              color: Colors.blue,
              onTap: () {
                context.push('/admin/requests');
              },
            ),
            _buildAdminMenuButton(
              context: context,
              icon: Icons.local_offer,
              title: 'إدارة العروض',
              subtitle: 'قريباً: إضافة وتعديل العروض الديناميكية',
              color: MyColors.myOrange,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم تفعيل هذه الميزة قريباً')),
                );
              },
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  final firestore = FirebaseFirestore.instance;
                  await firestore.collection('offers').add({
                    'discount': '10%',
                    'title': 'على قهوتك الصباحية الأولى',
                    'icon': 'coffee',
                    'colorHex': '#FF7A00',
                  });
                  await firestore.collection('offers').add({
                    'discount': '20%',
                    'title': 'على وجبة الغداء اليوم',
                    'icon': 'fastfood',
                    'colorHex': '#EFE3DC',
                  });
                  await firestore.collection('offers').add({
                    'discount': '15%',
                    'title': 'على المخبوزات الطازجة',
                    'icon': 'bakery_dining',
                    'colorHex': '#FFB74D',
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تمت إضافة العروض التجريبية بنجاح!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.myDarkText,
              ),
              child: const Text('إضافة عروض تجريبية (Seed Offers)', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMenuButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 28.r),
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
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.sp, color: MyColors.myTextSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
