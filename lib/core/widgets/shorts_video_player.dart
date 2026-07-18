import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/video_model.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/video_provider.dart';
import '../../core/constants/app_colors.dart';
import 'coin_earned_animation.dart';

class ShortsVideoPlayer extends StatefulWidget {
  final VideoModel video;
  final bool isPlaying;

  const ShortsVideoPlayer({Key? key, required this.video, required this.isPlaying}) : super(key: key);

  @override
  State<ShortsVideoPlayer> createState() => _ShortsVideoPlayerState();
}

class _ShortsVideoPlayerState extends State<ShortsVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = false;
  
  // Reward Tracking
  Timer? _watchTimer;
  int _secondsWatched = 0;
  bool _hasEarnedCoins = false;
  bool _showHalfwayToast = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // If URL is empty, avoid crashing
    if (widget.video.videoUrl.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        if (widget.isPlaying) {
          _controller!.play();
          _startWatchTimer();
        }
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  @override
  void didUpdateWidget(covariant ShortsVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller?.play();
        _startWatchTimer();
      } else {
        _controller?.pause();
        _pauseWatchTimer();
      }
    }
  }

  @override
  void dispose() {
    _watchTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startWatchTimer() {
    _watchTimer?.cancel();
    // Only track if not earned yet
    if (_hasEarnedCoins) return;

    _watchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller != null && _controller!.value.isPlaying) {
        _secondsWatched++;
        _checkRewardProgress();
      }
    });
  }

  void _pauseWatchTimer() {
    _watchTimer?.cancel();
  }

  void _checkRewardProgress() {
    if (_hasEarnedCoins || widget.video.duration == 0) return;

    final targetSeconds = (widget.video.duration * 0.8).clamp(5, 60).toInt(); // 80% or max 60 seconds
    final halfwaySeconds = targetSeconds ~/ 2;

    if (_secondsWatched == halfwaySeconds && _showHalfwayToast) {
      _showHalfwayToast = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Keep watching to earn coins! 🪙', style: GoogleFonts.poppins()),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }

    if (_secondsWatched >= targetSeconds && !_hasEarnedCoins) {
      _grantReward();
    }
  }

  Future<void> _grantReward() async {
    setState(() {
      _hasEarnedCoins = true;
    });
    
    _watchTimer?.cancel();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    // Prevent duplicate rewards for same video
    if (userProvider.user != null && !userProvider.user!.watchedVideoIds.contains(widget.video.id)) {
      try {
        final earnedCoins = 10; // Standard shorts reward
        await userProvider.watchVideoReward(widget.video.id, earnedCoins);
        videoProvider.incrementViews(widget.video.id);

        if (mounted) {
          CoinEarnedAnimation.show(context, coins: earnedCoins);
        }
      } catch (e) {
        debugPrint('Error granting reward: $e');
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _pauseWatchTimer();
      } else {
        _controller!.play();
        _startWatchTimer();
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: widget.video.thumbnail,
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
            errorWidget: (context, url, error) => Container(color: Colors.black),
          ),
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          // Play/Pause Overlay Icon
          if (!_controller!.value.isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 64),
              ),
            ),
            
          // Mute Toggle Button
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 28),
              onPressed: _toggleMute,
            ),
          ),

          // Video Info Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16).copyWith(top: 60),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.video.title,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: Text('${widget.video.categoryIcon} ${widget.video.categoryName}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.remove_red_eye, color: Colors.white54, size: 14),
                      const SizedBox(width: 4),
                      Text(widget.video.formattedViews, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Bar
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
