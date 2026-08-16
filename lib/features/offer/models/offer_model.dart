import 'package:engez/constants/my_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OfferModel {
  final String id;
  final String discount;
  final String title;
  final String iconName;
  final String colorHex;

  OfferModel({
    required this.id,
    required this.discount,
    required this.title,
    required this.iconName,
    required this.colorHex,
  });

  factory OfferModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      discount: data['discount'] ?? '',
      title: data['title'] ?? '',
      iconName: data['icon'] ?? 'local_offer',
      colorHex: data['colorHex'] ?? 'FFFD6A00',
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'fastfood':
        return Icons.fastfood;
      case 'coffee':
        return Icons.coffee;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'local_pizza':
        return Icons.local_pizza;
      default:
        return Icons.local_offer;
    }
  }

  Color get color {
    try {
      String hex = colorHex;
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return MyColors.myOrange;
    }
  }
}
