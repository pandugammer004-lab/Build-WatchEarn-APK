import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/admin_stat_card.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';

class AdminVip extends StatelessWidget {
  const AdminVip({Key? key}) : super(key: key);

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
              const Expanded(child: AdminStatCard(title: 'Total VIP Users', value: '1,245', subtitle: '10% of total users', icon: Icons.workspace_premium, color: Colors.amber)),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Silver', '450', Colors.grey),
                      _buildMiniStat('Gold', '320', Colors.amber),
                      _buildMiniStat('Platinum', '210', Colors.blueGrey),
                      _buildMiniStat('Diamond', '150', Colors.cyan),
                      _buildMiniStat('Lifetime', '115', Colors.purple),
                    ],
                  ),
                ),
              ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Recent VIP Subscriptions', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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
                                  _buildVipRow('Alex King', 'Gold VIP', 'Today', 'Apr 15, 2024'),
                                  _buildVipRow('Sarah M', 'Lifetime', 'Yesterday', 'Never'),
                                  _buildVipRow('John Doe', 'Silver VIP', '2 days ago', 'Apr 10, 2024'),
                                ],
                              ),
                            ),
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Grant VIP Manually', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        const TextField(
                          decoration: InputDecoration(hintText: 'User Email', filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                          value: 'Gold VIP',
                          items: ['Silver VIP', 'Gold VIP', 'Platinum VIP', 'Diamond VIP', 'Lifetime'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 16),
                        const TextField(
                          decoration: InputDecoration(hintText: 'Duration (Days)', filled: true, fillColor: Colors.black26, border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(text: 'Grant VIP', onPressed: () {}),
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

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: GoogleFonts.poppins(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
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
            TextButton(onPressed: () {}, child: const Text('Extend', style: TextStyle(color: Colors.blue))),
            TextButton(onPressed: () {}, child: const Text('Revoke', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    ]);
  }
}
