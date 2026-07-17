import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _user;
  bool _isLoading = false;
  List<TransactionModel> _transactions = [];
  List<NotificationModel> _notifications = [];

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => _transactions;
  List<NotificationModel> get notifications => _notifications;
  
  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadUser(String uid) async {
    try {
      _setLoading(true);
      _user = await _firestoreService.getUser(uid);
      if (_user != null) {
        await checkAndUpdateStreak();
        if (_user!.needsDailyReset) {
          await checkAndResetDaily();
        }
        await loadTransactions();
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      _setLoading(false);
    }
  }

  Stream<UserModel> userStream(String uid) {
    return _firestoreService.streamUser(uid).map((user) {
      _user = user;
      notifyListeners();
      return user;
    });
  }

  Future<void> updateCoins(int amount, String source) async {
    if (_user == null || amount == 0) return;
    try {
      final newCoins = _user!.coins + amount;
      final newTotalEarned = amount > 0 ? _user!.totalEarned + amount : _user!.totalEarned;
      final newDailyEarned = amount > 0 ? _user!.dailyEarned + amount : _user!.dailyEarned;
      
      // Optimistic update
      _user = _user!.copyWith(
        coins: newCoins,
        totalEarned: newTotalEarned,
        dailyEarned: newDailyEarned,
      );
      notifyListeners();
      
      await _firestoreService.updateUser(_user!.uid, {
        'coins': newCoins,
        'totalEarned': newTotalEarned,
        'dailyEarned': newDailyEarned,
      });

      // Add transaction record
      final tx = TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        userId: _user!.uid,
        type: amount > 0 ? 'earning' : 'withdrawal',
        source: source.toLowerCase(),
        coins: amount,
        amount: 0.0,
        status: 'completed',
        paymentMethod: '',
        paymentEmail: '',
        description: source,
        timestamp: DateTime.now(),
      );
      await _firestoreService.addTransaction(tx);
      _transactions.insert(0, tx);
      notifyListeners();
      
    } catch (e) {
      debugPrint("Error updating coins: $e");
    }
  }

  Future<int> claimDailyBonus() async {
    if (_user == null) return 0;
    try {
      final now = DateTime.now();
      if (_user!.lastDailyBonusClaim != null) {
        final last = _user!.lastDailyBonusClaim!;
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          return 0; // Already claimed today
        }
      }
      
      _user = _user!.copyWith(lastDailyBonusClaim: now);
      await _firestoreService.updateUser(_user!.uid, {
        'lastDailyBonusClaim': FieldValue.serverTimestamp(),
      });
      
      final streakCount = _user!.streak.clamp(1, 7);
      final amount = streakCount == 7 ? 1000 : 50 * streakCount;
      await updateCoins(amount, 'Daily Bonus');
      return amount;
    } catch (e) {
      debugPrint("Error claiming daily bonus: $e");
      return 0;
    }
  }

  Future<void> updateSpinState({required bool usedPremium}) async {
    if (_user == null) return;
    try {
      final updates = <String, dynamic>{};
      
      if (usedPremium) {
        final newPremium = (_user!.premiumSpins - 1).clamp(0, 9999);
        updates['premiumSpins'] = newPremium;
        _user = _user!.copyWith(premiumSpins: newPremium);
      } else {
        updates['lastSpinDate'] = FieldValue.serverTimestamp();
        updates['totalSpins'] = FieldValue.increment(1);
        _user = _user!.copyWith(lastSpinDate: DateTime.now(), totalSpins: _user!.totalSpins + 1);
      }
      notifyListeners();
      await _firestoreService.updateUser(_user!.uid, updates);
    } catch (e) {
      debugPrint("Error updating spin state: $e");
    }
  }

  Future<void> claimGoal(String goalId, int reward) async {
    if (_user == null || _user!.claimedGoals.contains(goalId)) return;
    try {
      final newClaimed = List<String>.from(_user!.claimedGoals)..add(goalId);
      _user = _user!.copyWith(claimedGoals: newClaimed);
      notifyListeners();
      
      await _firestoreService.updateUser(_user!.uid, {
        'claimedGoals': newClaimed,
      });
      await updateCoins(reward, 'goal');
    } catch (e) {
      debugPrint("Error claiming goal: $e");
    }
  }

  Future<void> updateScratchState() async {
    if (_user == null) return;
    try {
      _user = _user!.copyWith(
        lastScratchDate: DateTime.now(),
        totalScratchCards: _user!.totalScratchCards + 1,
      );
      notifyListeners();
      await _firestoreService.updateUser(_user!.uid, {
        'lastScratchDate': FieldValue.serverTimestamp(),
        'totalScratchCards': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint("Error updating scratch state: $e");
    }
  }

  Future<void> updateMysteryBoxState() async {
    if (_user == null) return;
    try {
      _user = _user!.copyWith(
        lastMysteryBoxDate: DateTime.now(),
      );
      notifyListeners();
      await _firestoreService.updateUser(_user!.uid, {
        'lastMysteryBoxDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error updating mystery box state: $e");
    }
  }

  Future<void> checkAndUpdateStreak() async {
    if (_user == null) return;
    try {
      final now = DateTime.now();
      final lastLogin = _user!.lastLogin;
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
          .inDays;

      int newStreak = _user!.streak;
      if (newStreak == 0) newStreak = 1; // Base case for new users

      if (difference == 1) {
        newStreak++;
      } else if (difference > 1) {
        newStreak = 1;
      }

      if (difference > 0 || _user!.streak == 0) {
        _user = _user!.copyWith(streak: newStreak, lastLogin: now);
        notifyListeners();
        await _firestoreService.updateUser(_user!.uid, {
          'streak': newStreak,
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error updating streak: $e");
    }
  }

  Future<void> updateProfile(String name, String? profilePic) async {
    if (_user == null) return;
    try {
      _setLoading(true);
      Map<String, dynamic> data = {'name': name};
      if (profilePic != null) data['profilePic'] = profilePic;
      await _firestoreService.updateUser(_user!.uid, data);
    } catch (e) {
      debugPrint("Error updating profile: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(String videoId) async {
    if (_user == null) return;
    try {
      List<String> favorites = List.from(_user!.favorites);
      if (favorites.contains(videoId)) {
        favorites.remove(videoId);
      } else {
        favorites.add(videoId);
      }
      await _firestoreService.updateUser(_user!.uid, {'favorites': favorites});
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
    }
  }

  Future<void> markVideoWatched(String videoId) async {
    if (_user == null) return;
    try {
      List<String> watched = List.from(_user!.watchedVideoIds);
      if (!watched.contains(videoId)) {
        watched.add(videoId);
        await _firestoreService.updateUser(_user!.uid, {'watchedVideoIds': watched});
      }
    } catch (e) {
      debugPrint("Error marking video watched: $e");
    }
  }

  Future<void> subscribeToChannel(String channelId) async {
    if (_user == null) return;
    try {
      List<String> subscribed = List.from(_user!.subscribedChannels);
      if (!subscribed.contains(channelId)) {
        subscribed.add(channelId);
        _user = _user!.copyWith(subscribedChannels: subscribed);
        notifyListeners();
        await _firestoreService.updateUser(_user!.uid, {'subscribedChannels': subscribed});
      }
    } catch (e) {
      debugPrint("Error subscribing to channel: $e");
    }
  }

  Future<void> updateDailyStats(String type) async {
    if (_user == null) return;
    try {
      String field = '';
      int newValue = 0;
      
      if (type == 'video') {
        field = 'dailyVideosWatched';
        newValue = _user!.dailyVideosWatched + 1;
        _user = _user!.copyWith(dailyVideosWatched: newValue, videosWatched: _user!.videosWatched + 1);
      }
      if (type == 'ad') {
        field = 'dailyAdsWatched';
        newValue = _user!.dailyAdsWatched + 1;
        _user = _user!.copyWith(dailyAdsWatched: newValue);
      }
      if (type == 'share') {
        field = 'dailyShares';
        newValue = _user!.dailyShares + 1;
        _user = _user!.copyWith(dailyShares: newValue);
      }
      if (type == 'category') {
        field = 'dailyCategoriesWatched';
        newValue = _user!.dailyCategoriesWatched + 1;
        _user = _user!.copyWith(dailyCategoriesWatched: newValue);
      }
      
      notifyListeners();
      
      if (field.isNotEmpty) {
        await _firestoreService.updateUser(_user!.uid, {
          field: newValue,
          if (type == 'video') 'videosWatched': _user!.videosWatched,
        });
      }
    } catch (e) {
      debugPrint("Error updating daily stats: $e");
    }
  }

  Future<void> checkAndResetDaily() async {
    if (_user == null) return;
    try {
      _user = _user!.copyWith(
        dailyVideosWatched: 0,
        dailyAdsWatched: 0,
        dailyShares: 0,
        dailyCategoriesWatched: 0,
        dailyEarned: 0,
        claimedGoals: const [],
        lastDailyReset: DateTime.now(),
      );
      notifyListeners();
      await _firestoreService.updateUser(_user!.uid, {
        'dailyVideosWatched': 0,
        'dailyAdsWatched': 0,
        'dailyShares': 0,
        'dailyCategoriesWatched': 0,
        'dailyEarned': 0,
        'claimedGoals': const [],
        'lastDailyReset': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error resetting daily stats: $e");
    }
  }

  Future<void> checkBadges() async {
    // Implementation placeholder
  }

  Future<void> loadTransactions() async {
    if (_user == null) return;
    try {
      _transactions = await _firestoreService.getTransactions(_user!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading transactions: $e");
    }
  }

  Future<void> loadNotifications() async {
    if (_user == null) return;
    try {
      _notifications = await _firestoreService.getUserNotifications(_user!.uid);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _firestoreService.markNotificationRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        // Optimistic update locally
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          type: _notifications[index].type,
          icon: _notifications[index].icon,
          isRead: true,
          timestamp: _notifications[index].timestamp,
          data: _notifications[index].data,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking notification read: $e");
    }
  }
}
