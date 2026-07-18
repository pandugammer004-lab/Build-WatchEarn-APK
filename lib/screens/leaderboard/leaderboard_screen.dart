import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/demo_data_service.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/providers/user_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
                Text('Real-time Leaderboard', style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _fetchLeaderboard(isWeekly),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No ranking data available yet.', style: TextStyle(color: Colors.white70)));
              }
              
              final topUsers = snapshot.data as List<dynamic>;
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (isWeekly) const Text('Weekly Prize Pool: 500,000 🪙', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    _buildPodium(topUsers),
                    const SizedBox(height: 30),
                    _buildMyRankCard(topUsers),
                    const SizedBox(height: 20),
                    _buildRankingsList(topUsers),
                    const SizedBox(height: 40),
                    if (isWeekly) _buildPrizesTable(),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> _fetchLeaderboard(bool isWeekly) async {
    final firestoreService = FirestoreService();
    
    // Fetch Real Users
    final realUsers = await firestoreService.getLeaderboard(weekly: isWeekly);
    
    // Fetch Base AI Users
    final baseAiUsers = await firestoreService.getBaseAiUsers();
    
    // If no AI users exist in DB, fallback to generating some locally to ensure it's never empty
    List<LeaderboardModel> aiUsers = baseAiUsers;
    if (aiUsers.isEmpty) {
      final rawBaseAi = DemoDataService.generateBaseAiUsersForDatabase(100);
      aiUsers = rawBaseAi.asMap().entries.map((entry) {
        return LeaderboardModel(
          rank: entry.key + 1,
          userId: 'ai_${entry.key}',
          name: entry.value['name'],
          profilePic: entry.value['profilePic'],
          countryFlag: entry.value['countryFlag'],
          weeklyCoins: entry.value['weeklyCoins'],
          totalCoins: entry.value['totalCoins'],
          vipPlan: entry.value['vipPlan'],
          isAi: true,
          joinDate: DateTime.now().subtract(Duration(days: 7)),
        );
      }).toList();
    }
    
    // Simulate dynamic growth
    final simulatedAiUsers = DemoDataService.simulateAiCoinGrowth(aiUsers);
    
    // Combine and Sort
    final allUsers = [...realUsers, ...simulatedAiUsers];
    
    if (isWeekly) {
      allUsers.sort((a, b) => b.weeklyCoins.compareTo(a.weeklyCoins));
    } else {
      allUsers.sort((a, b) => b.totalCoins.compareTo(a.totalCoins));
    }
    
    // Assign Ranks
    for (int i = 0; i < allUsers.length; i++) {
      allUsers[i].rank = i + 1;
    }
    
    return allUsers.map((model) => {
      'name': model.name,
      'coins': isWeekly ? model.weeklyCoins : model.totalCoins,
      'rank': model.rank,
      'isVip': model.vipPlan != 'free',
      'userId': model.userId,
      'countryFlag': model.countryFlag,
      'isAi': model.isAi,
      'rankTitle': model.rankTitle,
    }).toList();
  }

  Widget _buildPodium(List<dynamic> topUsers) {
    if (topUsers.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (topUsers.length > 1) _buildPodiumSpot(topUsers[1], 2, 120, const Color(0xFFC0C0C0)), // Silver
        if (topUsers.isNotEmpty) _buildPodiumSpot(topUsers[0], 1, 160, const Color(0xFFFFD700)), // Gold
        if (topUsers.length > 2) _buildPodiumSpot(topUsers[2], 3, 100, const Color(0xFFCD7F32)), // Bronze
      ],
    );
  }

  Widget _buildPodiumSpot(dynamic user, int rank, double height, Color color) {
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
        Text('${user['countryFlag']} ${user['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
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

  Widget _buildMyRankCard(List<dynamic> topUsers) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final currentUser = userProvider.user;
        if (currentUser == null) return const SizedBox.shrink();
        
        int myRank = -1;
        for (var i = 0; i < topUsers.length; i++) {
          if (topUsers[i]['userId'] == currentUser.uid) {
            myRank = topUsers[i]['rank'];
            break;
          }
        }
        
        String rankText = myRank != -1 ? '#$myRank' : 'Unranked';

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
                child: Center(child: Text(rankText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(myRank != -1 ? 'Keep earning to rank up!' : 'Earn coins to get on the board!', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text('${currentUser.coins} 🪙', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingsList(List<dynamic> topUsers) {
    if (topUsers.length <= 3) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topUsers.length - 3,
      itemBuilder: (context, index) {
        final user = topUsers[index + 3];
        return _buildRankingRow(user);
      },
    );
  }

  Widget _buildRankingRow(dynamic user) {
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
              backgroundColor: Colors.white12,
              child: Text(user['name'][0], style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('${user['countryFlag']} ${user['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                if (user['isVip']) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.workspace_premium, color: Colors.amber, size: 14)),
              ],
            ),
            Text(user['rankTitle'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
