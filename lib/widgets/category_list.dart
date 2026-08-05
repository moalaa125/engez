import 'package:engez/features/category/select_category_cubit.dart';
import 'package:engez/features/category/select_category_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_text_bubble.dart';

class CategoryList extends StatelessWidget {
  final List<String> categories = const ['Popular', 'Meals', 'Juices', 'Desserts'];

  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectCategoryCubit(),
      child: BlocBuilder<SelectCategoryCubit, SelectCategoryState>(
        builder: (context, state) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: CustomTextBubble(
                      text: categories[index],
                      isSelected: state.selectedIndex == index,
                      onTap: () {
                        context.read<SelectCategoryCubit>().selectCategory(index);
                      },
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}