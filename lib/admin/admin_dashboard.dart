import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/admin_stat_card.dart';
import '../core/constants/app_colors.dart';
// Note: In production, import fl_chart

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyMetrics(),
          const SizedBox(height: 24),
          _buildChartsRow(),
          const SizedBox(height: 24),
          _buildMoreStatsRow(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Row(
      children: [
        const Expanded(
          child: AdminStatCard(
            title: 'Total Users',
            value: '12,450',
            subtitle: '+124 today',
            icon: Icons.people,
            color: Colors.purpleAccent,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: AdminStatCard(
            title: 'Total Videos',
            value: '342',
            subtitle: '+12 this week',
            icon: Icons.video_library,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: AdminStatCard(
            title: 'Total Revenue',
            value: '\$14,500.50',
            subtitle: 'This month: \$3,200',
            icon: Icons.attach_money,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AdminStatCard(
            title: 'Videos Watched Today',
            value: '45,200',
            subtitle: 'Avg: 4.5 per user',
            icon: Icons.play_circle_filled,
            color: Colors.pink[400]!,
          ),
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue Overview', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Text('fl_chart BarChart placeholder\nLast 12 months', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Container(
            height: 350,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Growth', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Text('fl_chart LineChart placeholder\nLast 30 days', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('VIP Distribution', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Center(child: Text('fl_chart PieChart placeholder', style: TextStyle(color: Colors.white38))),
                const Spacer(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Categories', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Center(child: Text('Horizontal BarChart placeholder', style: TextStyle(color: Colors.white38))),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Pending Withdrawals', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onAction: () {}, child: const Text('View All', style: TextStyle(color: AppColors.primary))),
            ],
          ),
          const SizedBox(height: 16),
          _buildWithdrawalsTable(),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.05)),
        dataTextStyle: const TextStyle(color: Colors.white70),
        columns: const [
          DataColumn(label: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Action', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
        rows: [
          _buildWithdrawalRow('Alex King', '\$10.00', 'PayPal', '10 mins ago'),
          _buildWithdrawalRow('Sarah M', '\$5.00', 'Amazon', '1 hour ago'),
          _buildWithdrawalRow('John Doe', '\$20.00', 'Crypto', '2 hours ago'),
        ],
      ),
    );
  }

  DataRow _buildWithdrawalRow(String name, String amount, String method, String date) {
    return DataRow(cells: [
      DataCell(Text(name)),
      DataCell(Text(amount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(Text(method)),
      DataCell(Text(date)),
      DataCell(Row(
        children: [
          TextButton(onPressed: () {}, child: const Text('Approve', style: TextStyle(color: Colors.green))),
          TextButton(onPressed: () {}, child: const Text('Reject', style: TextStyle(color: Colors.red))),
        ],
      )),
    ]);
  }
}
