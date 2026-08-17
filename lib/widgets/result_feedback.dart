import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:engez/constants/my_colors.dart';

class ResultFeedbackScreen extends StatefulWidget {
  final bool isSuccess;
  final String message;
  final String? title;
  final VoidCallback? onDone;

  const ResultFeedbackScreen({
    super.key,
    required this.isSuccess,
    required this.message,
    this.title,
    this.onDone,
  });

  @override
  State<ResultFeedbackScreen> createState() => _ResultFeedbackScreenState();
}

class _ResultFeedbackScreenState extends State<ResultFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    if (widget.isSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(); // dismiss bottom sheet
          if (widget.onDone != null) {
            widget.onDone!();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? MyColors.mySuccess : MyColors.myError;
    final icon = widget.isSuccess ? Icons.check_circle : Icons.cancel;
    final titleText = widget.title ?? (widget.isSuccess ? 'نجاح' : 'خطأ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: MyColors.myWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Icon(icon, color: color, size: 80.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            titleText,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: 16.sp,
              color: MyColors.myDarkText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          if (!widget.isSuccess)
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (widget.onDone != null) {
                    widget.onDone!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'حسناً',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: MyColors.myWhite,
                  ),
                ),
              ),
            )
          else
            SizedBox(height: 50.h), // Placeholder for spacing consistency
        ],
      ),
    );
  }
}

Future<void> showResultFeedback(
  BuildContext context, {
  required bool isSuccess,
  required String message,
  String? title,
  VoidCallback? onDone,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => PopScope(
      canPop: false, // Prevent dismissing by back button during animation
      child: ResultFeedbackScreen(
        isSuccess: isSuccess,
        message: message,
        title: title,
        onDone: onDone,
      ),
    ),
  );
}
