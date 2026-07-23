import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardModel {
  int rank;
  final String userId;
  final String name;
  final String profilePic;
  final String countryFlag;
  int weeklyCoins;
  int totalCoins;
  final String vipPlan;
  final bool isAi;
  final DateTime? joinDate;

  LeaderboardModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.profilePic,
    this.countryFlag = '🌎',
    required this.weeklyCoins,
    required this.totalCoins,
    required this.vipPlan,
    this.isAi = false,
    this.joinDate,
  });

  String get rankBadge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  String get rankTitle {
    if (rank == 1) return 'Gold Champion';
    if (rank == 2) return 'Silver Champion';
    if (rank == 3) return 'Bronze Champion';
    if (rank <= 10) return 'Elite Player';
    if (rank <= 50) return 'Pro Player';
    return 'Rising Star';
  }

  int get weeklyPrize {
    if (rank == 1) return 10000;
    if (rank == 2) return 5000;
    if (rank == 3) return 2500;
    if (rank <= 10) return 1000;
    if (rank <= 50) return 100;
    return 0;
  }

  Color get rankColor {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return Colors.grey;
  }

  factory LeaderboardModel.fromFirestore(DocumentSnapshot doc, int index, {bool isAiUser = false}) {
    Map data = doc.data() as Map<String, dynamic>;
    return LeaderboardModel(
      rank: index + 1,
      userId: doc.id,
      name: data['name'] ?? 'Unknown User',
      profilePic: data['profilePic'] ?? '',
      countryFlag: data['countryFlag'] ?? (isAiUser ? '🇺🇸' : '🌎'),
      weeklyCoins: data['weeklyCoins'] ?? data['dailyEarned'] ?? 0,
      totalCoins: data['totalCoins'] ?? data['totalEarned'] ?? data['coins'] ?? 0,
      vipPlan: data['vipPlan'] ?? 'free',
      isAi: isAiUser,
      joinDate: (data['joinDate'] as Timestamp?)?.toDate() ?? (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
