import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_model.dart';
import '../../../data/providers/video_provider.dart';

class ManageVideosTab extends StatefulWidget {
  const ManageVideosTab({Key? key}) : super(key: key);

  @override
  State<ManageVideosTab> createState() => _ManageVideosTabState();
}

class _ManageVideosTabState extends State<ManageVideosTab> {
  void _showAddVideoDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final thumbCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: Text('Add New Video', style: GoogleFonts.poppins(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white54))),
                TextField(controller: urlCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Video URL (e.g. YouTube)', labelStyle: TextStyle(color: Colors.white54))),
                TextField(controller: thumbCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Thumbnail URL', labelStyle: TextStyle(color: Colors.white54))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || urlCtrl.text.isEmpty) return;
                
                final newVideo = VideoModel(
                  id: FirebaseFirestore.instance.collection('videos').doc().id,
                  title: titleCtrl.text,
                  url: urlCtrl.text,
                  thumbnail: thumbCtrl.text.isEmpty ? 'https://via.placeholder.com/400x200' : thumbCtrl.text,
                  categoryId: 'all',
                  durationSeconds: 60,
                  views: 0,
                  rewardCoins: 10,
                  isActive: true,
                  isTrending: false,
                  publishedAt: DateTime.now(),
                );
                
                await FirebaseFirestore.instance.collection('videos').doc(newVideo.id).set(newVideo.toFirestore());
                
                if (context.mounted) {
                  Navigator.pop(context);
                  Provider.of<VideoProvider>(context, listen: false).loadVideos();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVideoDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, _) {
          if (videoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = videoProvider.videos;
          if (videos.isEmpty) {
            return const Center(child: Text('No videos found. Add one!', style: TextStyle(color: Colors.white)));
          }
          
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                color: AppColors.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Image.network(video.thumbnail, width: 80, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_library, color: Colors.white),
                  ),
                  title: Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${video.views} views • ${video.rewardCoins} coins', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('videos').doc(video.id).delete();
                      videoProvider.loadVideos();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
