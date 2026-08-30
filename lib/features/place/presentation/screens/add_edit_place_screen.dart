import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:engez/widgets/result_feedback.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/place/place_cubit.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:engez/services/upload_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:engez/widgets/custom_text_field.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/features/location/presentation/screens/map_picker_screen.dart';


class AddEditPlaceScreen extends StatefulWidget {
  final Place? place;
  const AddEditPlaceScreen({super.key, this.place});

  @override
  State<AddEditPlaceScreen> createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedCategory = 'مطعم';
  final List<String> _categories = ['مطعم', 'كافيه', 'مطعم وكافيه', 'مخبز', 'حلويات'];
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  List<Branch> _branches = [];

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _imageUrl;
  File? _imageFile;

  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();
    if (widget.place != null) {
      _titleController.text = widget.place!.title;
      if (_categories.contains(widget.place!.category)) {
        _selectedCategory = widget.place!.category;
      } else {
        _selectedCategory = 'مطعم';
      }
      _descriptionController.text = widget.place!.description;
      _locationController.text = widget.place!.location;
      _branches = List.from(widget.place!.branches);
      _imageUrl = widget.place!.imagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
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
      final downloadUrl = await _uploadService.uploadImage(_imageFile!);
      setState(() {
        _imageUrl = downloadUrl;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل رفع الصورة: $e',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: MyColors.myError,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_isUploadingImage) {
      return const Center(
        child: CircularProgressIndicator(color: MyColors.myOrange),
      );
    }
    if (_imageUrl != null && _imageUrl!.startsWith('http')) {
      return CustomImage(
        imagePath: _imageUrl!,
        fit: BoxFit.cover,
      );
    }
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40.r, color: MyColors.myTextSecondary),
        SizedBox(height: 8.h),
        Text(
          'اضغط لإضافة صورة',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: MyColors.myTextSecondary,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Future<String> _generatePlaceId() async {
    if (widget.place != null) return widget.place!.id;

    final String title = _titleController.text.trim().toLowerCase().replaceAll(
      ' ',
      '_',
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('title', isEqualTo: _titleController.text.trim())
        .get();

    if (snapshot.docs.isEmpty) {
      return title;
    } else {
      final String uniqueSuffix = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(8, 13);
      return '${title}_$uniqueSuffix';
    }
  }

  
  

Future<void> _savePlace() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم المكان', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: MyColors.myOrange),
      );
      return;
    }
    if (_branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد الموقع على الخريطة', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: MyColors.myOrange),
      );
      return;
    }
    
    if (_branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة فرع واحد على الأقل', style: TextStyle(fontFamily: 'Cairo')), backgroundColor: MyColors.myOrange),
      );
      return;
    }
    if (_imageUrl == null && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء إضافة صورة للمكان',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: MyColors.myOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final placeId = await _generatePlaceId();

      final place = Place(
        id: placeId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        rating: widget.place?.rating ?? 0.0,
        imagePath: _imageUrl!,
        ownerId: user.uid,
        location: _locationController.text.trim(),
        branches: _branches,
      );

      if (widget.place == null) {
        await context.read<PlaceCubit>().addPlace(place);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'placeId': placeId, 'placeName': place.title});
        if (mounted) {
          showResultFeedback(
            context,
            isSuccess: true,
            message: 'تم إضافة المكان بنجاح',
            onDone: () {
              if (mounted) context.pop(true);
            },
          );
        }
      } else {
        await context.read<PlaceCubit>().updatePlace(place);
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'placeName': place.title});

        if (mounted) {
          showResultFeedback(
            context,
            isSuccess: true,
            message: 'تم تحديث المكان بنجاح',
            onDone: () {
              if (mounted) context.pop(true);
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showResultFeedback(
          context,
          isSuccess: false,
          message: 'حدث خطأ: $e',
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
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
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
                      color: MyColors.myWhite,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: MyColors.myBorder),
                      image:
                          (_imageUrl != null && _imageUrl!.startsWith('http'))
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
                  color: MyColors.myDarkText,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'مثال: مطعم كباب باشا',
                suffixIcon: Icons.restaurant,
                controller: _titleController,
              ),
              SizedBox(height: 16.h),

              Text(
                'التصنيف *',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: MyColors.myDarkText,
                ),
              ),
              SizedBox(height: 8.h),
                            Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _categories.map((category) {
                  return ChoiceChip(
                    label: Text(category, style: const TextStyle(fontFamily: 'Cairo')),
                    selected: _selectedCategory == category,
                    selectedColor: MyColors.myOrange.withValues(alpha: 0.2),
                    backgroundColor: MyColors.myBackground,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? MyColors.myOrange : MyColors.myDarkText,
                      fontWeight: _selectedCategory == category ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              
              SizedBox(height: 16.h),

              Text(
                'الوصف',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: MyColors.myDarkText,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'وصف مختصر عن المكان...',
                suffixIcon: Icons.description,
                controller: _descriptionController,
              ),
              SizedBox(height: 16.h),

              Text(
                'الموقع الجغرافي *',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: MyColors.myDarkText,
                ),
              ),
              SizedBox(height: 8.h),
              CustomButton(
                text: _branches.isEmpty ? 'تحديد الموقع على الخريطة' : 'تم تحديد الموقع بنجاح ✅',
                buttonColor: _branches.isEmpty ? MyColors.myWhite : MyColors.mySuccess.withValues(alpha: 0.1),
                textColor: _branches.isEmpty ? MyColors.myOrange : MyColors.mySuccess,
                iconPath: null,
                function: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapPickerScreen()),
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _branches = [
                        Branch(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: 'الفرع الرئيسي',
                          latitude: result['latitude'],
                          longitude: result['longitude'],
                        )
                      ];
                    });
                  }
                },
              ),
              if (_branches.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'يجب تحديد موقع المطعم',
                    style: TextStyle(color: MyColors.myError, fontSize: 12.sp, fontFamily: 'Cairo'),
                  ),
                ),
              SizedBox(height: 30.h),

              _isLoading 
                ? const Center(child: CircularProgressIndicator(color: MyColors.myOrange))
                : CustomButton(
                    text: isEditing ? 'تحديث المكان' : 'إضافة المكان',
                    buttonColor: MyColors.myOrange,
                    textColor: MyColors.myWhite,
                    function: _savePlace,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
