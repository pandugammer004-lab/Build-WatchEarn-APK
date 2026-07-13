import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralModel {
  final String id;
  final String referrerUserId;
  final String referredUserId;
  final String referredName;
  final String referredProfilePic;
  final String referredEmail;
  final int coinsEarned;
  final int referredVideosWatched;
  final bool hasPurchasedVip;
  final String status; // active/inactive
  final DateTime timestamp;
  final DateTime? lastActivityAt;

  ReferralModel({
    required this.id,
    required this.referrerUserId,
    required this.referredUserId,
    required this.referredName,
    required this.referredProfilePic,
    required this.referredEmail,
    required this.coinsEarned,
    required this.referredVideosWatched,
    required this.hasPurchasedVip,
    required this.status,
    required this.timestamp,
    this.lastActivityAt,
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

  String get statusBadge {
    switch (status) {
      case 'active': return '🟢 Active';
      case 'inactive': return '🔴 Inactive';
      default: return '⚪ Unknown';
    }
  }

  factory ReferralModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ReferralModel(
      id: doc.id,
      referrerUserId: data['referrerUserId'] ?? '',
      referredUserId: data['referredUserId'] ?? '',
      referredName: data['referredName'] ?? '',
      referredProfilePic: data['referredProfilePic'] ?? '',
      referredEmail: data['referredEmail'] ?? '',
      coinsEarned: data['coinsEarned'] ?? 0,
      referredVideosWatched: data['referredVideosWatched'] ?? 0,
      hasPurchasedVip: data['hasPurchasedVip'] ?? false,
      status: data['status'] ?? 'active',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: data['lastActivityAt'] != null ? (data['lastActivityAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrerUserId': referrerUserId,
      'referredUserId': referredUserId,
      'referredName': referredName,
      'referredProfilePic': referredProfilePic,
      'referredEmail': referredEmail,
      'coinsEarned': coinsEarned,
      'referredVideosWatched': referredVideosWatched,
      'hasPurchasedVip': hasPurchasedVip,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
    };
  }
}
