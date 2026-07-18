import 'package:flutter/material.dart';
import '../../data/models/video_model.dart';
import '../../core/widgets/shorts_video_player.dart';

class ShortsFeedScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const ShortsFeedScreen({Key? key, required this.videos, required this.initialIndex}) : super(key: key);

  @override
  State<ShortsFeedScreen> createState() => _ShortsFeedScreenState();
}

class _ShortsFeedScreenState extends State<ShortsFeedScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return ShortsVideoPlayer(
            video: widget.videos[index],
            isPlaying: _currentIndex == index,
          );
        },
      ),
      // Back button overlay
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
