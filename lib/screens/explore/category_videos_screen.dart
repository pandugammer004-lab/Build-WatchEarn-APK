import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/video_card.dart';
import '../../data/models/category_model.dart';
import '../../data/providers/video_provider.dart';
import '../../data/providers/user_provider.dart';
import '../player/shorts_feed_screen.dart';

class CategoryVideosScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryVideosScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
      ),
      body: Consumer2<VideoProvider, UserProvider>(
        builder: (context, provider, userProvider, _) {
          final categoryVideos = provider.allVideos.where((v) => v.categoryId == category.id).toList();

          if (categoryVideos.isEmpty) {
            return Center(
              child: Text(
                'No videos found in this category',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: categoryVideos.length,
            itemBuilder: (context, index) {
              return VideoCard(
                video: categoryVideos[index],
                type: VideoCardType.grid,
                isVipUnlocked: userProvider.user?.isVip ?? false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ShortsFeedScreen(videos: categoryVideos, initialIndex: index)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
