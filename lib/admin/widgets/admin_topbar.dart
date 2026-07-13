import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTopbar extends StatelessWidget {
  final String title;
  final VoidCallback onLogout;

  const AdminTopbar({Key? key, required this.title, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(bottom: BorderSide(color: Colors.white12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.play_circle_filled, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                'WatchEarn Admin',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 40),
              Text(
                title,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.amber,
                child: Text('A', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Text('Admin', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white54),
                onPressed: onLogout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
