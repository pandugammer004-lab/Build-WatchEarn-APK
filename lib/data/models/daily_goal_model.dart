class DailyGoalModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;
  final int current;
  final int reward;
  final bool isClaimed;
  final String type; // videos/ads/shares/categories

  DailyGoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.current,
    required this.reward,
    required this.isClaimed,
    required this.type,
  });

  bool get isCompleted => current >= target;
  
  double get progress => current >= target ? 1.0 : (current / target);
  
  String get progressText => '${current > target ? target : current}/$target';

  static List<DailyGoalModel> getGoals(int videos, int ads, int shares, int categories, List<String> claimedGoals) {
    return [
      DailyGoalModel(
        id: 'first_video',
        title: 'First Video',
        description: 'Watch your first video today',
        icon: '🎬',
        target: 1,
        current: videos,
        reward: 20,
        isClaimed: claimedGoals.contains('first_video'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'morning_viewer',
        title: 'Morning Viewer',
        description: 'Watch 3 videos today',
        icon: '🌅',
        target: 3,
        current: videos,
        reward: 40,
        isClaimed: claimedGoals.contains('morning_viewer'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'half_way',
        title: 'Half Way',
        description: 'Watch 5 videos today',
        icon: '📈',
        target: 5,
        current: videos,
        reward: 60,
        isClaimed: claimedGoals.contains('half_way'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'dedicated_watcher',
        title: 'Dedicated Watcher',
        description: 'Watch 10 videos today',
        icon: '👀',
        target: 10,
        current: videos,
        reward: 120,
        isClaimed: claimedGoals.contains('dedicated_watcher'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'video_marathon',
        title: 'Video Marathon',
        description: 'Watch 20 videos today',
        icon: '🏃',
        target: 20,
        current: videos,
        reward: 250,
        isClaimed: claimedGoals.contains('video_marathon'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'daily_champion',
        title: 'Daily Champion',
        description: 'Watch 30 videos today',
        icon: '🏆',
        target: 30,
        current: videos,
        reward: 500,
        isClaimed: claimedGoals.contains('daily_champion'),
        type: 'videos',
      ),
      DailyGoalModel(
        id: 'ad_supporter',
        title: 'Ad Supporter',
        description: 'Watch 5 ads today',
        icon: '📺',
        target: 5,
        current: ads,
        reward: 100,
        isClaimed: claimedGoals.contains('ad_supporter'),
        type: 'ads',
      ),
      DailyGoalModel(
        id: 'social_butterfly',
        title: 'Social Butterfly',
        description: 'Share app once today',
        icon: '🦋',
        target: 1,
        current: shares,
        reward: 30,
        isClaimed: claimedGoals.contains('social_butterfly'),
        type: 'shares',
      ),
      DailyGoalModel(
        id: 'explorer',
        title: 'Explorer',
        description: 'Watch from 3 different categories',
        icon: '🗂️',
        target: 3,
        current: categories,
        reward: 50,
        isClaimed: claimedGoals.contains('explorer'),
        type: 'categories',
      ),
      DailyGoalModel(
        id: 'all_goals',
        title: 'All Goals Complete BONUS',
        description: 'Complete all daily goals',
        icon: '🎁',
        target: 9, // Total other goals
        current: claimedGoals.length,
        reward: 300,
        isClaimed: claimedGoals.contains('all_goals'),
        type: 'bonus',
      ),
    ];
  }
}
