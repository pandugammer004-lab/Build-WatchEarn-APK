import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String youtubeId;
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
  final String? customThumbnail;

  VideoModel({
    required this.id,
    required this.youtubeId,
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
    this.customThumbnail,
  });

  String get thumbnailHQ => customThumbnail != null && customThumbnail!.isNotEmpty ? customThumbnail! : 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
  String get thumbnailMQ => customThumbnail != null && customThumbnail!.isNotEmpty ? customThumbnail! : 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';
  String get thumbnailSQ => customThumbnail != null && customThumbnail!.isNotEmpty ? customThumbnail! : 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
  
  bool get isDirectLink => youtubeId.startsWith('http://') || youtubeId.startsWith('https://');
  
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
      youtubeId: data['youtubeId'] ?? '',
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
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      customThumbnail: data['customThumbnail'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'youtubeId': youtubeId,
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
      'customThumbnail': customThumbnail,
    };
  }
}
