import 'package:engez/constants/my_colors.dart';
import 'package:engez/features/admin/manager/admin_requests_cubit.dart';
import 'package:engez/features/admin/manager/admin_requests_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:engez/features/admin/models/admin_request_model.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminRequestsCubit>().fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.myBackground,
      appBar: AppBar(
        title: const Text(
          'طلبات الانضمام',
          style: TextStyle(fontFamily: 'cairo'),
        ),
        backgroundColor: MyColors.myWhite,
        centerTitle: true,
      ),
      body: BlocBuilder<AdminRequestsCubit, AdminRequestsState>(
        builder: (context, state) {
          final isLoading = state is AdminRequestsLoading;
          if (state is AdminRequestsError) {
            return Center(child: Text('حدث خطأ: ${state.message}'));
          }
          if (isLoading || state is AdminRequestsLoaded) {
            final requests = isLoading ? List.generate(4, (index) => AdminRequestModel(
              uid: '',
              status: 'pending',
              userName: 'اسم تجريبي للمالك',
              email: 'test@example.com',
            )) : (state as AdminRequestsLoaded).requests;
            if (!isLoading && requests.isEmpty) {
              return Center(
                child: Text(
                  'لا توجد طلبات انضمام جديدة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: MyColors.myTextSecondary,
                  ),
                ),
              );
            }
            return Skeletonizer(
              enabled: isLoading,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  color: MyColors.myWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاسم: ${request.userName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'البريد: ${request.email}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.mySuccess,
                                ),
                                onPressed: () {
                                  context
                                      .read<AdminRequestsCubit>()
                                      .approveRequest(request.uid);
                                },
                                child: const Text(
                                  'موافقة',
                                  style: TextStyle(color: MyColors.myWhite),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.myError,
                                ),
                                onPressed: () {
                                  context
                                      .read<AdminRequestsCubit>()
                                      .rejectRequest(request.uid);
                                },
                                child: const Text(
                                  'رفض',
                                  style: TextStyle(color: MyColors.myWhite),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
