import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/providers/user_provider.dart';
import '../../core/utils/helpers.dart';
import '../../core/services/firestore_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  int _currentStep = 1;
  double _selectedAmount = 10.0;
  String _selectedMethod = 'PayPal';
  final TextEditingController _detailController = TextEditingController();
  bool _isProcessing = false;

  final List<double> _quickAmounts = [5.0, 10.0, 25.0, 50.0];
  final List<Map<String, dynamic>> _methods = [
    {'id': 'PayPal', 'name': 'PayPal', 'icon': '💳', 'time': 'Instant'},
    {'id': 'Amazon', 'name': 'Amazon Gift Card', 'icon': '🛍️', 'time': 'Email Delivery'},
    {'id': 'GooglePlay', 'name': 'Google Play Credit', 'icon': '🎮', 'time': 'App Credit'},
  ];

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _processWithdrawal();
    }
  }

  void _processWithdrawal() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    final int requiredCoins = (_selectedAmount * 10000).toInt();
    if (user.coins < requiredCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient coin balance for this withdrawal amount!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final paymentDetails = _detailController.text.trim();
      
      // Save withdrawal request to Firestore
      await FirestoreService().createWithdrawal({
        'userId': user.uid,
        'paymentEmail': paymentDetails.isNotEmpty ? paymentDetails : user.email,
        'method': _selectedMethod,
        'amount': _selectedAmount,
        'coinsDeducted': requiredCoins,
        'status': 'pending',
        'timestamp': DateTime.now(),
      });

      // Deduct coins & record transaction
      await userProvider.updateCoins(-requiredCoins, 'Withdrawal ($_selectedMethod)');

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _currentStep = 5; // Success screen
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Withdraw', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.user;
          final balance = user?.coins ?? 0;

          if (_currentStep == 5) return _buildSuccessScreen();

          return Column(
            children: [
              _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_currentStep == 1) _buildStep1(balance),
                      if (_currentStep == 2) _buildStep2(),
                      if (_currentStep == 3) _buildStep3(),
                      if (_currentStep == 4) _buildStep4(balance, user?.isVip ?? false),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 1; i <= 4; i++) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentStep >= i ? AppColors.primary : Colors.white10,
              ),
              child: Center(
                child: Text(
                  i.toString(),
                  style: TextStyle(color: _currentStep >= i ? Colors.white : Colors.white54, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (i < 4)
              Container(
                width: 40,
                height: 2,
                color: _currentStep > i ? AppColors.primary : Colors.white10,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1(int balance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Select Amount', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Balance', style: TextStyle(color: Colors.white70)),
              Text('${Helpers.formatCoins(balance)} 🪙', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '\$${_selectedAmount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            '= ${Helpers.formatCoins((_selectedAmount * 10000).toInt())} coins',
            style: const TextStyle(color: Colors.amber),
          ),
        ),
        const SizedBox(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: _quickAmounts.map((amount) {
            final isSelected = _selectedAmount == amount;
            return GestureDetector(
              onTap: () => setState(() => _selectedAmount = amount),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.white12),
                ),
                child: Center(
                  child: Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Select Method', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ..._methods.map((method) {
          final isSelected = _selectedMethod == method['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = method['id']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                    child: Center(child: Text(method['icon'], style: const TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(method['time'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.primary : Colors.white54,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Enter Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Text('Enter your $_selectedMethod account details', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _detailController,
          hintText: 'Email Address or Account ID',
          prefixIcon: Icons.account_circle,
        ),
      ],
    );
  }

  Widget _buildStep4(int balance, bool isVip) {
    final coinsRequired = (_selectedAmount * 10000).toInt();
    final canAfford = balance >= coinsRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Confirm', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildSummaryRow('Amount', '\$${_selectedAmount.toStringAsFixed(2)}'),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow('Method', _selectedMethod),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow('Details', _detailController.text.isEmpty ? 'Not provided' : _detailController.text),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow('Processing', isVip ? '1 Business Day' : '3-5 Business Days'),
              const Divider(color: Colors.white12, height: 24),
              _buildSummaryRow('Coins to deduct', '${Helpers.formatCoins(coinsRequired)} 🪙', valueColor: Colors.amber),
            ],
          ),
        ),
        if (!canAfford)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Insufficient coin balance', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color valueColor = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 24),
          Text('Withdrawal Submitted!', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'Your \$${_selectedAmount.toStringAsFixed(2)} will arrive\nin 3-5 business days',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            child: const Text('Back to Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 1)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _currentStep == 4 ? 'Confirm Withdrawal' : 'Continue',
                isLoading: _isProcessing,
                onPressed: _currentStep == 3 && _detailController.text.isEmpty ? null : _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
