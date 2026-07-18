import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/leaderboard_model.dart';

class DemoDataService {
  static final List<String> _names = [
    'Michael', 'Emma', 'Lucas', 'Sophia', 'James', 'Olivia', 'William', 'Isabella',
    'Benjamin', 'Mia', 'Elijah', 'Charlotte', 'Oliver', 'Amelia', 'Jacob', 'Harper',
    'Alexander', 'Evelyn', 'Ethan', 'Abigail', 'Daniel', 'Emily', 'Matthew', 'Elizabeth',
    'Joseph', 'Mila', 'Samuel', 'Ella', 'David', 'Avery'
  ];

  static final List<Map<String, String>> _countries = [
    {'name': 'United States', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'Canada', 'flag': '🇨🇦'},
    {'name': 'Germany', 'flag': '🇩🇪'},
    {'name': 'France', 'flag': '🇫🇷'},
    {'name': 'Italy', 'flag': '🇮🇹'},
    {'name': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Australia', 'flag': '🇦🇺'},
  ];

  static final List<Map<String, dynamic>> _methods = [
    {'name': 'PayPal', 'icon': 'assets/images/paypal.png', 'color': 0xFF003087},
    {'name': 'USDT', 'icon': 'assets/images/usdt.png', 'color': 0xFF26A17B},
    {'name': 'Bitcoin', 'icon': 'assets/images/bitcoin.png', 'color': 0xFFF7931A},
    {'name': 'Amazon', 'icon': 'assets/images/amazon.png', 'color': 0xFFFF9900},
  ];

  static final List<int> _amounts = [5, 10, 15, 20, 25, 30, 40, 50];

  /// Generates a list of fake recent withdrawals
  static List<Map<String, dynamic>> getDemoWithdrawals(int count) {
    final random = Random(DateTime.now().hour); // Semi-stable daily seed for consistency, or just truly random
    final List<Map<String, dynamic>> withdrawals = [];

    for (int i = 0; i < count; i++) {
      final name = _names[random.nextInt(_names.length)];
      final country = _countries[random.nextInt(_countries.length)];
      final method = _methods[random.nextInt(_methods.length)];
      final amount = _amounts[random.nextInt(_amounts.length)];
      final timeMinutesAgo = random.nextInt(59) + 1;

      withdrawals.add({
        'id': 'demo_${i}',
        'name': name,
        'countryFlag': country['flag'],
        'countryName': country['name'],
        'amount': amount,
        'method': method['name'],
        'methodIcon': method['icon'],
        'methodColor': method['color'],
        'time': '$timeMinutesAgo min ago',
        'timestamp': DateTime.now().subtract(Duration(minutes: timeMinutesAgo)),
      });
    }

    // Sort by timestamp descending
    withdrawals.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    return withdrawals;
  }

  /// Calculates real-time simulated AI coin growth based on elapsed time
  static List<LeaderboardModel> simulateAiCoinGrowth(List<LeaderboardModel> baseAiUsers) {
    // We use the current hour and day as a seed to ensure the AI grows deterministically
    // This makes it look like they are constantly earning without us writing to Firestore.
    final now = DateTime.now();
    
    return baseAiUsers.map((user) {
      // Calculate hours since their "join date"
      final hoursElapsed = now.difference(user.joinDate ?? now.subtract(const Duration(days: 7))).inHours;
      
      // Each AI user has a slightly different earning rate based on their ID hash
      final userSeed = user.userId.hashCode;
      final random = Random(userSeed);
      
      // Hourly earning rate between 100 and 500 coins
      final hourlyEarningRate = random.nextInt(400) + 100; 
      
      // Weekly reset logic: only count hours since the start of the current week (Monday)
      final daysSinceMonday = now.weekday - 1;
      final hoursSinceMonday = (daysSinceMonday * 24) + now.hour;
      
      final simulatedWeeklyCoins = user.weeklyCoins + (hoursSinceMonday * hourlyEarningRate);
      final simulatedTotalCoins = user.totalCoins + (hoursElapsed * hourlyEarningRate);
      
      // Add a slight randomization for the current minute so ranks shuffle slightly within the hour
      final minuteBonus = (now.minute * (random.nextInt(10) + 1));
      
      return LeaderboardModel(
        rank: user.rank,
        userId: user.userId,
        name: user.name,
        profilePic: user.profilePic,
        countryFlag: user.countryFlag,
        weeklyCoins: simulatedWeeklyCoins + minuteBonus,
        totalCoins: simulatedTotalCoins + (minuteBonus * 5),
        vipPlan: user.vipPlan,
        isAi: true,
        joinDate: user.joinDate,
      );
    }).toList();
  }

  /// Creates raw base AI users to be pushed to Firestore ONCE
  static List<Map<String, dynamic>> generateBaseAiUsersForDatabase(int count) {
    final random = Random();
    final List<Map<String, dynamic>> users = [];
    
    for (int i = 0; i < count; i++) {
      final name = _names[random.nextInt(_names.length)];
      final country = _countries[random.nextInt(_countries.length)];
      
      users.add({
        'name': '$name ${random.nextInt(99)}',
        'profilePic': 'https://i.pravatar.cc/150?u=ai_$i',
        'countryFlag': country['flag'],
        'weeklyCoins': random.nextInt(5000),
        'totalCoins': random.nextInt(50000) + 5000,
        'vipPlan': random.nextBool() ? 'vip' : 'free',
        'joinDate': FieldValue.serverTimestamp(),
      });
    }
    
    return users;
  }
}
