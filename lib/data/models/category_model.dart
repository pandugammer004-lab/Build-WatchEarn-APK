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
      CategoryModel(id: 'all', name: 'All', icon: '✨', colorHex: '#6C63FF', videoCount: 0, order: 1, isActive: true),
      CategoryModel(id: 'sand', name: 'Sand Cutting', icon: '🏖️', colorHex: '#FF6B9D', videoCount: 0, order: 2, isActive: true),
      CategoryModel(id: 'soap', name: 'Soap Cutting', icon: '🧼', colorHex: '#00D9FF', videoCount: 0, order: 3, isActive: true),
      CategoryModel(id: 'slime', name: 'Slime', icon: '🟢', colorHex: '#00E676', videoCount: 0, order: 4, isActive: true),
      CategoryModel(id: 'wash', name: 'Pressure Wash', icon: '💦', colorHex: '#2196F3', videoCount: 0, order: 5, isActive: true),
      CategoryModel(id: 'paint', name: 'Paint Mixing', icon: '🎨', colorHex: '#9C27B0', videoCount: 0, order: 6, isActive: true),
      CategoryModel(id: 'cake', name: 'Cake Art', icon: '🎂', colorHex: '#E91E63', videoCount: 0, order: 7, isActive: true),
      CategoryModel(id: 'press', name: 'Hydraulic Press', icon: '🔨', colorHex: '#795548', videoCount: 0, order: 8, isActive: true),
      CategoryModel(id: 'print', name: '3D Printing', icon: '🖨️', colorHex: '#607D8B', videoCount: 0, order: 9, isActive: true),
      CategoryModel(id: 'asmr', name: 'ASMR', icon: '🎧', colorHex: '#6C63FF', videoCount: 0, order: 10, isActive: true),
    ];
  }
}
