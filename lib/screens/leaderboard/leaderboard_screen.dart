import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _topUsers = [
    {'name': 'AlexKing', 'coins': 84500, 'rank': 1, 'isVip': true},
    {'name': 'SarahM', 'coins': 62300, 'rank': 2, 'isVip': true},
    {'name': 'ProGamer', 'coins': 55100, 'rank': 3, 'isVip': false},
    {'name': 'JaneDoe', 'coins': 42000, 'rank': 4, 'isVip': false},
    {'name': 'Mike99', 'coins': 38500, 'rank': 5, 'isVip': true},
    {'name': 'CoolCat', 'coins': 35000, 'rank': 6, 'isVip': false},
    {'name': 'SuperWatch', 'coins': 31200, 'rank': 7, 'isVip': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🏆 Leaderboard', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardView(isWeekly: true),
          _buildLeaderboardView(isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardView({required bool isWeekly}) {
    return Column(
      children: [
        if (isWeekly)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.amber.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Text('Resets in: 2d 14h 32m', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (isWeekly) const Text('Weekly Prize Pool: 500,000 🪙', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                _buildPodium(),
                const SizedBox(height: 30),
                _buildMyRankCard(),
                const SizedBox(height: 20),
                _buildRankingsList(),
                const SizedBox(height: 40),
                if (isWeekly) _buildPrizesTable(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumSpot(_topUsers[1], 2, 120, const Color(0xFFC0C0C0)), // Silver
        _buildPodiumSpot(_topUsers[0], 1, 160, const Color(0xFFFFD700)), // Gold
        _buildPodiumSpot(_topUsers[2], 3, 100, const Color(0xFFCD7F32)), // Bronze
      ],
    );
  }

  Widget _buildPodiumSpot(Map<String, dynamic> user, int rank, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (rank == 1) const Icon(Icons.workspace_premium, color: Colors.amber, size: 40),
        CircleAvatar(
          radius: rank == 1 ? 40 : 30,
          backgroundColor: color,
          child: CircleAvatar(
            radius: rank == 1 ? 36 : 26,
            backgroundColor: AppColors.cardColor,
            child: Text(user['name'][0], style: TextStyle(color: Colors.white, fontSize: rank == 1 ? 24 : 16)),
          ),
        ),
        const SizedBox(height: 8),
        Text(user['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text('${user['coins']}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border(top: BorderSide(color: color, width: 4)),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(child: Text('#$rank', style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold))),
        ),
      ],
    );
  }

  Widget _buildMyRankCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Center(child: Text('#42', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Need 2,400 more coins to reach #41', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(value: 0.7, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('12,400 🪙', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRankingsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _topUsers.length - 3,
      itemBuilder: (context, index) {
        final user = _topUsers[index + 3];
        return _buildRankingRow(user);
      },
    );
  }

  Widget _buildRankingRow(Map<String, dynamic> user) {
    Color bgColor = Colors.transparent;
    if (user['rank'] <= 10) bgColor = AppColors.primary.withOpacity(0.1);

    return Container(
      color: bgColor,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              child: Text('#${user['rank']}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.white10,
              radius: 20,
              child: Text(user['name'][0], style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(user['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (user['isVip']) const SizedBox(width: 4),
            if (user['isVip']) const Icon(Icons.workspace_premium, color: Colors.amber, size: 14),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${user['coins']} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (user['rank'] % 2 == 0)
              const Icon(Icons.arrow_upward, color: Colors.green, size: 16)
            else
              const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizesTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text('Weekly Prize Pool Structure', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
          iconColor: Colors.amber,
          collapsedIconColor: Colors.amber,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPrizeRow('1st Place', '50,000 coins', Colors.amber),
                  const Divider(color: Colors.white12),
                  _buildPrizeRow('2nd Place', '30,000 coins', const Color(0xFFC0C0C0)),
                  const Divider(color: Colors.white12),
                  _buildPrizeRow('3rd Place', '20,000 coins', const Color(0xFFCD7F32)),
                  const Divider(color: Colors.white12),
                  _buildPrizeRow('4th - 10th Place', '10,000 coins each', Colors.white),
                  const Divider(color: Colors.white12),
                  _buildPrizeRow('11th - 50th Place', '5,000 coins each', Colors.white),
                  const Divider(color: Colors.white12),
                  _buildPrizeRow('51st - 100th Place', '2,000 coins each', Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeRow(String rank, String prize, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rank, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(prize, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
