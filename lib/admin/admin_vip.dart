import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/admin_stat_card.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';

class AdminVip extends StatefulWidget {
  const AdminVip({Key? key}) : super(key: key);

  @override
  State<AdminVip> createState() => _AdminVipState();
}

class _AdminVipState extends State<AdminVip> {
  final _emailCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '30');
  String _selectedPlan = 'Gold VIP';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💎 VIP Management', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: AdminStatCard(title: 'Active VIP Members', value: '42', icon: Icons.workspace_premium, color: Colors.amber)),
              const SizedBox(width: 16),
              Expanded(child: AdminStatCard(title: 'VIP Revenue', value: '\$419.58', icon: Icons.attach_money, color: Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: AdminStatCard(title: 'Conversion Rate', value: '3.4%', icon: Icons.trending_up, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.black12),
                        columns: const [
                          DataColumn(label: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Purchased', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Expires', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          _buildVipRow('Alex Johnson', 'Gold VIP', '2026-07-01', '2026-08-01'),
                          _buildVipRow('Maria Garcia', 'Platinum VIP', '2026-06-15', '2026-09-15'),
                          _buildVipRow('David Smith', 'Silver VIP', '2026-07-10', '2026-08-10'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Manual VIP Grant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'User Email or UID', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24)),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPlan,
                            dropdownColor: const Color(0xFF1A1A2E),
                            style: const TextStyle(color: Colors.white),
                            underline: const SizedBox(),
                            items: ['Silver VIP', 'Gold VIP', 'Platinum VIP', 'Diamond VIP'].map((String val) {
                              return DropdownMenuItem<String>(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPlan = val);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _daysCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(hintText: 'Duration (Days)', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Grant VIP',
                          onPressed: () async {
                            final target = _emailCtrl.text.trim();
                            final days = int.tryParse(_daysCtrl.text.trim()) ?? 30;
                            if (target.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter User Email or UID!'), backgroundColor: Colors.red));
                              return;
                            }
                            try {
                              final planKey = _selectedPlan.split(' ')[0].toLowerCase();
                              final snap = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: target).limit(1).get();
                              if (snap.docs.isNotEmpty) {
                                await snap.docs.first.reference.update({
                                  'vipPlan': planKey,
                                  'vipExpiry': Timestamp.fromDate(DateTime.now().add(Duration(days: days))),
                                });
                              }
                              _emailCtrl.clear();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Granted $_selectedPlan for $days days!'), backgroundColor: Colors.green));
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                      ],
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

  DataRow _buildVipRow(String user, String plan, String purchased, String expires) {
    return DataRow(cells: [
      DataCell(Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      DataCell(Chip(label: Text(plan, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.amber.withOpacity(0.2))),
      DataCell(Text(purchased, style: const TextStyle(color: Colors.white70))),
      DataCell(Text(expires, style: const TextStyle(color: Colors.white70))),
      DataCell(
        Row(
          children: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Extended $user VIP by 30 days!'), backgroundColor: Colors.blue));
              },
              child: const Text('Extend', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Revoked $user VIP status.'), backgroundColor: Colors.orange));
              },
              child: const Text('Revoke', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    ]);
  }
}
