import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/video_card.dart';
import '../../core/widgets/gradient_text.dart';
import '../player/shorts_feed_screen.dart';
import 'widgets/recent_withdrawals_widget.dart';
import '../../core/utils/helpers.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/video_provider.dart';
import '../../data/providers/coin_provider.dart';
import '../../data/models/video_model.dart';
import '../../data/providers/ad_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await Future.wait([
      videoProvider.loadVideos(),
      videoProvider.loadCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingHeader(),
              _buildDailyBonusBanner(),
              _buildStatsRow(),
              const SizedBox(height: 16),
              Consumer<AdProvider>(
                builder: (context, adProvider, _) {
                  return Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: adProvider.buildBannerAdWidget(),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildFeaturedVideo(),
              const SizedBox(height: 24),
              _buildTrendingNow(),
              const SizedBox(height: 24),
              _buildForYou(),
              const SizedBox(height: 24),
              const RecentWithdrawalsWidget(),
              const SizedBox(height: 24),
              _buildVipPromo(),
              const SizedBox(height: 24),
              _buildMostPopular(),
              const SizedBox(height: 24),
              _buildRecentlyAdded(),
              const SizedBox(height: 80), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }



  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          GradientText(
            'WatchEarn',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;
            return Row(
              children: [
                if (user != null)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Text('🪙', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          Helpers.formatCoins(user.coins),
                          style: GoogleFonts.poppins(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      onPressed: () {},
                    ),
                    if (userProvider.unreadNotifications > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${userProvider.unreadNotifications}',
                            style: const TextStyle(fontSize: 8, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                if (user != null && user.isVip)
                  IconButton(
                    icon: const Icon(Icons.workspace_premium, color: Colors.amber),
                    onPressed: () {},
                  ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGreetingHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Helpers.getGreeting()}, ${user?.name ?? "Guest"}! 👋',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "You've earned ${Helpers.formatCoins(user?.dailyEarned ?? 0)} coins today",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('🪙', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyBonusBanner() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        bool hasClaimed = false;
        if (user != null && user.lastDailyBonusClaim != null) {
          final last = user.lastDailyBonusClaim!;
          final now = DateTime.now();
          if (last.year == now.year && last.month == now.month && last.day == now.day) {
            hasClaimed = true;
          }
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎁 Daily Bonus Available!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Claim your Day ${userProvider.user?.streak ?? 1} streak reward',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: hasClaimed ? null : () async {
                  int amount = await userProvider.claimDailyBonus();
                  if (context.mounted && amount > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Daily Bonus Claimed! +$amount Coins')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.white54,
                  disabledForegroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(hasClaimed ? 'Claimed' : 'Claim Now →', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildStatCard('🪙', Helpers.formatCoins(user?.totalEarned ?? 0), 'Total Coins', Colors.amber),
              _buildStatCard('📺', '${user?.dailyVideosWatched ?? 0}', 'Videos Today', Colors.blue),
              _buildStatCard('🔥', '${user?.streak ?? 0}', 'Day Streak', Colors.orange),
              _buildStatCard('👥', '${user?.totalReferrals ?? 0}', 'Referrals', Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<VideoProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Browse Categories',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.categories.length + 1,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final isSelected = isAll ? provider.selectedCategory == 'all' : provider.selectedCategory == provider.categories[index-1].id;
                  
                  return GestureDetector(
                    onTap: () {
                      provider.filterByCategory(isAll ? 'all' : provider.categories[index-1].id);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Text(isAll ? '🌟' : provider.categories[index-1].icon),
                          const SizedBox(width: 8),
                          Text(
                            isAll ? 'All' : provider.categories[index-1].name,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedVideo() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final mixedShorts = provider.getMixedUnwatchedShorts(userProvider.user?.watchedVideoIds ?? <String>[]);
        if (mixedShorts.isEmpty) return const SizedBox.shrink();
        
        final video = mixedShorts.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mix Shorts Feed',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.shuffle, color: Colors.amber, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              VideoCard(
                video: video,
                type: VideoCardType.featured,
                isVipUnlocked: userProvider.user?.isVip ?? false,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: mixedShorts, initialIndex: 0)));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingNow() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final unwatchedTrending = provider.getUnwatchedVideos(provider.trendingVideos, userProvider.user);
        if (unwatchedTrending.isEmpty) return const SizedBox.shrink();
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔥 Trending Now',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text('See All →', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: unwatchedTrending.length,
                itemBuilder: (context, index) {
                  return VideoCard(
                    video: unwatchedTrending[index],
                    type: VideoCardType.vertical,
                    isVipUnlocked: userProvider.user?.isVip ?? false,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: unwatchedTrending, initialIndex: index)));
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForYou() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final unwatchedFiltered = provider.getUnwatchedVideos(provider.filteredVideos, userProvider.user);
        if (unwatchedFiltered.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '⭐ For You',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: unwatchedFiltered.length > 4 ? 4 : unwatchedFiltered.length,
              itemBuilder: (context, index) {
                return VideoCard(
                  video: unwatchedFiltered[index],
                  type: VideoCardType.grid,
                  isVipUnlocked: userProvider.user?.isVip ?? false,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: unwatchedFiltered, initialIndex: index)));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVipPromo() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.user?.isVip == true) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium, size: 48, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💎 Earn 5x Faster with VIP!',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('Starting from \$9.99/month', style: TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Upgrade Now →', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMostPopular() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final unwatchedAll = provider.getUnwatchedVideos(provider.allVideos, userProvider.user);
        if (unwatchedAll.isEmpty) return const SizedBox.shrink();
        
        final popular = List.from(unwatchedAll)..sort((a, b) => (b as VideoModel).views.compareTo((a as VideoModel).views));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '🏆 Most Popular',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: popular.length > 3 ? 3 : popular.length,
              itemBuilder: (context, index) {
                return VideoCard(
                  video: popular[index],
                  type: VideoCardType.horizontal,
                  isVipUnlocked: userProvider.user?.isVip ?? false,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: popular, initialIndex: index)));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentlyAdded() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final unwatchedAll = provider.getUnwatchedVideos(provider.allVideos, userProvider.user);
        if (unwatchedAll.isEmpty) return const SizedBox.shrink();
        
        final recent = List.from(unwatchedAll)..sort((a, b) => (b as VideoModel).publishedAt.compareTo((a as VideoModel).publishedAt));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '🆕 Just Added',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: recent.length > 4 ? 4 : recent.length,
              itemBuilder: (context, index) {
                return VideoCard(
                  video: recent[index],
                  type: VideoCardType.grid,
                  isVipUnlocked: userProvider.user?.isVip ?? false,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: recent, initialIndex: index)));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
