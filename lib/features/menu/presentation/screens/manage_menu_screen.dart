import 'dart:io';
import 'package:engez/features/menu/manger/menu_item_cubit.dart';
import 'package:engez/features/menu/manger/menu_item_state.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:engez/widgets/result_feedback.dart';
import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/menu/models/menu_item_model.dart';
import 'package:engez/widgets/custom_image.dart';
import 'package:engez/widgets/custom_text_field.dart';
import 'package:engez/widgets/custom_button.dart';
import 'package:engez/models/place_model.dart';
import 'package:engez/repositories/menu_item_repository.dart';
import 'package:engez/services/upload_service.dart';

class ManageMenuScreen extends StatelessWidget {
  final Place place;
  const ManageMenuScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MenuItemCubit(MenuItemRepository(), place.id)..fetchMenuItems(),
      child: _ManageMenuScreenContent(place: place),
    );
  }
}

class _ManageMenuScreenContent extends StatefulWidget {
  final Place place;
  const _ManageMenuScreenContent({required this.place});

  @override
  State<_ManageMenuScreenContent> createState() =>
      _ManageMenuScreenContentState();
}

class _ManageMenuScreenContentState extends State<_ManageMenuScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;
  bool _isEditing = false;
  String? _editingId;
  final UploadService _uploadService = UploadService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _isUploading = true;
    });
    try {
      final url = await _uploadService.uploadImage(_imageFile!);
      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل رفع الصورة: $e'),
          backgroundColor: MyColors.myError,
        ),
      );
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _imageUrl = null;
      _imageFile = null;
      _isEditing = false;
      _editingId = null;
    });
  }

  void _editItem(MenuItem item) {
    _titleController.text = item.title;
    _descriptionController.text = item.description;
    _priceController.text = item.price.toString();
    setState(() {
      _imageUrl = item.imagePath;
      _imageFile = null;
      _isEditing = true;
      _editingId = item.id;
    });
  }

  Future<void> _saveItem() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال اسم العنصر')));
      return;
    }
    if (_imageUrl == null && _imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرجاء إضافة صورة للعنصر')));
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السعر يجب أن يكون رقماً موجباً')),
      );
      return;
    }
    final item = MenuItem(
      id: _editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _imageUrl!,
      price: price,
    );
    try {
      if (_isEditing) {
        await context.read<MenuItemCubit>().updateMenuItem(item);
      } else {
        await context.read<MenuItemCubit>().addMenuItem(item);
      }
      
      if (mounted) {
        showResultFeedback(
          context,
          isSuccess: true,
          message: _isEditing ? 'تم تحديث العنصر بنجاح' : 'تم إضافة العنصر بنجاح',
        );
      }
      _resetForm();
    } catch (e) {
      if (mounted) {
        showResultFeedback(
          context,
          isSuccess: false,
          message: 'حدث خطأ: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: Text('إدارة قائمة ${widget.place.title}'),
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 100.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: MyColors.myBorder,
                            borderRadius: BorderRadius.circular(12.r),
                            image: _imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _isUploading
                              ? const Center(child: CircularProgressIndicator())
                              : (_imageUrl == null
                                    ? Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: MyColors.myTextSecondary,
                                      )
                                    : null),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _titleController,
                        hintText: 'اسم العنصر',
                        suffixIcon: null,
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'الوصف',
                        suffixIcon: null,
                      ),
                      SizedBox(height: 12.h),
                      CustomTextField(
                        controller: _priceController,
                        hintText: 'السعر (ج.م)',
                        keyboardType: TextInputType.number,
                        suffixIcon: null,
                      ),
                      SizedBox(height: 12.h),
                      CustomButton(
                        text: _isEditing ? 'تحديث' : 'إضافة',
                        function: _saveItem,
                        buttonColor: MyColors.myOrange,
                        textColor: MyColors.myWhite,
                      ),
                      if (_isEditing) ...[
                        SizedBox(height: 12.h),
                        CustomButton(
                          text: 'إلغاء',
                          function: _resetForm,
                          buttonColor: MyColors.myBackground,
                          textColor: MyColors.myError,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<MenuItemCubit, MenuItemState>(
              builder: (context, state) {
                final isLoading = state is MenuItemLoading;
                if (state is MenuItemError) {
                  return Center(child: Text('خطأ: ${state.message}'));
                }
                if (isLoading || state is MenuItemLoaded) {
                  final items = isLoading ? [] : (state as MenuItemLoaded).items;
                  if (!isLoading && items.isEmpty) {
                    return const Center(
                      child: Text('لا توجد عناصر في القائمة'),
                    );
                  }
                  
                  final itemsCount = isLoading ? 5 : items.length;
                  
                  return Skeletonizer(
                    enabled: isLoading,
                    child: ListView.builder(
                      itemCount: itemsCount,
                      itemBuilder: (context, index) {
                        if (isLoading) {
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade300,
                            ),
                            title: const Text('اسم العنصر التجريبي'),
                            subtitle: const Text('100 ج.م'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                              ],
                            ),
                          );
                        }
                        
                        final item = items[index];
                        return ListTile(
                          leading: CustomImage(
                            imagePath: item.imagePath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item.title),
                          subtitle: Text('${item.price} ج.م'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: MyColors.myError),
                                onPressed: () {
                                  context.read<MenuItemCubit>().deleteMenuItem(
                                    item.id,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
