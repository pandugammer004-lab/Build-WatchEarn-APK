import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;

  const AdminSidebar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF12122A),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildNavItem(0, Icons.home, 'Dashboard'),
          _buildNavItem(1, Icons.video_library, 'Video Management'),
          _buildNavItem(2, Icons.people, 'User Management'),
          _buildNavItem(3, Icons.folder, 'Categories'),
          _buildNavItem(4, Icons.payments, 'Withdrawals'),
          _buildNavItem(5, Icons.workspace_premium, 'VIP Management'),
          _buildNavItem(6, Icons.notifications, 'Notifications'),
          _buildNavItem(7, Icons.analytics, 'Analytics'),
          _buildNavItem(8, Icons.settings, 'App Settings'),
          const Spacer(),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white54),
            title: const Text('Logout', style: TextStyle(color: Colors.white54)),
            onTap: onLogout,
            hoverColor: Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        border: isSelected ? const Border(left: BorderSide(color: AppColors.primary, width: 4)) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.white54),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onItemSelected(index),
        hoverColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
