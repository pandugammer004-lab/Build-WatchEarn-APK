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

  Future<List<LeaderboardModel>> getBaseAiUsers() async {
    try {
      final snapshot = await _db.collection('ai_users').limit(150).get();
      List<LeaderboardModel> aiUsers = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        aiUsers.add(LeaderboardModel.fromFirestore(snapshot.docs[i], i, isAiUser: true));
      }
      return aiUsers;
    } catch (e) {
      return [];
    }
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

  // Transactions for Secure Rewards
  Future<Map<String, dynamic>> claimDailyBonusTransaction(String uid, List<int> streakRewards) async {
    return await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final data = snapshot.data()!;
      final DateTime now = DateTime.now();
      DateTime? lastClaim;
      if (data['lastDailyBonusClaim'] != null) {
        lastClaim = (data['lastDailyBonusClaim'] as Timestamp).toDate();
      }

      int streak = data['streak'] ?? 0;
      
      if (lastClaim != null) {
        final difference = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastClaim.year, lastClaim.month, lastClaim.day))
            .inDays;
        
        if (difference == 0) {
          throw Exception("Already claimed today");
        } else if (difference == 1) {
          streak += 1;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }

      if (streak > 7) streak = 1;

      final reward = streakRewards[streak - 1];

      transaction.update(userRef, {
        'coins': FieldValue.increment(reward),
        'totalEarned': FieldValue.increment(reward),
        'streak': streak,
        'lastDailyBonusClaim': FieldValue.serverTimestamp(),
      });

      final transactionRef = _db.collection('transactions').doc();
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': uid,
        'amount': reward,
        'type': 'credit',
        'source': 'streak',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {'reward': reward, 'streak': streak};
    });
  }

  Future<Map<String, dynamic>> claimAdRewardTransaction(String uid, int rewardAmount) async {
    return await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      transaction.update(userRef, {
        'coins': FieldValue.increment(rewardAmount),
        'totalEarned': FieldValue.increment(rewardAmount),
        'dailyAdsWatched': FieldValue.increment(1),
        'dailyEarned': FieldValue.increment(rewardAmount),
      });

      final transactionRef = _db.collection('transactions').doc();
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': uid,
        'amount': rewardAmount,
        'type': 'credit',
        'source': 'ad',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {'reward': rewardAmount};
    });
  }

  Future<Map<String, dynamic>> claimSpinPrizeTransaction(String uid, int prize, bool isPremium) async {
    return await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final data = snapshot.data()!;
      int premiumSpins = data['premiumSpins'] ?? 0;

      Map<String, dynamic> updates = {
        'coins': FieldValue.increment(prize),
        'totalEarned': FieldValue.increment(prize),
        'totalSpins': FieldValue.increment(1),
        'lastSpinDate': FieldValue.serverTimestamp(),
      };

      if (isPremium) {
        if (premiumSpins <= 0) throw Exception("No premium spins available");
        updates['premiumSpins'] = FieldValue.increment(-1);
      }

      transaction.update(userRef, updates);

      final transactionRef = _db.collection('transactions').doc();
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': uid,
        'amount': prize,
        'type': 'credit',
        'source': 'spin',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {'reward': prize};
    });
  }

  Future<Map<String, dynamic>> claimScratchCardPrizeTransaction(String uid, int prize) async {
    return await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final data = snapshot.data()!;
      if (data['lastScratchDate'] != null) {
        final lastScratch = (data['lastScratchDate'] as Timestamp).toDate();
        if (DateTime.now().difference(lastScratch).inHours < 12) {
          throw Exception("Wait for the timer to expire");
        }
      }

      transaction.update(userRef, {
        'coins': FieldValue.increment(prize),
        'totalEarned': FieldValue.increment(prize),
        'totalScratchCards': FieldValue.increment(1),
        'lastScratchDate': FieldValue.serverTimestamp(),
      });

      final transactionRef = _db.collection('transactions').doc();
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': uid,
        'amount': prize,
        'type': 'credit',
        'source': 'scratch_card',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {'reward': prize};
    });
  }

  Future<Map<String, dynamic>> claimMysteryBoxPrizeTransaction(String uid, int prize) async {
    return await _db.runTransaction((transaction) async {
      final userRef = _db.collection('users').doc(uid);
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception("User not found");

      final data = snapshot.data()!;
      if (data['lastMysteryBoxDate'] != null) {
        final lastBox = (data['lastMysteryBoxDate'] as Timestamp).toDate();
        if (DateTime.now().difference(lastBox).inHours < 12) {
          throw Exception("Wait for the timer to expire");
        }
      }

      transaction.update(userRef, {
        'coins': FieldValue.increment(prize),
        'totalEarned': FieldValue.increment(prize),
        'lastMysteryBoxDate': FieldValue.serverTimestamp(),
      });

      final transactionRef = _db.collection('transactions').doc();
      transaction.set(transactionRef, {
        'id': transactionRef.id,
        'userId': uid,
        'amount': prize,
        'type': 'credit',
        'source': 'mystery_box',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return {'reward': prize};
    });
  }
}
