import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
    showDialog(
      context: context,
      builder: (context) => const AddVideoDialog(),
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
          final videos = videoProvider.allVideos;
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
                  leading: Image.network(video.thumbnailMQ, width: 80, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_library, color: Colors.white),
                  ),
                  title: Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${video.views} views • ${video.formattedDuration}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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

class AddVideoDialog extends StatefulWidget {
  const AddVideoDialog({Key? key}) : super(key: key);

  @override
  State<AddVideoDialog> createState() => _AddVideoDialogState();
}

class _AddVideoDialogState extends State<AddVideoDialog> {
  final titleCtrl = TextEditingController();
  final urlCtrl = TextEditingController();
  final thumbCtrl = TextEditingController();
  bool isFetching = false;

  void _fetchYoutubeDetails() async {
    final url = urlCtrl.text.trim();
    if (url.isEmpty || (!url.contains('youtube.com') && !url.contains('youtu.be'))) return;

    setState(() { isFetching = true; });

    try {
      final response = await http.get(Uri.parse('https://www.youtube.com/oembed?url=$url&format=json'));
      if (response.statusCode == 200) {
        final titleMatch = RegExp(r'"title"\s*:\s*"([^"]+)"').firstMatch(response.body);
        final thumbMatch = RegExp(r'"thumbnail_url"\s*:\s*"([^"]+)"').firstMatch(response.body);
        
        if (titleMatch != null && titleCtrl.text.isEmpty) {
          titleCtrl.text = titleMatch.group(1) ?? '';
        }
        if (thumbMatch != null && thumbCtrl.text.isEmpty) {
          thumbCtrl.text = (thumbMatch.group(1) ?? '').replaceAll('\\/', '/');
        }
      }
    } catch (e) {
      debugPrint('Error fetching youtube details: $e');
    } finally {
      setState(() { isFetching = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardColor,
      title: Text('Add New Video', style: GoogleFonts.poppins(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: urlCtrl, 
                    style: const TextStyle(color: Colors.white), 
                    decoration: const InputDecoration(labelText: 'Video URL', labelStyle: TextStyle(color: Colors.white54))
                  ),
                ),
                IconButton(
                  icon: isFetching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search, color: Colors.amber),
                  onPressed: isFetching ? null : _fetchYoutubeDetails,
                  tooltip: 'Fetch Title & Thumbnail',
                ),
              ],
            ),
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: thumbCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Thumbnail URL', labelStyle: TextStyle(color: Colors.white54))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          onPressed: () async {
            if (titleCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Title and URL')));
              return;
            }
            
            String yId = urlCtrl.text.trim();
            // Handle different YouTube URL formats
            if (yId.contains('v=')) {
              yId = yId.split('v=')[1].split('&')[0];
            } else if (yId.contains('youtu.be/')) {
              yId = yId.split('youtu.be/')[1].split('?')[0];
            } else if (yId.contains('shorts/')) {
              yId = yId.split('shorts/')[1].split('?')[0];
            } else if (!yId.contains('http') && yId.length == 11) {
              // It's likely just the ID itself
              yId = yId; 
            }
            
            try {
              final docRef = FirebaseFirestore.instance.collection('videos').doc();
              final newVideo = VideoModel(
                id: docRef.id,
                youtubeId: yId,
                title: titleCtrl.text.trim(),
                description: 'No description',
                categoryId: 'all',
                categoryName: 'All',
                categoryIcon: '🎬',
                duration: 60, // Default 60s, will be updated if needed
                views: 0,
                likes: 0,
                publishedAt: DateTime.now(),
                isTrending: false,
                isFeatured: false,
                isVipOnly: false,
                isActive: true,
                order: 0,
                tags: [],
              );
              
              await docRef.set(newVideo.toFirestore());
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Added Successfully!'), backgroundColor: Colors.green));
                Provider.of<VideoProvider>(context, listen: false).loadVideos();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
