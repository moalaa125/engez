import 'package:engez/constants/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:engez/widgets/result_feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/widgets/dashboard_menu_tile.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: Text(
          'لوحة الإدارة',
          style: TextStyle(
            color: MyColors.myDarkOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyColors.myWhite,
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
            DashboardMenuTile(
              icon: Icons.storefront,
              title: 'طلبات الانضمام (مُلاك المطاعم)',
              subtitle: 'الموافقة أو الرفض على طلبات الملاك الجدد',
              color: Colors.blue,
              onTap: () {
                context.push('/admin/requests');
              },
            ),
            DashboardMenuTile(
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
                    showResultFeedback(
                      context,
                      isSuccess: true,
                      message: 'تمت إضافة العروض التجريبية بنجاح!',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    showResultFeedback(
                      context,
                      isSuccess: false,
                      message: 'خطأ: $e',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.myDarkText,
              ),
              child: const Text(
                'إضافة عروض تجريبية (Seed Offers)',
                style: TextStyle(color: MyColors.myWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
