import 'package:flutter/material.dart';

class PlaceCategories {
  static const String all = 'الكل';
  static const List<String> list = [
    all,
    'قهوة',
    'فطار',
    'مخبز',
    'بيتزا',
    'آيس كريم',
    'مأكولات',
  ];
  static const Map<String, dynamic> icons = {
    'قهوة': Icons.coffee_outlined,
    'فطار': Icons.breakfast_dining,
    'مخبز': Icons.bakery_dining_outlined,
    'بيتزا': Icons.local_pizza_outlined,
    'آيس كريم': Icons.icecream_outlined,
    'مأكولات': Icons.food_bank_outlined,
  };
}
