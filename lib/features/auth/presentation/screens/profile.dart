import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/services/upload_service.dart';
import 'package:engez/services/user_service.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:engez/widgets/custom_text_field.dart';
import 'package:engez/widgets/custom_button.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isUploading = false;
  final UploadService _uploadService = UploadService();
  final UserService _userService = UserService();
  bool _isRequestingOwner = false;
  bool _hasPendingRequest = false;

  @override
  void initState() {
    super.initState();
    _checkPendingRequest();
  }

  Future<void> _checkPendingRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final hasPending = await _userService.hasPendingOwnerRequest(user.uid);
      if (mounted) {
        setState(() {
          _hasPendingRequest = hasPending;
        });
      }
    }
  }

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
          const SnackBar(
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

  void _showEditProfileSheet(String currentName) {
    final nameController = TextEditingController(text: currentName);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: MyColors.myWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: MyColors.myDarkText,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'الاسم',
                      suffixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: 20.h),
                    isLoading
                        ? const CircularProgressIndicator(color: MyColors.myOrange)
                        : CustomButton(
                            text: 'حفظ',
                            buttonColor: MyColors.myOrange,
                            textColor: MyColors.myWhite,
                            function: () async {
                              final newName = nameController.text.trim();
                              if (newName.isEmpty) return;

                              setSheetState(() => isLoading = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .set({
                                    'userName': newName,
                                  }, SetOptions(merge: true));
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم تحديث الاسم بنجاح'),
                                      backgroundColor: MyColors.mySuccess,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('حدث خطأ: $e'),
                                      backgroundColor: MyColors.myError,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setSheetState(() => isLoading = false);
                                }
                              }
                            },
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordSheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: MyColors.myWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'تغيير كلمة المرور',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: MyColors.myDarkText,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                      controller: oldPasswordController,
                      hintText: 'كلمة المرور الحالية',
                      suffixIcon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: newPasswordController,
                      hintText: 'كلمة المرور الجديدة',
                      suffixIcon: Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 20.h),
                    isLoading
                        ? const CircularProgressIndicator(color: MyColors.myOrange)
                        : CustomButton(
                            text: 'تغيير',
                            buttonColor: MyColors.myOrange,
                            textColor: MyColors.myWhite,
                            function: () async {
                              final oldPassword = oldPasswordController.text;
                              final newPassword = newPasswordController.text;

                              if (oldPassword.isEmpty || newPassword.isEmpty) return;

                              setSheetState(() => isLoading = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null && user.email != null) {
                                  // Re-authenticate
                                  final cred = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: oldPassword,
                                  );
                                  await user.reauthenticateWithCredential(cred);
                                  // Update password
                                  await user.updatePassword(newPassword);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم تغيير كلمة المرور بنجاح'),
                                        backgroundColor: MyColors.mySuccess,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('كلمة المرور الحالية غير صحيحة أو حدث خطأ'),
                                      backgroundColor: MyColors.myError,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setSheetState(() => isLoading = false);
                                }
                              }
                            },
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _requestOwnerRole(String uid) async {
    setState(() => _isRequestingOwner = true);
    try {
      await _userService.requestOwnerRole(uid);
      setState(() => _hasPendingRequest = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلبك. ستتم مراجعته من الإدارة.'),
            backgroundColor: MyColors.mySuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تقديم الطلب: $e'),
            backgroundColor: MyColors.myError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequestingOwner = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Check if user signed in with password
    final bool hasPasswordProvider = user?.providerData
            .any((info) => info.providerId == 'password') ?? false;

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
          String userRole = 'customer';

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['userName'] ?? user?.displayName ?? 'لا يوجد اسم';
            profileImageUrl = data['profileImage'] ?? user?.photoURL;
            userRole = data['role'] ?? 'customer';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(profileImageUrl, userName, user?.email),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('الحساب'),
                      _buildProfileOption(
                        Icons.person_outline,
                        'تعديل الملف الشخصي',
                        () => _showEditProfileSheet(userName),
                      ),
                      if (hasPasswordProvider)
                        _buildProfileOption(
                          Icons.lock_outline,
                          'تغيير كلمة المرور',
                          _showChangePasswordSheet,
                        ),
                      SizedBox(height: 20.h),
                      
                      _buildSectionTitle('الطلبات'),
                      _buildProfileOption(
                        Icons.receipt_long,
                        'سجل الطلبات',
                        () {
                          context.push('/order-history');
                        },
                      ),
                      SizedBox(height: 20.h),

                      if (userRole == 'customer') ...[
                        _buildSectionTitle('تطوير العمل'),
                        _buildOwnerRequestOption(user?.uid),
                        SizedBox(height: 20.h),
                      ],

                      SizedBox(height: 10.h),
                      _buildLogoutButton(),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String? profileImageUrl, String userName, String? email) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 40.h),
      decoration: BoxDecoration(
        color: MyColors.myOrange,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40.r),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: MyColors.myWhite, width: 3),
                ),
                child: ClipOval(
                  child: CustomImage(
                    imagePath: profileImageUrl ?? 'assets/images/joinUs.png',
                    width: 100.r,
                    height: 100.r,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isUploading ? null : _pickAndUploadImage,
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: MyColors.myDarkText,
                    shape: BoxShape.circle,
                    border: Border.all(color: MyColors.myWhite, width: 2),
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            color: MyColors.myWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: MyColors.myWhite,
                          size: 16.r,
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            userName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: MyColors.myWhite,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            email ?? 'لا يوجد بريد إلكتروني',
            style: TextStyle(
              fontSize: 14.sp,
              color: MyColors.myWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, right: 8.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: MyColors.myTextSecondary,
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: MyColors.myWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: MyColors.myBackgroundAlt,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: MyColors.myOrange, size: 24.r),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: MyColors.myDarkText,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.r, color: MyColors.myTextSecondary),
      ),
      ),
    );
  }

  Widget _buildOwnerRequestOption(String? uid) {
    if (_hasPendingRequest) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: MyColors.myWarning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: MyColors.myWarning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: MyColors.myWarning),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'طلب الانضمام كصاحب مطعم قيد المراجعة',
                style: TextStyle(color: MyColors.myDarkText, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return _buildProfileOption(
      Icons.storefront,
      'اطلب الانضمام كصاحب مطعم',
      () {
        if (uid != null && !_isRequestingOwner) {
          _requestOwnerRole(uid);
        }
      },
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) context.go('/login');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: MyColors.myWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: MyColors.myError),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: MyColors.myError, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
