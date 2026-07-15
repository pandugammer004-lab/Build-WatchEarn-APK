import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';

class ManageWithdrawalsTab extends StatelessWidget {
  const ManageWithdrawalsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('withdrawals').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No withdrawal requests found.', style: TextStyle(color: Colors.white)));
          }

          final docs = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              final status = data['status'] ?? 'pending';
              final amount = data['amount'] ?? 0;
              final method = data['method'] ?? 'Unknown';
              final details = data['details'] ?? '';
              final date = data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16) : 'Unknown';

              return Card(
                color: AppColors.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$$amount via $method', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'pending' ? Colors.orange : (status == 'approved' ? Colors.green : Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Details: $details', style: const TextStyle(color: Colors.white70)),
                      Text('Date: $date', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 12),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => FirebaseFirestore.instance.collection('withdrawals').doc(id).update({'status': 'rejected'}),
                              child: const Text('REJECT', style: TextStyle(color: Colors.redAccent)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => FirebaseFirestore.instance.collection('withdrawals').doc(id).update({'status': 'approved'}),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('APPROVE', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
