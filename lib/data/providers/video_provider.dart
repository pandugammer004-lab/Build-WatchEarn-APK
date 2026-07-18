import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/category_model.dart';
import '../../core/services/firestore_service.dart';

class VideoProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<VideoModel> _allVideos = [];
  List<VideoModel> _trendingVideos = [];
  List<VideoModel> _featuredVideos = [];
  List<VideoModel> _filteredVideos = [];
  List<VideoModel> _favoriteVideos = [];
  List<CategoryModel> _categories = [];
  
  String _selectedCategory = 'all';
  bool _isLoading = false;
  String _searchQuery = '';
  VideoModel? _currentVideo;

  List<VideoModel> get allVideos => _allVideos;
  List<VideoModel> get trendingVideos => _trendingVideos;
  List<VideoModel> get featuredVideos => _featuredVideos;
  List<VideoModel> get filteredVideos => _filteredVideos;
  List<VideoModel> get favoriteVideos => _favoriteVideos;
  List<CategoryModel> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  VideoModel? get currentVideo => _currentVideo;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadVideos() async {
    try {
      _setLoading(true);
      final rawVideos = await _firestoreService.getVideos();
      // Enforce the 3 strictly allowed categories
      _allVideos = rawVideos.where((v) => 
        v.categoryId == 'cricket' || 
        v.categoryId == 'football' || 
        v.categoryId == 'funny'
      ).toList();
      _trendingVideos = _allVideos.where((v) => v.isTrending).toList();
      _featuredVideos = _allVideos.where((v) => v.isFeatured).toList();
      _filteredVideos = _allVideos;
    } catch (e) {
      debugPrint("Error loading videos: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Returns a shuffled list of all videos the user hasn't watched yet.
  List<VideoModel> getMixedUnwatchedShorts(List<String> watchedIds) {
    // Filter out videos the user has already watched
    List<VideoModel> unwatched = _allVideos.where((v) => !watchedIds.contains(v.id)).toList();
    // Shuffle to mix cricket, football, and funny
    unwatched.shuffle();
    return unwatched;
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _firestoreService.getCategories();
      if (_categories.isEmpty) {
        _categories = CategoryModel.defaultCategories;
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
      _categories = CategoryModel.defaultCategories;
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadFavorites(List<String> favoriteIds) async {
    _favoriteVideos = _allVideos.where((v) => favoriteIds.contains(v.id)).toList();
    notifyListeners();
  }

  void filterByCategory(String categoryId) {
    _selectedCategory = categoryId;
    if (categoryId == 'all') {
      _filteredVideos = _allVideos;
    } else {
      _filteredVideos = _allVideos.where((v) => v.categoryId == categoryId).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      searchVideos(_searchQuery);
    } else {
      notifyListeners();
    }
  }

  void searchVideos(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      filterByCategory(_selectedCategory);
    } else {
      final queryLower = query.toLowerCase();
      var baseList = _selectedCategory == 'all' 
          ? _allVideos 
          : _allVideos.where((v) => v.categoryId == _selectedCategory).toList();
          
      _filteredVideos = baseList.where((v) => 
        v.title.toLowerCase().contains(queryLower) || 
        v.description.toLowerCase().contains(queryLower)
      ).toList();
      notifyListeners();
    }
  }

  Future<void> incrementViews(String videoId) async {
    try {
      await _firestoreService.incrementVideoViews(videoId);
      final index = _allVideos.indexWhere((v) => v.id == videoId);
      if (index != -1) {
        final video = _allVideos[index];
        _allVideos[index] = VideoModel(
          id: video.id,
          videoUrl: video.videoUrl,
          title: video.title,
          description: video.description,
          categoryId: video.categoryId,
          categoryName: video.categoryName,
          categoryIcon: video.categoryIcon,
          duration: video.duration,
          views: video.views + 1,
          likes: video.likes,
          publishedAt: video.publishedAt,
          isTrending: video.isTrending,
          isFeatured: video.isFeatured,
          isVipOnly: video.isVipOnly,
          isActive: video.isActive,
          order: video.order,
          tags: video.tags,
          thumbnailUrl: video.thumbnailUrl,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error incrementing views: $e");
    }
  }

  Future<void> incrementLikes(String videoId) async {
    // Implement like functionality similarly to incrementViews
  }

  List<VideoModel> getRelatedVideos(VideoModel video) {
    return _allVideos.where((v) => v.categoryId == video.categoryId && v.id != video.id).take(5).toList();
  }

  void setCurrentVideo(VideoModel video) {
    _currentVideo = video;
    notifyListeners();
  }

  List<VideoModel> getUnwatchedVideos(List<VideoModel> source, dynamic user) {
    if (user == null) return source;
    return source.where((v) => !user.watchedVideoIds.contains(v.id)).toList();
  }
}
