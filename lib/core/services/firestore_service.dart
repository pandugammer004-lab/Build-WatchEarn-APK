import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/models/video_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/referral_model.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/models/notification_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Stream<UserModel> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) => UserModel.fromFirestore(doc));
  }

  Future<UserModel?> getUserByReferralCode(String code) async {
    final query = await _db.collection('users').where('referralCode', isEqualTo: code).limit(1).get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  // Videos
  Future<List<VideoModel>> getVideos({String? category, bool? trending, int? limit}) async {
    Query query = _db.collection('videos').orderBy('publishedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    var videos = snapshot.docs.map((doc) => VideoModel.fromFirestore(doc)).toList();
    
    // Filter locally to avoid requiring complex composite indexes in Firebase
    videos = videos.where((v) => v.isActive).toList();
    
    if (category != null && category != 'all') {
      videos = videos.where((v) => v.categoryId == category).toList();
    }
    if (trending == true) {
      videos = videos.where((v) => v.isTrending).toList();
    }
    
    return videos;
  }

  Future<void> incrementVideoViews(String videoId) async {
    await _db.collection('videos').doc(videoId).update({
      'views': FieldValue.increment(1)
    });
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  // Transactions
  Future<void> addTransaction(TransactionModel t) async {
    await _db.collection('transactions').doc(t.id).set(t.toFirestore());
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await _db.collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }

  Future<void> createWithdrawal(Map<String, dynamic> data) async {
    await _db.collection('withdrawals').add(data);
  }

  // Referrals
  Future<void> addReferral(ReferralModel r) async {
    await _db.collection('referrals').doc(r.id).set(r.toFirestore());
  }

  Future<List<ReferralModel>> getReferrals(String userId) async {
    final snapshot = await _db.collection('referrals')
        .where('referrerUserId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReferralModel.fromFirestore(doc)).toList();
  }

  // Leaderboard
  Future<List<LeaderboardModel>> getLeaderboard({bool weekly = true}) async {
    String field = weekly ? 'weeklyCoins' : 'totalEarned';
    final snapshot = await _db.collection('users')
        .orderBy(field, descending: true)
        .limit(100)
        .get();
    
    List<LeaderboardModel> leaderboard = [];
    for (int i = 0; i < snapshot.docs.length; i++) {
      leaderboard.add(LeaderboardModel.fromFirestore(snapshot.docs[i], i));
    }
    return leaderboard;
  }

  // Notifications
  Future<void> sendNotificationToAll(String title, String body) async {
    // Usually done via Cloud Functions, placeholder here
    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'type': 'global',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
  }

  Future<void> markNotificationRead(String notifId) async {
    // Requires userId context usually, simplistic placeholder
    // await _db.collection('users').doc(userId).collection('notifications').doc(notifId).update({'isRead': true});
  }
}
