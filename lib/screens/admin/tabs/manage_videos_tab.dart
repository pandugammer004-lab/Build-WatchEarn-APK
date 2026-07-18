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
                  leading: Image.network(video.thumbnail, width: 60, height: 80, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.video_library, color: Colors.white),
                  ),
                  title: Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${video.categoryName} • ${video.views} views • ${video.formattedDuration}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
  final descCtrl = TextEditingController(text: 'Check out this awesome short!');
  final urlCtrl = TextEditingController();
  final thumbCtrl = TextEditingController();
  final durationCtrl = TextEditingController(text: '30');
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardColor,
      title: Text('Add New Short', style: GoogleFonts.poppins(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlCtrl, 
              style: const TextStyle(color: Colors.white), 
              decoration: const InputDecoration(labelText: 'Direct MP4 URL', labelStyle: TextStyle(color: Colors.white54))
            ),
            TextField(controller: thumbCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Thumbnail Image URL', labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white54))),
            TextField(controller: durationCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Duration (Seconds)', hintText: 'e.g. 30', hintStyle: TextStyle(color: Colors.white30), labelStyle: TextStyle(color: Colors.white54))),
            const SizedBox(height: 16),
            Consumer<VideoProvider>(
              builder: (context, videoProvider, _) {
                // Ensure only cricket, football, funny are allowed
                final categories = videoProvider.categories.where((c) => ['cricket', 'football', 'funny'].contains(c.id)).toList();
                if (categories.isEmpty) return const SizedBox.shrink();
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  dropdownColor: AppColors.cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.icon} ${c.name}'),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCategoryId = val;
                    });
                  },
                );
              }
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          onPressed: () async {
            if (titleCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty || thumbCtrl.text.trim().isEmpty || _selectedCategoryId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select a category')));
              return;
            }
            
            try {
              final videoProvider = Provider.of<VideoProvider>(context, listen: false);
              final catId = _selectedCategoryId!;
              final cat = videoProvider.categories.firstWhere((c) => c.id == catId);
              
              final int durationSeconds = int.tryParse(durationCtrl.text.trim()) ?? 30;
              final docRef = FirebaseFirestore.instance.collection('videos').doc();
              final newVideo = VideoModel(
                id: docRef.id,
                videoUrl: urlCtrl.text.trim(),
                thumbnailUrl: thumbCtrl.text.trim(),
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                categoryId: catId,
                categoryName: cat.name,
                categoryIcon: cat.icon,
                duration: durationSeconds,
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
