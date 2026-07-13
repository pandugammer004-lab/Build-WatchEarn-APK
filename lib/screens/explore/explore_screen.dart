import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/video_card.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/providers/video_provider.dart';
import '../../data/providers/user_provider.dart';
import '../player/video_player_screen.dart';
import 'category_videos_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Explore',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Consumer2<VideoProvider, UserProvider>(
        builder: (context, provider, userProvider, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _searchController,
                  hintText: 'Search videos, creators...',
                  prefixIcon: Icons.search,
                  onChanged: (val) {
                    provider.searchVideos(val);
                  },
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            provider.searchVideos('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
                const SizedBox(height: 24),
                if (_searchController.text.isEmpty) ...[
                  Text(
                    'Categories',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoriesGrid(provider),
                ] else ...[
                  Text(
                    'Search Results',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: provider.filteredVideos.isEmpty
                        ? Center(
                            child: Text(
                              'No results found',
                              style: GoogleFonts.poppins(color: Colors.white54),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: provider.filteredVideos.length,
                            itemBuilder: (context, index) {
                              return VideoCard(
                                video: provider.filteredVideos[index],
                                type: VideoCardType.grid,
                                isVipUnlocked: userProvider.user?.isVip ?? false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: provider.filteredVideos[index])),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesGrid(VideoProvider provider) {
    if (provider.categories.isEmpty) return const SizedBox.shrink();

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryVideosScreen(category: category),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient, // Custom per category would be better
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.allVideos.where((v) => v.categoryId == category.id).length} videos',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
