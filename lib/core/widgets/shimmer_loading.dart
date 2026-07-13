import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.cardBorder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class VideoCardSkeleton extends StatelessWidget {
  final bool isHorizontal;
  
  const VideoCardSkeleton({
    Key? key, 
    this.isHorizontal = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: isHorizontal ? _buildHorizontal() : _buildVertical(),
    );
  }

  Widget _buildVertical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerLoading(width: double.infinity, height: 180, borderRadius: 0),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerLoading(width: double.infinity, height: 16),
              const SizedBox(height: 8),
              const ShimmerLoading(width: 150, height: 16),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerLoading(width: 60, height: 14),
                  ShimmerLoading(width: 40, height: 20, borderRadius: 12),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontal() {
    return Row(
      children: [
        const ShimmerLoading(width: 140, height: 100, borderRadius: 0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ShimmerLoading(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 100, height: 14),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerLoading(width: 50, height: 12),
                    ShimmerLoading(width: 40, height: 18, borderRadius: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
