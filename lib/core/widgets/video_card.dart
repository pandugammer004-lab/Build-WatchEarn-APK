import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/video_model.dart';
import '../constants/app_colors.dart';
import 'shimmer_loading.dart';

enum VideoCardType { vertical, grid, horizontal, featured }

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final VideoCardType type;
  final VoidCallback onTap;
  final bool isVipUnlocked;

  const VideoCard({
    Key? key,
    required this.video,
    required this.type,
    required this.onTap,
    this.isVipUnlocked = false,
  }) : super(key: key);

  String get _thumbnailUrl => video.thumbnail;
  String get _hqThumbnailUrl => video.thumbnail;
  String get _maxresThumbnailUrl => video.thumbnail;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    switch (type) {
      case VideoCardType.vertical:
        return _buildVertical();
      case VideoCardType.grid:
        return _buildGrid();
      case VideoCardType.horizontal:
        return _buildHorizontal();
      case VideoCardType.featured:
        return _buildFeatured();
    }
  }

  Widget _buildVertical() {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(
            height: 100,
            width: 180,
            url: _thumbnailUrl,
            showDuration: true,
            showVipLock: video.isVipOnly && !isVipUnlocked,
            topRightWidget: _buildCoinBadge(),
            topLeftWidget: video.isTrending ? _buildBadge('TRENDING', Colors.red) : null,
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildCategoryChip(),
              const Spacer(),
              Text(
                '${video.views} views',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(
            height: 120,
            width: double.infinity,
            url: _hqThumbnailUrl,
            showDuration: true,
            showVipLock: video.isVipOnly && !isVipUnlocked,
            topRightWidget: _buildCoinBadge(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  video.categoryName,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(
            height: 80,
            width: 120,
            url: _thumbnailUrl,
            showDuration: true,
            showVipLock: video.isVipOnly && !isVipUnlocked,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCategoryChip(),
                    const SizedBox(width: 8),
                    Text(
                      '${video.views} views',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatured() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: _maxresThumbnailUrl, // Try maxres for featured
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => CachedNetworkImage(
                imageUrl: _hqThumbnailUrl, // Fallback to hq
                fit: BoxFit.cover,
              ),
              placeholder: (context, url) => const ShimmerLoading(width: double.infinity, height: double.infinity),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.play_circle_fill,
              size: 64,
              color: Colors.white70,
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _buildBadge('FEATURED', AppColors.primary),
          ),
          if (video.isVipOnly && !isVipUnlocked)
            const Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.lock, color: Colors.amber),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryChip(),
                const SizedBox(height: 4),
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildDurationBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail({
    required double width,
    required double height,
    required String url,
    bool showDuration = false,
    bool showVipLock = false,
    Widget? topLeftWidget,
    Widget? topRightWidget,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => ShimmerLoading(width: width, height: height),
              errorWidget: (context, url, error) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
            ),
            if (showDuration)
              Positioned(
                bottom: 4,
                right: 4,
                child: _buildDurationBadge(),
              ),
            if (showVipLock)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Icon(Icons.lock, color: Colors.amber, size: 32),
                ),
              ),
            if (topLeftWidget != null)
              Positioned(
                top: 4,
                left: 4,
                child: topLeftWidget,
              ),
            if (topRightWidget != null)
              Positioned(
                top: 4,
                right: 4,
                child: topRightWidget,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationBadge() {
    final minutes = video.duration ~/ 60;
    final seconds = video.duration % 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$minutes:${seconds.toString().padLeft(2, '0')}',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCoinBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('+10 ', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
          const Text('🪙', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(video.categoryIcon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            video.categoryName,
            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
