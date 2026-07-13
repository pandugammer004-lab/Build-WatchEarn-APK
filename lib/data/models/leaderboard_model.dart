import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderboardModel {
  final int rank;
  final String userId;
  final String name;
  final String profilePic;
  final int weeklyCoins;
  final int totalCoins;
  final String vipPlan;

  LeaderboardModel({
    required this.rank,
    required this.userId,
    required this.name,
    required this.profilePic,
    required this.weeklyCoins,
    required this.totalCoins,
    required this.vipPlan,
  });

  String get rankBadge {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  String get rankTitle {
    if (rank == 1) return 'Champion';
    if (rank == 2) return 'Runner Up';
    if (rank == 3) return 'Second Runner Up';
    if (rank <= 10) return 'Top 10';
    if (rank <= 50) return 'Top 50';
    return 'Player';
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

  factory LeaderboardModel.fromFirestore(DocumentSnapshot doc, int index) {
    Map data = doc.data() as Map<String, dynamic>;
    return LeaderboardModel(
      rank: index + 1,
      userId: doc.id,
      name: data['name'] ?? 'Unknown User',
      profilePic: data['profilePic'] ?? '',
      weeklyCoins: data['weeklyCoins'] ?? 0,
      totalCoins: data['totalCoins'] ?? 0,
      vipPlan: data['vipPlan'] ?? 'free',
    );
  }
}
