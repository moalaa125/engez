import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/services/upload_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isUploading = false;
  final UploadService _uploadService = UploadService();

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final imageFile = File(pickedFile.path);
      final downloadUrl = await _uploadService.uploadImage(imageFile);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث الصورة الشخصية بنجاح!'),
            backgroundColor: MyColors.mySuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: $e'),
            backgroundColor: MyColors.myError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: MyColors.myBackground,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = user?.displayName ?? 'لا يوجد اسم';
          String? profileImageUrl = user?.photoURL;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['userName'] ?? user?.displayName ?? 'لا يوجد اسم';
            profileImageUrl = data['profileImage'] ?? user?.photoURL;
          }

          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 60.r,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : const AssetImage('assets/images/joinUs.png')
                                as ImageProvider,
                    ),
                    CircleAvatar(
                      backgroundColor: MyColors.myOrange,
                      radius: 20.r,
                      child: IconButton(
                        icon: _isUploading
                            ? SizedBox(
                                width: 20.sp,
                                height: 20.sp,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  userName,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Center(
                child: Text(
                  user?.email ?? 'لا يوجد بريد إلكتروني',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
              ),
              SizedBox(height: 40.h),
              _buildProfileOption(Icons.person, 'تعديل الملف الشخصي', () {}),
              _buildProfileOption(Icons.receipt_long, 'سجل الطلبات', () {
                context.push('/order-history');
              }),
              _buildProfileOption(Icons.lock, 'تغيير كلمة المرور', () {}),
              _buildProfileOption(Icons.settings, 'إعدادات التطبيق', () {}),
              _buildProfileOption(Icons.logout, 'تسجيل الخروج', () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) context.go('/login');
              }, isDestructive: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      color: const Color(0xFFF0F0F0),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? MyColors.myError : MyColors.myOrange,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? MyColors.myError : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
