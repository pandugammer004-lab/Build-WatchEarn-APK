import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum VipTier { none, silver, gold, platinum, diamond }

class VipBadge extends StatelessWidget {
  final VipTier tier;
  final double size;

  const VipBadge({
    Key? key,
    required this.tier,
    this.size = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tier == VipTier.none) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: _getGradient(tier),
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            color: _getColor(tier).withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: size * 0.6, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            _getLabel(tier),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient(VipTier tier) {
    switch (tier) {
      case VipTier.silver:
        return AppColors.silverGradient;
      case VipTier.gold:
        return AppColors.goldGradient;
      case VipTier.platinum:
        return AppColors.platinumGradient;
      case VipTier.diamond:
        return AppColors.diamondGradient;
      default:
        return AppColors.silverGradient;
    }
  }

  Color _getColor(VipTier tier) {
    switch (tier) {
      case VipTier.silver:
        return AppColors.vipSilver;
      case VipTier.gold:
        return AppColors.vipGold;
      case VipTier.platinum:
        return AppColors.vipPlatinum;
      case VipTier.diamond:
        return AppColors.vipDiamond;
      default:
        return Colors.transparent;
    }
  }

  String _getLabel(VipTier tier) {
    return tier.toString().split('.').last.toUpperCase();
  }
}
