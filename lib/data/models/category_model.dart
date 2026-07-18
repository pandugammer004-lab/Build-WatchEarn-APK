import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final int videoCount;
  final int order;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.videoCount,
    required this.order,
    required this.isActive,
  });

  Color get color {
    String hex = colorHex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      colorHex: data['colorHex'] ?? '#6C63FF',
      videoCount: data['videoCount'] ?? 0,
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'colorHex': colorHex,
      'videoCount': videoCount,
      'order': order,
      'isActive': isActive,
    };
  }

  static List<CategoryModel> get defaultCategories {
    return [
      CategoryModel(id: 'cricket', name: 'Cricket Shorts', icon: '🏏', colorHex: '#4CAF50', videoCount: 0, order: 1, isActive: true),
      CategoryModel(id: 'football', name: 'Football Shorts', icon: '⚽', colorHex: '#2196F3', videoCount: 0, order: 2, isActive: true),
      CategoryModel(id: 'funny', name: 'Funny Videos', icon: '😂', colorHex: '#FFC107', videoCount: 0, order: 3, isActive: true),
    ];
  }
}
