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
      if (_user != null && _user!.needsDailyReset) {
        await checkAndResetDaily();
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
    if (_user == null) return;
    try {
      final newCoins = _user!.coins + amount;
      final newTotalEarned = amount > 0 ? _user!.totalEarned + amount : _user!.totalEarned;
      
      // Optimistic update
      _user = _user!.copyWith(
        coins: newCoins,
        totalEarned: newTotalEarned,
      );
      notifyListeners();
      
      await _firestoreService.updateUser(_user!.uid, {
        'coins': newCoins,
        'totalEarned': newTotalEarned,
      });
    } catch (e) {
      debugPrint("Error updating coins: $e");
    }
  }

  Future<void> claimDailyBonus() async {
    if (_user == null) return;
    try {
      final now = DateTime.now();
      if (_user!.lastDailyBonusClaim != null) {
        final last = _user!.lastDailyBonusClaim!;
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          return; // Already claimed today
        }
      }
      
      _user = _user!.copyWith(lastDailyBonusClaim: now);
      await _firestoreService.updateUser(_user!.uid, {
        'lastDailyBonusClaim': FieldValue.serverTimestamp(),
      });
      await updateCoins(100, 'Daily Bonus');
    } catch (e) {
      debugPrint("Error claiming daily bonus: $e");
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

  Future<void> checkAndUpdateStreak() async {
    if (_user == null) return;
    try {
      final now = DateTime.now();
      final lastLogin = _user!.lastLogin;
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
          .inDays;

      int newStreak = _user!.streak;
      if (difference == 1) {
        newStreak++;
      } else if (difference > 1) {
        newStreak = 1;
      }

      if (difference > 0) {
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
      if (type == 'video') field = 'dailyVideosWatched';
      if (type == 'ad') field = 'dailyAdsWatched';
      if (type == 'share') field = 'dailyShares';
      if (type == 'category') field = 'dailyCategoriesWatched';
      
      if (field.isNotEmpty) {
        await _firestoreService.updateUser(_user!.uid, {
          field: FieldValue.increment(1)
        });
      }
    } catch (e) {
      debugPrint("Error updating daily stats: $e");
    }
  }

  Future<void> checkAndResetDaily() async {
    if (_user == null) return;
    try {
      await _firestoreService.updateUser(_user!.uid, {
        'dailyVideosWatched': 0,
        'dailyAdsWatched': 0,
        'dailyShares': 0,
        'dailyCategoriesWatched': 0,
        'dailyEarned': 0,
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
