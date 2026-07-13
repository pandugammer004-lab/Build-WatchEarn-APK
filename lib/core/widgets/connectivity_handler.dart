import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConnectivityHandler extends StatefulWidget {
  final Widget child;

  const ConnectivityHandler({Key? key, required this.child}) : super(key: key);

  @override
  State<ConnectivityHandler> createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  // Using dummy logic for connectivity to avoid adding extra packages just for UI demo.
  // In production, use connectivity_plus.
  bool _isConnected = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (!_isConnected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
