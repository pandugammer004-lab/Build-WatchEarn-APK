import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Rewards', 'Videos', 'VIP', 'Referrals'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1', 'type': 'Rewards', 'icon': '🎁', 'color': Colors.amber,
      'title': 'Daily Bonus Claimed!', 'body': 'You received 50 coins for your day 1 streak.',
      'time': '2m ago', 'isRead': false,
    },
    {
      'id': '2', 'type': 'Videos', 'icon': '🎬', 'color': Colors.purple,
      'title': 'New Premium Videos', 'body': '5 new high-paying videos are available to watch!',
      'time': '1h ago', 'isRead': false,
    },
    {
      'id': '3', 'type': 'VIP', 'icon': '💎', 'color': Colors.cyan,
      'title': 'VIP Offer Expiring', 'body': 'Your 50% discount on Gold VIP expires in 2 hours!',
      'time': '3h ago', 'isRead': true,
    },
    {
      'id': '4', 'type': 'Referrals', 'icon': '👥', 'color': Colors.green,
      'title': 'New Referral Joined', 'body': 'John used your code. You earned 500 coins!',
      'time': '1d ago', 'isRead': true,
    },
    {
      'id': '5', 'type': 'Rewards', 'icon': '💰', 'color': Colors.blue,
      'title': 'Withdrawal Successful', 'body': 'Your \$10 PayPal withdrawal has been completed.',
      'time': '2d ago', 'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('🔔 Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) n['isRead'] = true;
              });
            },
            child: const Text('Mark All Read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedFilter = filter),
                    backgroundColor: Colors.white10,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filtered = _selectedFilter == 'All' 
        ? _notifications 
        : _notifications.where((n) => n['type'] == _selectedFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No notifications yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('We\'ll notify you about rewards', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notif = filtered[index];
        final bool isRead = notif['isRead'];

        return Dismissible(
          key: Key(notif['id']),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            setState(() => _notifications.removeWhere((n) => n['id'] == notif['id']));
          },
          child: Container(
            color: isRead ? Colors.transparent : Colors.white.withOpacity(0.05),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () {
                setState(() => notif['isRead'] = true);
                // Navigate if needed
              },
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notif['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(notif['icon'], style: const TextStyle(fontSize: 24))),
              ),
              title: Text(
                notif['title'],
                style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notif['body'], style: TextStyle(color: isRead ? Colors.white54 : Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(notif['time'], style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                ],
              ),
              trailing: !isRead 
                  ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
                  : null,
            ),
          ),
        );
      },
    );
  }
}
