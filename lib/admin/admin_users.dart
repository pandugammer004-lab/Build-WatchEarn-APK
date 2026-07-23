import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class UserDetailDialog extends StatefulWidget {
  final String userName;
  final String? userId;
  const UserDetailDialog({Key? key, required this.userName, this.userId}) : super(key: key);

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  final _coinsController = TextEditingController();
  String _selectedVip = 'Gold VIP';

  @override
  void dispose() {
    _coinsController.dispose();
    super.dispose();
  }

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
                    CircleAvatar(radius: 24, backgroundColor: Colors.amber, child: Text(widget.userName[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 24))),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.userName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('User Profile', style: TextStyle(color: Colors.white54)),
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
                Expanded(child: CustomTextField(controller: _coinsController, hintText: 'Amount', prefixIcon: Icons.monetization_on, keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                CustomButton(text: 'Add', onPressed: () async {
                  final amount = int.tryParse(_coinsController.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  if (widget.userId != null) {
                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'coins': FieldValue.increment(amount),
                      'totalEarned': FieldValue.increment(amount),
                    });
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $amount coins!'), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                }, width: 80, color: Colors.green),
                const SizedBox(width: 8),
                CustomButton(text: 'Deduct', onPressed: () async {
                  final amount = int.tryParse(_coinsController.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  if (widget.userId != null) {
                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'coins': FieldValue.increment(-amount),
                    });
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deducted $amount coins!'), backgroundColor: Colors.orange));
                    Navigator.pop(context);
                  }
                }, width: 80, color: Colors.red),
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
                      value: _selectedVip,
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: ['Free', 'Silver VIP', 'Gold VIP', 'Platinum VIP'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedVip = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(text: 'Apply VIP', onPressed: () async {
                  final plan = _selectedVip.split(' ')[0].toLowerCase();
                  if (widget.userId != null) {
                    await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                      'vipPlan': plan,
                      'vipExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
                    });
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Applied $_selectedVip!'), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                }, width: 120),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Danger Zone', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(text: 'Suspend Account', onPressed: () async {
                    if (widget.userId != null) {
                      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                        'isBlocked': true,
                      });
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Suspended!'), backgroundColor: Colors.orange));
                      Navigator.pop(context);
                    }
                  }, color: Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(text: 'Delete Account', onPressed: () async {
                    if (widget.userId != null) {
                      await FirebaseFirestore.instance.collection('users').doc(widget.userId).delete();
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Deleted!'), backgroundColor: Colors.red));
                      Navigator.pop(context);
                    }
                  }, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
