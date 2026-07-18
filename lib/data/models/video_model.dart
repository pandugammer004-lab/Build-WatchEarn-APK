import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String videoUrl;
  final String title;
  final String description;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int duration; // seconds
  final int views;
  final int likes;
  final DateTime publishedAt;
  final bool isTrending;
  final bool isFeatured;
  final bool isVipOnly;
  final bool isActive;
  final int order;
  final List<String> tags;
  final String? thumbnailUrl;

  VideoModel({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.duration,
    required this.views,
    required this.likes,
    required this.publishedAt,
    required this.isTrending,
    required this.isFeatured,
    required this.isVipOnly,
    required this.isActive,
    required this.order,
    required this.tags,
    this.thumbnailUrl,
  });

  String get thumbnail => thumbnailUrl != null && thumbnailUrl!.isNotEmpty 
      ? thumbnailUrl! 
      : 'https://via.placeholder.com/400x600.png?text=No+Thumbnail';

  String get formattedDuration {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get formattedViews {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
  
  String get formattedLikes {
    if (likes >= 1000000) return '${(likes / 1000000).toStringAsFixed(1)}M';
    if (likes >= 1000) return '${(likes / 1000).toStringAsFixed(1)}K';
    return likes.toString();
  }
  
  String get timeAgo {
    final difference = DateTime.now().difference(publishedAt);
    if (difference.inDays > 365) return '${difference.inDays ~/ 365}y ago';
    if (difference.inDays > 30) return '${difference.inDays ~/ 30}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return VideoModel(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? data['youtubeId'] ?? '', // Fallback to old schema temporarily so it doesn't crash
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      categoryIcon: data['categoryIcon'] ?? '',
      duration: data['duration'] ?? 0,
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTrending: data['isTrending'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      isVipOnly: data['isVipOnly'] ?? false,
      isActive: data['isActive'] != false, // Show video unless explicitly set to false
      order: data['order'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      thumbnailUrl: data['thumbnailUrl'] ?? data['customThumbnail'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'videoUrl': videoUrl,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'duration': duration,
      'views': views,
      'likes': likes,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'isTrending': isTrending,
      'isFeatured': isFeatured,
      'isVipOnly': isVipOnly,
      'isActive': isActive,
      'order': order,
      'tags': tags,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
