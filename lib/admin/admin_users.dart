import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/utils/helpers.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({Key? key}) : super(key: key);

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  void _showUserDetailPanel(String name) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(userName: name),
    );
  }

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
              Text('👥 User Management', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {}, // Export CSV
                icon: const Icon(Icons.download),
                label: const Text('Export CSV', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email or code...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: 'All Users',
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: ['All Users', 'VIP Users', 'Free Users', 'Flagged'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ],
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
                        DataColumn(label: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('VIP Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Joined', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        _buildUserRow('Alex King', 'alex@email.com', 84500, 'Gold VIP', 'Mar 1, 2024', 'Active'),
                        _buildUserRow('Sarah M', 'sarah@email.com', 62300, 'Free', 'Mar 5, 2024', 'Active'),
                        _buildUserRow('SuspiciousUser', 'bot@email.com', 999999, 'Free', 'Today', 'Flagged'),
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

  DataRow _buildUserRow(String name, String email, int coins, String vip, String joined, String status) {
    Color statusColor = status == 'Active' ? Colors.green : Colors.red;
    return DataRow(cells: [
      DataCell(
        Row(
          children: [
            CircleAvatar(radius: 16, backgroundColor: Colors.amber, child: Text(name[0], style: const TextStyle(color: Colors.black, fontSize: 12))),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      DataCell(Text(email, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(Helpers.formatCoins(coins), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
      DataCell(Chip(label: Text(vip, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: vip == 'Free' ? Colors.white10 : Colors.amber.withOpacity(0.2))),
      DataCell(Text(joined, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
      DataCell(
        Row(
          children: [
            IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () => _showUserDetailPanel(name), tooltip: 'View Profile'),
            IconButton(icon: const Icon(Icons.block, color: Colors.orange), onPressed: () {}, tooltip: 'Suspend'),
          ],
        ),
      ),
    ]);
  }
}

class UserDetailDialog extends StatelessWidget {
  final String userName;
  const UserDetailDialog({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 24, backgroundColor: Colors.amber, child: Text(userName[0], style: const TextStyle(color: Colors.black, fontSize: 24))),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('user@email.com', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            const Text('Edit Coins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: CustomTextField(hintText: 'Amount', prefixIcon: Icons.monetization_on)),
                const SizedBox(width: 16),
                CustomButton(text: 'Add', onPressed: () {}, width: 80, color: Colors.green),
                const SizedBox(width: 8),
                CustomButton(text: 'Deduct', onPressed: () {}, width: 80, color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            const Text('VIP Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: 'Gold VIP',
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: ['Free', 'Silver VIP', 'Gold VIP', 'Platinum VIP'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(text: 'Apply VIP', onPressed: () {}, width: 120),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Danger Zone', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: CustomButton(text: 'Suspend Account', onPressed: () {}, color: Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: CustomButton(text: 'Delete Account', onPressed: () {}, color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
