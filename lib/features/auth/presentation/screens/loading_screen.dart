import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:engez/constants/my_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] as String?;

      if (role == null || role.isEmpty) {
        if (mounted) context.go('/role-selection');
      } else if (role == 'customer') {
        if (mounted) context.go('/home');
      } else if (role == 'owner') {
        if (mounted) context.go('/owner-dashboard');
      } else if (role == 'admin') {
        if (mounted) context.go('/admin-dashboard');
      } else {
        if (mounted) context.go('/role-selection');
      }
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'إنجز',
              style: TextStyle(
                color: MyColors.myOrange,
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'cairo',
              ),
            ),
            SizedBox(height: 30.h),
             CircularProgressIndicator(
              color: MyColors.myOrange,
              strokeWidth: 4,
            ),
            SizedBox(height: 20.h),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16.sp,
                fontFamily: 'cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}