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
  void _showItemFormBottomSheet(BuildContext context, {MenuItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MyColors.myWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<MenuItemCubit>(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: _MenuItemFormSheet(item: item),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myWhite,
      appBar: AppBar(
        title: Text(
          'إدارة القائمة',
          style: TextStyle(
            color: MyColors.myDarkOrange,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyColors.myWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: MyColors.myDarkText),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemFormBottomSheet(context),
        backgroundColor: MyColors.myOrange,
        icon: const Icon(Icons.add, color: MyColors.myWhite),
        label: Text(
          'إضافة صنف',
          style: TextStyle(color: MyColors.myWhite, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<MenuItemCubit, MenuItemState>(
        builder: (context, state) {
          final isLoading = state is MenuItemLoading;
          if (state is MenuItemError) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          if (isLoading || state is MenuItemLoaded) {
            final items = isLoading ? [] : (state as MenuItemLoaded).items;
            if (!isLoading && items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 80.r, color: MyColors.myBorder),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد أصناف في القائمة',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: MyColors.myTextSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }

            final itemsCount = isLoading ? 6 : items.length;

            return Skeletonizer(
              enabled: isLoading,
              child: GridView.builder(
                padding: EdgeInsets.all(16.w).copyWith(bottom: 100.h), // Padding for FAB
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: itemsCount,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return _buildLoadingCard();
                  }

                  final item = items[index];
                  return _buildItemCard(context, item);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14.h, width: 100.w, color: Colors.grey.shade300),
                SizedBox(height: 4.h),
                Container(height: 14.h, width: 60.w, color: Colors.grey.shade300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, MenuItem item) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: MyColors.myWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: CustomImage(
                    imagePath: item.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.edit,
                        color: MyColors.myInfo,
                        onTap: () => _showItemFormBottomSheet(context, item: item),
                      ),
                      SizedBox(width: 4.w),
                      _buildActionButton(
                        icon: Icons.delete,
                        color: MyColors.myError,
                        onTap: () {
                          _showDeleteConfirmation(context, item);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: MyColors.myDarkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.price} ج.م',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: MyColors.myOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16.r,
        backgroundColor: MyColors.myWhite.withValues(alpha: 0.9),
        child: Icon(icon, size: 16.r, color: color),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: MyColors.myWhite,
          title: Text('حذف الصنف', style: TextStyle(color: MyColors.myDarkText)),
          content: Text('هل أنت متأكد من حذف ${item.title}؟', style: TextStyle(color: MyColors.myTextSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء', style: TextStyle(color: MyColors.myDarkText)),
            ),
            TextButton(
              onPressed: () {
                context.read<MenuItemCubit>().deleteMenuItem(item.id);
                Navigator.pop(dialogContext);
                showResultFeedback(context, isSuccess: true, message: 'تم الحذف بنجاح');
              },
              child: Text('حذف', style: TextStyle(color: MyColors.myError, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItemFormSheet extends StatefulWidget {
  final MenuItem? item;
  const _MenuItemFormSheet({this.item});

  @override
  State<_MenuItemFormSheet> createState() => _MenuItemFormSheetState();
}

class _MenuItemFormSheetState extends State<_MenuItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  
  String? _imageUrl;
  File? _imageFile;
  bool _isUploading = false;
  bool _isSaving = false;
  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _imageUrl = widget.item?.imagePath;
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: $e'),
            backgroundColor: MyColors.myError,
          ),
        );
      }
    }
  }

  Future<void> _saveItem() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال اسم العنصر')));
      return;
    }
    if (_imageUrl == null && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إضافة صورة للعنصر')));
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السعر يجب أن يكون رقماً موجباً')));
      return;
    }
    
    setState(() => _isSaving = true);
    
    final item = MenuItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath: _imageUrl!,
      price: price,
    );
    
    try {
      if (widget.item != null) {
        await context.read<MenuItemCubit>().updateMenuItem(item);
      } else {
        await context.read<MenuItemCubit>().addMenuItem(item);
      }
      
      if (mounted) {
        Navigator.pop(context); // Close sheet
        showResultFeedback(
          context,
          isSuccess: true,
          message: widget.item != null ? 'تم تحديث الصنف بنجاح' : 'تم إضافة الصنف بنجاح',
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
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
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              widget.item != null ? 'تعديل صنف' : 'إضافة صنف جديد',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: MyColors.myDarkText,
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: MyColors.myBackground,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: MyColors.myBorder, width: 2),
                    image: _imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _isUploading
                      ? const Center(child: CircularProgressIndicator(color: MyColors.myOrange))
                      : (_imageUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40.r, color: MyColors.myOrange),
                                SizedBox(height: 4.h),
                                Text('إضافة صورة', style: TextStyle(color: MyColors.myOrange, fontSize: 12.sp)),
                              ],
                            )
                          : null),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            CustomTextField(
              controller: _titleController,
              hintText: 'اسم الصنف',
              suffixIcon: null,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _descriptionController,
              hintText: 'الوصف (مثال: دبل فراخ مع صوص)',
              suffixIcon: null,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _priceController,
              hintText: 'السعر (مثال: 125)',
              keyboardType: TextInputType.number,
              suffixIcon: null,
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: _isSaving ? 'جاري الحفظ...' : (widget.item != null ? 'حفظ التعديلات' : 'إضافة الصنف'),
              function: _isSaving ? () {} : _saveItem,
              buttonColor: MyColors.myOrange,
              textColor: MyColors.myWhite,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
