import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_config.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final int coins;
  final int totalEarned;
  final double totalWithdrawn;
  final String vipPlan; // free/silver/gold/platinum/diamond/lifetime
  final DateTime? vipExpiry;
  final String referralCode;
  final String referredBy;
  final int totalReferrals;
  final int referralEarnings;
  final int streak;
  final DateTime lastLogin;
  final int videosWatched;
  final int totalWatchTimeSeconds;
  final DateTime joinDate;
  final List<String> badges;
  final List<String> favorites;
  final List<String> watchedVideoIds;
  final bool notificationsEnabled;
  final bool autoplayEnabled;
  final String videoQuality;
  final int dailyVideosWatched;
  final int dailyAdsWatched;
  final int dailyShares;
  final int dailyCategoriesWatched;
  final DateTime lastDailyReset;
  final int totalSpins;
  final int totalScratchCards;
  final String fcmToken;
  final DateTime? lastSpinDate;
  final DateTime? lastScratchDate;
  final DateTime? lastMysteryBoxDate;
  final int premiumSpins;
  final int dailyEarned;
  final List<String> claimedGoals;
  final DateTime? lastDailyBonusClaim;
  final bool isBlocked;
  final List<String> subscribedChannels;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.coins,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.vipPlan,
    this.vipExpiry,
    required this.referralCode,
    required this.referredBy,
    required this.totalReferrals,
    this.referralEarnings = 0,
    required this.streak,
    required this.lastLogin,
    required this.videosWatched,
    required this.totalWatchTimeSeconds,
    required this.joinDate,
    required this.badges,
    required this.favorites,
    required this.watchedVideoIds,
    required this.notificationsEnabled,
    required this.autoplayEnabled,
    required this.videoQuality,
    required this.dailyVideosWatched,
    required this.dailyAdsWatched,
    required this.dailyShares,
    required this.dailyCategoriesWatched,
    required this.lastDailyReset,
    required this.totalSpins,
    required this.totalScratchCards,
    required this.fcmToken,
    this.lastSpinDate,
    this.lastScratchDate,
    this.lastMysteryBoxDate,
    this.premiumSpins = 0,
    this.dailyEarned = 0,
    this.claimedGoals = const [],
    this.lastDailyBonusClaim,
    this.isBlocked = false,
    this.subscribedChannels = const [],
  });

  bool get isVip => vipPlan != 'free' && (vipExpiry == null || vipExpiry!.isAfter(DateTime.now()));
  
  int get coinMultiplier => AppConfig.vipMultipliers[vipPlan] ?? 1;
  
  String get formattedCoins => coins.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  
  double get cashValue => coins / AppConfig.coinsPerDollar;
  
  String get formattedCashValue => '\$${cashValue.toStringAsFixed(2)}';
  
  String get formattedWatchTime {
    int hours = totalWatchTimeSeconds ~/ 3600;
    int minutes = (totalWatchTimeSeconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
  
  String get memberSince => '${joinDate.month}/${joinDate.year}';
  
  String get vipBadgeIcon {
    switch (vipPlan) {
      case 'silver': return '🥈';
      case 'gold': return '🥇';
      case 'platinum': return '🌟';
      case 'diamond': return '💎';
      case 'lifetime': return '👑';
      default: return '';
    }
  }
  
  String get vipDisplayName {
    if (vipPlan == 'free') return 'Free Member';
    return '${vipPlan[0].toUpperCase()}${vipPlan.substring(1)} VIP';
  }
  
  bool get canWithdraw => cashValue >= minWithdrawal;
  
  double get minWithdrawal => isVip ? AppConfig.vipMinWithdrawal : AppConfig.minWithdrawal;
  
  bool get needsDailyReset {
    final now = DateTime.now();
    return lastDailyReset.day != now.day || lastDailyReset.month != now.month || lastDailyReset.year != now.year;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePic: data['profilePic'] ?? '',
      coins: data['coins'] ?? 0,
      totalEarned: data['totalEarned'] ?? 0,
      totalWithdrawn: (data['totalWithdrawn'] ?? 0.0).toDouble(),
      vipPlan: data['vipPlan'] ?? 'free',
      vipExpiry: data['vipExpiry'] != null ? (data['vipExpiry'] as Timestamp).toDate() : null,
      referralCode: data['referralCode'] ?? '',
      referredBy: data['referredBy'] ?? '',
      totalReferrals: data['totalReferrals'] ?? 0,
      referralEarnings: data['referralEarnings'] ?? 0,
      streak: data['streak'] ?? 0,
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      videosWatched: data['videosWatched'] ?? 0,
      totalWatchTimeSeconds: data['totalWatchTimeSeconds'] ?? 0,
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      badges: List<String>.from(data['badges'] ?? []),
      favorites: List<String>.from(data['favorites'] ?? []),
      watchedVideoIds: List<String>.from(data['watchedVideoIds'] ?? []),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      autoplayEnabled: data['autoplayEnabled'] ?? true,
      videoQuality: data['videoQuality'] ?? 'auto',
      dailyVideosWatched: data['dailyVideosWatched'] ?? 0,
      dailyAdsWatched: data['dailyAdsWatched'] ?? 0,
      dailyShares: data['dailyShares'] ?? 0,
      dailyCategoriesWatched: data['dailyCategoriesWatched'] ?? 0,
      lastDailyReset: (data['lastDailyReset'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalSpins: data['totalSpins'] ?? 0,
      totalScratchCards: data['totalScratchCards'] ?? 0,
      fcmToken: data['fcmToken'] ?? '',
      lastSpinDate: data['lastSpinDate'] != null ? (data['lastSpinDate'] as Timestamp).toDate() : null,
      lastScratchDate: data['lastScratchDate'] != null ? (data['lastScratchDate'] as Timestamp).toDate() : null,
      lastMysteryBoxDate: data['lastMysteryBoxDate'] != null ? (data['lastMysteryBoxDate'] as Timestamp).toDate() : null,
      premiumSpins: data['premiumSpins'] ?? 0,
      dailyEarned: data['dailyEarned'] ?? 0,
      claimedGoals: List<String>.from(data['claimedGoals'] ?? []),
      lastDailyBonusClaim: data['lastDailyBonusClaim'] != null ? (data['lastDailyBonusClaim'] as Timestamp).toDate() : null,
      isBlocked: data['isBlocked'] ?? false,
      subscribedChannels: List<String>.from(data['subscribedChannels'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'coins': coins,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'vipPlan': vipPlan,
      'vipExpiry': vipExpiry != null ? Timestamp.fromDate(vipExpiry!) : null,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'totalReferrals': totalReferrals,
      'referralEarnings': referralEarnings,
      'streak': streak,
      'lastLogin': Timestamp.fromDate(lastLogin),
      'videosWatched': videosWatched,
      'totalWatchTimeSeconds': totalWatchTimeSeconds,
      'joinDate': Timestamp.fromDate(joinDate),
      'badges': badges,
      'favorites': favorites,
      'watchedVideoIds': watchedVideoIds,
      'notificationsEnabled': notificationsEnabled,
      'autoplayEnabled': autoplayEnabled,
      'videoQuality': videoQuality,
      'dailyVideosWatched': dailyVideosWatched,
      'dailyAdsWatched': dailyAdsWatched,
      'dailyShares': dailyShares,
      'dailyCategoriesWatched': dailyCategoriesWatched,
      'lastDailyReset': Timestamp.fromDate(lastDailyReset),
      'totalSpins': totalSpins,
      'totalScratchCards': totalScratchCards,
      'fcmToken': fcmToken,
      'lastSpinDate': lastSpinDate != null ? Timestamp.fromDate(lastSpinDate!) : null,
      'lastScratchDate': lastScratchDate != null ? Timestamp.fromDate(lastScratchDate!) : null,
      'lastMysteryBoxDate': lastMysteryBoxDate != null ? Timestamp.fromDate(lastMysteryBoxDate!) : null,
      'premiumSpins': premiumSpins,
      'dailyEarned': dailyEarned,
      'claimedGoals': claimedGoals,
      'lastDailyBonusClaim': lastDailyBonusClaim != null ? Timestamp.fromDate(lastDailyBonusClaim!) : null,
      'isBlocked': isBlocked,
      'subscribedChannels': subscribedChannels,
    };
  }

  UserModel copyWith({
    String? name,
    String? profilePic,
    int? coins,
    int? totalEarned,
    double? totalWithdrawn,
    String? vipPlan,
    DateTime? vipExpiry,
    int? totalReferrals,
    int? referralEarnings,
    int? streak,
    DateTime? lastLogin,
    int? videosWatched,
    int? totalWatchTimeSeconds,
    List<String>? badges,
    List<String>? favorites,
    List<String>? watchedVideoIds,
    bool? notificationsEnabled,
    bool? autoplayEnabled,
    String? videoQuality,
    int? dailyVideosWatched,
    int? dailyAdsWatched,
    int? dailyShares,
    int? dailyCategoriesWatched,
    DateTime? lastDailyReset,
    int? totalSpins,
    int? totalScratchCards,
    String? fcmToken,
    DateTime? lastSpinDate,
    DateTime? lastScratchDate,
    DateTime? lastMysteryBoxDate,
    int? premiumSpins,
    int? dailyEarned,
    List<String>? claimedGoals,
    DateTime? lastDailyBonusClaim,
    bool? isBlocked,
    List<String>? subscribedChannels,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      profilePic: profilePic ?? this.profilePic,
      coins: coins ?? this.coins,
      totalEarned: totalEarned ?? this.totalEarned,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      vipPlan: vipPlan ?? this.vipPlan,
      vipExpiry: vipExpiry ?? this.vipExpiry,
      referralCode: referralCode,
      referredBy: referredBy,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      streak: streak ?? this.streak,
      lastLogin: lastLogin ?? this.lastLogin,
      videosWatched: videosWatched ?? this.videosWatched,
      totalWatchTimeSeconds: totalWatchTimeSeconds ?? this.totalWatchTimeSeconds,
      joinDate: joinDate,
      badges: badges ?? this.badges,
      favorites: favorites ?? this.favorites,
      watchedVideoIds: watchedVideoIds ?? this.watchedVideoIds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoplayEnabled: autoplayEnabled ?? this.autoplayEnabled,
      videoQuality: videoQuality ?? this.videoQuality,
      dailyVideosWatched: dailyVideosWatched ?? this.dailyVideosWatched,
      dailyAdsWatched: dailyAdsWatched ?? this.dailyAdsWatched,
      dailyShares: dailyShares ?? this.dailyShares,
      dailyCategoriesWatched: dailyCategoriesWatched ?? this.dailyCategoriesWatched,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
      totalSpins: totalSpins ?? this.totalSpins,
      totalScratchCards: totalScratchCards ?? this.totalScratchCards,
      fcmToken: fcmToken ?? this.fcmToken,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      lastScratchDate: lastScratchDate ?? this.lastScratchDate,
      lastMysteryBoxDate: lastMysteryBoxDate ?? this.lastMysteryBoxDate,
      premiumSpins: premiumSpins ?? this.premiumSpins,
      dailyEarned: dailyEarned ?? this.dailyEarned,
      claimedGoals: claimedGoals ?? this.claimedGoals,
      lastDailyBonusClaim: lastDailyBonusClaim ?? this.lastDailyBonusClaim,
      isBlocked: isBlocked ?? this.isBlocked,
      subscribedChannels: subscribedChannels ?? this.subscribedChannels,
    );
  }
}
