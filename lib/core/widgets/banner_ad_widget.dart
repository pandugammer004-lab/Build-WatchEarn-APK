import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/ad_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../constants/app_colors.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().userModel;
      if (user != null && !user.isVip) {
        context.read<AdProvider>().loadBannerAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AdProvider>(
      builder: (context, authProvider, adProvider, child) {
        final user = authProvider.userModel;
        
        // Hide for VIP users
        if (user != null && user.isVip) {
          return const SizedBox.shrink();
        }

        if (adProvider.isBannerLoaded) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Advertisement',
                style: TextStyle(color: Colors.white38, fontSize: 10),
              ),
              const SizedBox(height: 4),
              adProvider.buildBannerAdWidget(),
              const SizedBox(height: 8),
            ],
          );
        }

        return Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'Advertisement',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}
