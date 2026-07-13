import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📈 Analytics Dashboard', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: 'Last 30 Days',
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: ['Today', 'Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'This Year'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildChartCard('Revenue (Ads vs VIP)', 'LineChart placeholder'),
                      const SizedBox(width: 24),
                      _buildChartCard('User Retention', 'BarChart placeholder'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildChartCard('Coin Distribution', 'PieChart placeholder'),
                      const SizedBox(width: 24),
                      _buildChartCard('Videos by Category', 'PieChart placeholder'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildChartCard('Top 10 Videos', 'DataTable placeholder', height: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String placeholder, {double height = 300}) {
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: Center(
                child: Text(placeholder, style: const TextStyle(color: Colors.white38)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
