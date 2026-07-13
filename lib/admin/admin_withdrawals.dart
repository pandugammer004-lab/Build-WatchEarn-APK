import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/admin_stat_card.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';

class AdminWithdrawals extends StatefulWidget {
  const AdminWithdrawals({Key? key}) : super(key: key);

  @override
  State<AdminWithdrawals> createState() => _AdminWithdrawalsState();
}

class _AdminWithdrawalsState extends State<AdminWithdrawals> {
  String _selectedTab = 'Pending';
  final List<String> _tabs = ['All', 'Pending', 'Approved', 'Rejected', 'Processing'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💸 Withdrawal Management', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: AdminStatCard(title: 'Pending', value: '45', subtitle: '\$450.00 total', icon: Icons.pending_actions, color: Colors.orange)),
              const SizedBox(width: 16),
              const Expanded(child: AdminStatCard(title: 'Approved Today', value: '12', subtitle: '\$120.00 total', icon: Icons.check_circle, color: Colors.green)),
              const SizedBox(width: 16),
              const Expanded(child: AdminStatCard(title: 'Rejected Today', value: '3', subtitle: 'Suspicious activity', icon: Icons.cancel, color: Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: AdminStatCard(title: 'Total Paid Out', value: '\$14,500', subtitle: 'All time', icon: Icons.account_balance_wallet, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedTab = tab),
                    backgroundColor: Colors.white10,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    labelStyle: TextStyle(color: isSelected ? AppColors.primary : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.black12),
                      dataRowHeight: 60,
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        _buildRow('#W1042', 'Alex King', '\$10.00', '100,000', 'PayPal', 'alex@email.com', '10 mins ago', 'Pending'),
                        _buildRow('#W1041', 'Sarah M', '\$5.00', '50,000', 'Amazon', 'sarah@email.com', '1 hour ago', 'Pending'),
                        _buildRow('#W1040', 'John Doe', '\$20.00', '200,000', 'PayPal', 'john@email.com', '2 hours ago', 'Approved'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String id, String user, String amount, String coins, String method, String details, String date, String status) {
    Color statusColor;
    switch (status) {
      case 'Approved': statusColor = Colors.green; break;
      case 'Rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(color: Colors.white54))),
      DataCell(Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      DataCell(Text(amount, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(Text(coins, style: const TextStyle(color: Colors.amber))),
      DataCell(Text(method, style: const TextStyle(color: Colors.white))),
      DataCell(Text(details, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(date, style: const TextStyle(color: Colors.white54))),
      DataCell(Chip(label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: statusColor.withOpacity(0.2))),
      DataCell(
        status == 'Pending' ? Row(
          children: [
            CustomButton(text: 'Approve', onPressed: () {}, width: 80, height: 30, color: Colors.green),
            const SizedBox(width: 8),
            CustomButton(text: 'Reject', onPressed: () {}, width: 80, height: 30, color: Colors.red),
          ],
        ) : const SizedBox(),
      ),
    ]);
  }
}
