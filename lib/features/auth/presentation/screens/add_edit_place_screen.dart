import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/services/place_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddEditPlaceScreen extends StatefulWidget {
  final Place? place;

  const AddEditPlaceScreen({super.key, this.place});

  @override
  State<AddEditPlaceScreen> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _imageUrl;
  File? _imageFile;

  static const String _cloudName = 'dtneftgss';
  static const String _uploadPreset = 'upload_app_profile_image';

  @override
  void initState() {
    super.initState();
    if (widget.place != null) {
      _titleController.text = widget.place!.title;
      _categoryController.text = widget.place!.category;
      _descriptionController.text = widget.place!.description;
      _locationController.text = widget.place!.location;
      _imageUrl = widget.place!.imagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    setState(() {
      _isUploadingImage = true;
      _imageFile = File(pickedFile.path);
    });

    try {
      final downloadUrl = await _uploadToCloudinary(_imageFile!);
      setState(() {
        _imageUrl = downloadUrl;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل رفع الصورة: $e', style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_isUploadingImage) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      );
    }

    if (_imageUrl != null && _imageUrl!.startsWith('http')) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
              strokeWidth: 2,
            ),
          );
        },
      );
    }

    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    }

    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 40.r,
          color: Colors.grey[400],
        ),
        SizedBox(height: 8.h),
        Text(
          'اضغط لإضافة صورة',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey[600],
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  String _generatePlaceId() {
    if (widget.place != null) return widget.place!.id;

    final String title = _titleController.text.trim().toLowerCase().replaceAll(' ', '_');
    final String uniqueSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13);
    return '$title$uniqueSuffix';
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl == null && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء إضافة صورة للمكان',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final placeService = PlaceService();

      final placeId = _generatePlaceId();

      final place = Place(
        id: placeId,
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        rating: widget.place?.rating ?? 0.0,
        imagePath: _imageUrl!,
        ownerId: user.uid,
        location: _locationController.text.trim(),
      );

      if (widget.place == null) {
        await placeService.addPlace(place);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'placeId': placeId,
          'placeName': place.title,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ تم إضافة المكان بنجاح',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await placeService.updatePlace(place);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ تم تحديث المكان بنجاح',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ حدث خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.place != null;

    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل المكان' : 'إضافة مكان جديد',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey[300]!),
                          image: (_imageUrl != null && _imageUrl!.startsWith('http'))
                              ? DecorationImage(
                                  image: NetworkImage(_imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _buildImagePreview(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),


                  Text(
                    'اسم المكان *',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _titleController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'مثال: مطعم كباب باشا',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال اسم المكان';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),


                  Text(
                    'التصنيف *',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _categoryController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'مثال: مطعم، مقهى، مخبز',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال التصنيف';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),


                  Text(
                    'الوصف',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'وصف مختصر عن المكان...',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),


                  Text(
                    'الموقع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _locationController,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'مثال: الزمالك، القاهرة',
                      hintStyle: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30.h),


                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePlace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.myOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isEditing ? 'تحديث المكان' : 'إضافة المكان',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}