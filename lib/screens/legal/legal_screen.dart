import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Note: In a real project, uncomment and add webview_flutter package
// import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

class LegalScreen extends StatefulWidget {
  final String title;
  final String url;

  const LegalScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool _isLoading = true;
  // late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // _controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(AppColors.background)
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onPageFinished: (String url) {
    //         setState(() => _isLoading = false);
    //       },
    //     ),
    //   )
    //   ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share link
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebViewWidget(controller: _controller),
          const Center(child: Text('WebView Placeholder\nRequires webview_flutter package', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
          // if (_isLoading)
          //   const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
