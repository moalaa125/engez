import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/services/user_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;
  bool isLoading = false;

  final List<Map<String, dynamic>> roles = [
    {
      'id': 'customer',
      'title': 'عميل',
      'icon': Icons.person_outline,
      'description': 'أبحث عن أماكن وأطلب طعاماً',
    },
    {
      'id': 'owner',
      'title': 'صاحب مطعم',
      'icon': Icons.storefront_outlined,
      'description': 'أدير مطعمي وأضيف العروض',
    },
  ];

  Future<void> _saveRoleAndNavigate() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء اختيار دورك')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final existingRole = doc.data()?['role'] as String?;

      if (existingRole == 'owner') {
        if (mounted) context.go('/owner-dashboard');
        return;
      } else if (existingRole == 'admin') {
        if (mounted) context.go('/admin/requests');
        return;
      }

      if (selectedRole == 'customer') {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'role': 'customer',
        }, SetOptions(merge: true));
        if (mounted) context.go('/home');
      } else if (selectedRole == 'owner') {
        await UserService().requestOwnerRole(user.uid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم إرسال طلبك. ستتم مراجعته من الإدارة. أنت الآن مسجل كعميل.',
              ),
            ),
          );
          context.go('/home');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: AppBar(
        title: const Text('اختر دورك'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: MyColors.myWhite,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            Text(
              'لنكمل معاً! أخبرنا من أنت؟',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'اختر الدور المناسب لك لتخصيص التجربة',
              style: TextStyle(
                fontSize: 16.sp,
                color: MyColors.myTextSecondary,
              ),
            ),
            SizedBox(height: 40.h),
            ...roles.map((role) => _buildRoleCard(role)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveRoleAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.myOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: MyColors.myWhite)
                    : Text(
                        'متابعة',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: MyColors.myWhite,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    final isSelected = selectedRole == role['id'];
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.myOrange.withValues(alpha: 0.1)
              : MyColors.myBackgroundAlt,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? MyColors.myOrange : MyColors.myBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: MyColors.myOrange.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              role['icon'],
              size: 36.r,
              color: isSelected ? MyColors.myOrange : MyColors.myTextSecondary,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role['title'],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? MyColors.myOrange : MyColors.myDarkText,
                    ),
                  ),
                  Text(
                    role['description'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: MyColors.myTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: MyColors.myOrange, size: 28.r),
          ],
        ),
      ),
    );
  }
}
