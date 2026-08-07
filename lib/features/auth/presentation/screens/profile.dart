import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isUploading = false;

  static const String _cloudName = 'dtneftgss';
  static const String _uploadPreset = 'upload_app_profile_image';  

  Future<String?> _uploadToCloudinary(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    var request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var data = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      throw Exception('Cloudinary upload failed: ${data['error']['message']}');
    }
  }

  // Future<void> _pickAndUploadImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: ImageSource.gallery,
  //     imageQuality: 70,     
  //   );

  //   if (pickedFile == null) return;

  //   setState(() => _isUploading = true);

  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) return;

  //     File imageFile = File(pickedFile.path);

  //     final downloadUrl = await _uploadToCloudinary(imageFile);

  //     if (downloadUrl == null) throw Exception('Upload failed');

  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .update({'profileImage': downloadUrl});

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Profile picture updated successfully!'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to upload image: $e')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isUploading = false);
  //   }
  // }

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
          String userName = 'Loading...';
          String? profileImageUrl;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['userName'] ?? 'No Name';
            profileImageUrl =
                data.containsKey('profileImage') ? data['profileImage'] : null;
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
                        onPressed: _isUploading ? null : null,
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
                  user?.email ?? 'No Email',
                  style: TextStyle(fontSize: 16.sp, color: Colors.black),
                ),
              ),
              SizedBox(height: 40.h),
              _buildProfileOption(Icons.person, 'Edit Profile', () {}),
              _buildProfileOption(Icons.lock, 'Change Password', () {}),
              _buildProfileOption(Icons.settings, 'App Settings', () {}),
              _buildProfileOption(
                Icons.logout,
                'Logout',
                () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('loginPage');
                },
                isDestructive: true,
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : MyColors.myOrange,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
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