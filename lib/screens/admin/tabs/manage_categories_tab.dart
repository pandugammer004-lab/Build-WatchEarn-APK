import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ManageCategoriesTab extends StatelessWidget {
  const ManageCategoriesTab({Key? key}) : super(key: key);

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final iconCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor,
          title: Text('Add Category', style: GoogleFonts.poppins(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: idCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'ID (e.g. music)', labelStyle: TextStyle(color: Colors.white54))),
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name (e.g. Music)', labelStyle: TextStyle(color: Colors.white54))),
              TextField(controller: iconCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Icon Emoji (e.g. 🎵)', labelStyle: TextStyle(color: Colors.white54))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () async {
                if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty || iconCtrl.text.isEmpty) return;
                
                await FirebaseFirestore.instance.collection('categories').doc(idCtrl.text.toLowerCase().trim()).set({
                  'id': idCtrl.text.toLowerCase().trim(),
                  'name': nameCtrl.text,
                  'icon': iconCtrl.text,
                  'order': 0,
                  'isActive': true,
                });
                
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No custom categories. Default ones are shown to users.', style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                color: AppColors.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Text(data['icon'] ?? '', style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(data['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${data['id']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await docs[index].reference.delete();
                    },
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
