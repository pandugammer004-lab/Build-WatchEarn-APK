import 'package:flutter/material.dart';
import 'admin_login.dart';
import 'admin_dashboard.dart';
import 'admin_videos.dart';
import 'admin_users.dart';
import 'admin_categories.dart';
import 'admin_withdrawals.dart';
import 'admin_vip.dart';
import 'admin_notifications.dart';
import 'admin_analytics.dart';
import 'admin_settings.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_topbar.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({Key? key}) : super(key: key);

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _isAuthenticated = false;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboard(),
    const AdminVideos(),
    const AdminUsers(),
    const AdminCategories(),
    const AdminWithdrawals(),
    const AdminVip(),
    const AdminNotifications(),
    const AdminAnalytics(),
    const AdminSettings(),
  ];

  final List<String> _pageTitles = [
    'Dashboard',
    'Video Management',
    'User Management',
    'Category Management',
    'Withdrawals',
    'VIP Management',
    'Notifications',
    'Analytics',
    'App Settings',
  ];

  void _login(String email) {
    if (email == 'admin@watchearn.app') {
      setState(() => _isAuthenticated = true);
    }
  }

  void _logout() {
    setState(() {
      _isAuthenticated = false;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AdminLogin(onLogin: _login);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Column(
        children: [
          AdminTopbar(
            title: _pageTitles[_selectedIndex],
            onLogout: _logout,
          ),
          Expanded(
            child: Row(
              children: [
                AdminSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  onLogout: _logout,
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20)),
                    child: Container(
                      color: const Color(0xFF0D0D1A),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
