import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../utils/helpers.dart';

class UpdateDialog extends StatelessWidget {
  final bool isForced;

  const UpdateDialog({Key? key, this.isForced = false}) : super(key: key);

  static void show(BuildContext context, {bool isForced = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isForced,
      builder: (_) => UpdateDialog(isForced: isForced),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isForced,
      child: Dialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.system_update, color: AppColors.primary, size: 60),
              const SizedBox(height: 16),
              Text(
                'Update Available',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'A new version of WatchEarn is available. Please update to get the latest features and bug fixes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Helpers.openUrl('https://play.google.com/store/apps/details?id=com.watchearn.app');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (!isForced)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later', style: TextStyle(color: Colors.white54)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
