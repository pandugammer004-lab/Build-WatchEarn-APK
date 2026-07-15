import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/video_card.dart';
import '../../core/widgets/coin_earned_animation.dart';
import '../../data/models/video_model.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/video_provider.dart';
import '../../data/providers/coin_provider.dart';
import '../../data/providers/ad_provider.dart';
import '../../core/utils/helpers.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasEarnedCoins = false;
  bool _showHalfwayToast = true;
  Timer? _watchTimer;
  int _secondsWatched = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      if (_controller.value.isPlaying) {
        if (_watchTimer == null || !_watchTimer!.isActive) {
          _startTimer();
        }
      } else {
        _stopTimer();
      }
    }
  }

  void _startTimer() {
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      _secondsWatched++;
      _checkEarningMilestones();
    });
  }

  void _stopTimer() {
    _watchTimer?.cancel();
  }

  bool _needsToSubscribe = false;

  void _checkEarningMilestones() async {
    if (_hasEarnedCoins) return;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final double progress = widget.video.duration > 0 ? _secondsWatched / widget.video.duration : 1.0;

    if (_secondsWatched == 60 && _showHalfwayToast) {
      _showHalfwayToast = false;
      Helpers.showSuccessSnackbar(context, "Keep watching to earn coins! 🪙");
    }

    // Earn at 180 seconds or 80% if duration is less than 180
    bool timeReached = _secondsWatched >= 180 || (widget.video.duration < 180 && progress >= 0.8 && _secondsWatched >= 30);

    if (timeReached) {
      if (user.subscribedChannels.contains(widget.video.id)) {
        _hasEarnedCoins = true;
        _stopTimer();
        _awardCoins();
      } else {
        if (!_needsToSubscribe) {
          setState(() {
            _needsToSubscribe = true;
          });
          Helpers.showSuccessSnackbar(context, "Subscribe to claim your coins!");
        }
      }
    }
  }

  Future<void> _awardCoins() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    
    if (userProvider.user == null) return;

    final earned = await coinProvider.earnFromVideo(userProvider.user!);
    
    if (earned > 0 && mounted) {
      CoinEarnedAnimation.show(context, coins: earned, source: 'Video Watched');
      await userProvider.updateCoins(earned, 'Video Watched');
      await userProvider.markVideoWatched(widget.video.id);
      await userProvider.updateDailyStats('video');
      
      // Increment video count for ad logic
      coinProvider.incrementVideoCount();
      adProvider.incrementVideoCount();
      
      if (adProvider.shouldShowInterstitial(userProvider.user!.isVip)) {
        await adProvider.showInterstitialAd();
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Area
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.primary,
                  handleColor: Colors.white,
                ),
                onReady: () {
                  _isPlayerReady = true;
                },
                topActions: [
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _controller.metadata.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    player,
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVideoInfo(),
                            _buildActionButtons(),
                            _buildDailyProgress(),
                            _buildRelatedVideos(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.video.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Text(
                  widget.video.categoryName,
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.video.views} views',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Text(
                '•',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Text(
                Helpers.formatTimeAgo(widget.video.publishedAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final isSubscribed = userProvider.user?.subscribedChannels.contains(widget.video.id) ?? false;
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubscribed ? null : () async {
                        if (userProvider.user != null) {
                          // Redirect to YouTube
                          final url = Uri.parse('https://www.youtube.com/watch?v=${widget.video.youtubeId}');
                          try {
                            // ignore: avoid_dynamic_calls
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint("Could not launch $url: $e");
                          }

                          await userProvider.subscribeToChannel(widget.video.id);
                          if (mounted) {
                            Helpers.showSuccessSnackbar(context, "Subscribed successfully!");
                            // If timer was reached and we were waiting for subscription
                            if (_needsToSubscribe) {
                              setState(() {
                                _needsToSubscribe = false;
                              });
                              _checkEarningMilestones();
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSubscribed ? Colors.grey.withOpacity(0.3) : (_needsToSubscribe ? Colors.redAccent : AppColors.primary),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: _needsToSubscribe ? 8 : 0,
                      ),
                      child: Text(
                        isSubscribed ? 'Subscribed ✓' : 'Subscribe to Earn Coins',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isFavorite = userProvider.user?.favorites.contains(widget.video.id) ?? false;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                label: 'Like',
                onTap: () {},
              ),
              _buildActionButton(
                icon: isFavorite ? Icons.favorite : Icons.favorite_outline,
                label: 'Save',
                color: isFavorite ? Colors.red : Colors.white,
                onTap: () {
                  userProvider.toggleFavorite(widget.video.id);
                },
              ),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {
                  Helpers.shareText('Watch this awesome video on WatchEarn! https://watchearn.app/v/${widget.video.id}');
                },
              ),
              _buildWatchAdButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.white}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchAdButton() {
    return Consumer2<AdProvider, UserProvider>(
      builder: (context, adProvider, userProvider, _) {
        final isAdReady = adProvider.isRewardedLoaded;
        
        return InkWell(
          onTap: isAdReady ? () async {
            _controller.pause();
            final reward = await adProvider.showRewardedAd();
            if (reward > 0 && mounted && userProvider.user != null) {
              final coinProvider = Provider.of<CoinProvider>(context, listen: false);
              final earned = await coinProvider.earnFromAd(userProvider.user!);
              await userProvider.updateCoins(earned, 'Ad Watched');
              await userProvider.updateDailyStats('ad');
              if (mounted) CoinEarnedAnimation.show(context, coins: earned, source: 'Ad Watched');
            }
          } : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isAdReady ? Colors.amber.withOpacity(0.2) : Colors.white10,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isAdReady ? Colors.amber : Colors.transparent),
            ),
            child: Column(
              children: [
                Icon(Icons.ondemand_video, color: isAdReady ? Colors.amber : Colors.white38, size: 24),
                const SizedBox(height: 4),
                Text(
                  '+15 🪙 Ad',
                  style: TextStyle(color: isAdReady ? Colors.amber : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyProgress() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        if (user == null) return const SizedBox.shrink();
        
        final maxCoins = 1000;
        final currentCoins = user.dailyVideosWatched * 10;
        final progress = (currentCoins / maxCoins).clamp(0.0, 1.0);
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Video Limit',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$currentCoins / $maxCoins 🪙',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                borderRadius: BorderRadius.circular(4),
              ),
              if (user.isVip)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '💎 VIP Users have unlimited earning',
                    style: TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRelatedVideos() {
    return Consumer2<VideoProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        final related = provider.getRelatedVideos(widget.video);
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Related Videos',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: related.length,
              itemBuilder: (context, index) {
                return VideoCard(
                  video: related[index],
                  type: VideoCardType.horizontal,
                  isVipUnlocked: userProvider.user?.isVip ?? false,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: related[index])),
                    );
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
