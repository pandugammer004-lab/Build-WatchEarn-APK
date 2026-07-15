import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class VipRequestsTab extends StatelessWidget {
  const VipRequestsTab({Key? key}) : super(key: key);

  void _approveRequest(BuildContext context, DocumentSnapshot requestDoc) async {
    final data = requestDoc.data() as Map<String, dynamic>;
    final userId = data['userId'];
    final planId = data['planId'];
    
    // Update User
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isVip': true,
      'vipPlan': planId,
      'vipExpiry': planId == 'lifetime' ? null : DateTime.now().add(const Duration(days: 30)),
    });
    
    // Update Request
    await requestDoc.reference.update({'status': 'approved'});
  }

  void _rejectRequest(DocumentSnapshot requestDoc) async {
    await requestDoc.reference.update({'status': 'rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vip_requests').where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading requests', style: TextStyle(color: Colors.white)));
          }
          
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No pending VIP requests.', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return Card(
                color: AppColors.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User Email: ${data['userEmail'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Plan: ${data['planId']} | Method: ${data['paymentMethod']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('TrxID: ${data['trxId']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _rejectRequest(doc),
                            child: const Text('Reject', style: TextStyle(color: Colors.redAccent)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _approveRequest(context, doc),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Approve'),
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
