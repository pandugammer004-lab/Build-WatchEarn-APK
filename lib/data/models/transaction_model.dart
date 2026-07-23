import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type; // earning/withdrawal/vip_purchase/referral_bonus
  final String source; // video/ad/spin/scratch/mystery/referral/streak/goal/milestone/vip
  final int coins;
  final double amount;
  final String status; // completed/pending/rejected
  final String paymentMethod; // paypal/amazon/google_play/apple/visa
  final String paymentEmail;
  final String description;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.source,
    required this.coins,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.paymentEmail,
    required this.description,
    required this.timestamp,
  });

  String get statusIcon {
    switch (status) {
      case 'completed': return '✅';
      case 'pending': return '⏳';
      case 'rejected': return '❌';
      default: return '❓';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'earning': return '💰';
      case 'withdrawal': return '💸';
      case 'vip_purchase': return '💎';
      case 'referral_bonus': return '👥';
      default: return '🪙';
    }
  }

  String get formattedAmount {
    if (amount > 0) return '\$${amount.toStringAsFixed(2)}';
    return '${coins > 0 ? '+' : ''}$coins';
  }

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 365) return '${difference.inDays ~/ 365}y ago';
    if (difference.inDays > 30) return '${difference.inDays ~/ 30}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  bool get isEarning => coins > 0 || type == 'earning';
  bool get isWithdrawal => type == 'withdrawal';

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    String typeVal = data['type'] ?? 'earning';
    if (typeVal == 'credit') typeVal = 'earning';
    
    int coinsVal = data['coins'] ?? 0;
    double amountVal = (data['amount'] as num?)?.toDouble() ?? 0.0;
    
    // Backward compatibility fallback if coins was 0 but amount was stored as coins integer
    if (coinsVal == 0 && amountVal > 0 && typeVal != 'withdrawal') {
      coinsVal = amountVal.toInt();
      amountVal = 0.0;
    }

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: typeVal,
      source: data['source'] ?? '',
      coins: coinsVal,
      amount: amountVal,
      status: data['status'] ?? 'completed',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentEmail: data['paymentEmail'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'source': source,
      'coins': coins,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentEmail': paymentEmail,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
