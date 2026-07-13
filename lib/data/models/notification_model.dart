import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // daily_bonus/new_video/vip_offer/referral/milestone/withdrawal/streak
  final String icon;
  final bool isRead;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.icon,
    required this.isRead,
    required this.timestamp,
    this.data,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 365) return '${difference.inDays ~/ 365}y ago';
    if (difference.inDays > 30) return '${difference.inDays ~/ 30}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  Color get typeColor {
    switch (type) {
      case 'daily_bonus': return Colors.amber;
      case 'new_video': return Colors.blue;
      case 'vip_offer': return Colors.purple;
      case 'referral': return Colors.green;
      case 'milestone': return Colors.orange;
      case 'withdrawal': return Colors.teal;
      case 'streak': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map mapData = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: mapData['title'] ?? '',
      body: mapData['body'] ?? '',
      type: mapData['type'] ?? 'info',
      icon: mapData['icon'] ?? '🔔',
      isRead: mapData['isRead'] ?? false,
      timestamp: (mapData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: mapData['data'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'icon': icon,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
      'data': data,
    };
  }
}
