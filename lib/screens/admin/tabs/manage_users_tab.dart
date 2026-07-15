import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/helpers.dart';

class ManageUsersTab extends StatefulWidget {
  const ManageUsersTab({Key? key}) : super(key: key);

  @override
  State<ManageUsersTab> createState() => _ManageUsersTabState();
}

class _ManageUsersTabState extends State<ManageUsersTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by email or name...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').orderBy('lastLogin', descending: true).limit(50).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.', style: TextStyle(color: Colors.white)));
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();
                
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown';
                    final email = data['email'] ?? 'No Email';
                    final coins = data['coins'] ?? 0;
                    final isVip = data['vipPlan'] != 'free';
                    final isBlocked = data['isBlocked'] ?? false;
                    final userId = docs[index].id;
                      
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isBlocked ? Colors.red : (isVip ? Colors.amber : Colors.blueGrey),
                        child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(name, style: TextStyle(color: isBlocked ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, decoration: isBlocked ? TextDecoration.lineThrough : null)),
                      subtitle: Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${Helpers.formatCoins(coins)} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                              Text('\$${(coins / 10000).toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 10)),
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white54),
                            color: AppColors.cardColor,
                            onSelected: (value) async {
                              if (value == 'block') {
                                await FirebaseFirestore.instance.collection('users').doc(userId).update({'isBlocked': !isBlocked});
                              } else if (value == 'delete') {
                                // Show confirm dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: AppColors.cardColor,
                                    title: const Text('Delete User', style: TextStyle(color: Colors.white)),
                                    content: Text('Are you sure you want to delete $name?', style: const TextStyle(color: Colors.white70)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('users').doc(userId).delete();
                                          if (context.mounted) Navigator.pop(context);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  )
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'block', child: Text(isBlocked ? 'Unblock User' : 'Block User', style: TextStyle(color: isBlocked ? Colors.green : Colors.orange))),
                              const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
