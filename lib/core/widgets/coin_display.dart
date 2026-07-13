import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'package:animate_do/animate_do.dart';

class CoinDisplay extends StatelessWidget {
  final int amount;
  final double size;

  const CoinDisplay({
    Key? key,
    required this.amount,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Pulse(
          infinite: true,
          child: Icon(
            Icons.monetization_on,
            color: AppColors.gold,
            size: size,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: GoogleFonts.poppins(
            color: AppColors.gold,
            fontSize: size * 0.75,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
