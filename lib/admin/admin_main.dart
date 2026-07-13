import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_app.dart';
import 'admin_provider.dart';
import '../theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Note: Firebase initialization will go here
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const AdminMain());
}

class AdminMain extends StatelessWidget {
  const AdminMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'WatchEarn Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AdminApp(),
      ),
    );
  }
}
