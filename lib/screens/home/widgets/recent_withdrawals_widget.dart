import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/demo_data_service.dart';

class RecentWithdrawalsWidget extends StatefulWidget {
  const RecentWithdrawalsWidget({Key? key}) : super(key: key);

  @override
  State<RecentWithdrawalsWidget> createState() => _RecentWithdrawalsWidgetState();
}

class _RecentWithdrawalsWidgetState extends State<RecentWithdrawalsWidget> {
  Timer? _rotationTimer;
  List<Map<String, dynamic>> _displayList = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  bool _isInitialized = false;
  List<Map<String, dynamic>> _allWithdrawals = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAndMergeData();
  }

  Future<void> _fetchAndMergeData() async {
    try {
      // 1. Fetch real withdrawals
      final snapshot = await FirebaseFirestore.instance
          .collection('withdrawals')
          .where('status', isEqualTo: 'approved')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> mergedList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = data['amount'] ?? 0.0;
        final email = data['paymentEmail'] ?? 'User';
        final maskedName = email.contains('@') 
            ? '${email.split('@')[0].substring(0, 3)}***' 
            : 'User***';
            
        mergedList.add({
          'id': doc.id,
          'name': maskedName,
          'countryFlag': '🌎',
          'countryName': 'Global',
          'amount': amount.toInt(),
          'method': data['method'] ?? 'Wallet',
          'methodIcon': 'assets/images/usdt.png', // Fallback
          'methodColor': 0xFF26A17B,
          'time': 'Just now',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        });
      }

      // 2. Add demo withdrawals if we don't have enough real ones
      if (mergedList.length < 50) {
        final demoData = DemoDataService.getDemoWithdrawals(50 - mergedList.length);
        mergedList.addAll(demoData);
      }

      // Sort combined
      mergedList.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      
      _allWithdrawals = mergedList;
      
      // Initialize with first 3 items
      for (int i = 0; i < 3 && i < _allWithdrawals.length; i++) {
        _displayList.add(_allWithdrawals[i]);
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _currentIndex = 3;
        });
        
        // Start rotation timer (rotate every 15 seconds)
        _rotationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
          _rotateWithdrawals();
        });
      }
    } catch (e) {
      debugPrint('Error fetching withdrawals: $e');
    }
  }

  void _rotateWithdrawals() {
    if (!mounted || _allWithdrawals.isEmpty || _listKey.currentState == null) return;
    
    // Remove the last item with an exit animation
    final removedItem = _displayList.removeLast();
    _listKey.currentState!.removeItem(
      2, 
      (context, animation) => _buildItem(removedItem, animation),
      duration: const Duration(milliseconds: 500)
    );
    
    // Add a new item at the top with an entrance animation
    final newItem = _allWithdrawals[_currentIndex % _allWithdrawals.length];
    _currentIndex++;
    
    _displayList.insert(0, newItem);
    _listKey.currentState!.insertItem(0, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  Widget _buildItem(Map<String, dynamic> item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                radius: 20,
                child: Text(item['name'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${item['countryFlag']} ${item['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        Text('\$${item['amount']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.white54, size: 12),
                        const SizedBox(width: 4),
                        Text('via ${item['method']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const Spacer(),
                        Text(item['time'], style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Withdrawals',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.sensors, color: Colors.greenAccent, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!_isInitialized)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else if (_displayList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No recent withdrawals.', style: TextStyle(color: Colors.white54)),
          )
        else
          Container(
            height: 250, // Fixed height to prevent shifting layout during animations
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _displayList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index, animation) {
                return _buildItem(_displayList[index], animation);
              },
            ),
          ),
      ],
    );
  }
}
