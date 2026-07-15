import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/user_provider.dart';
import '../home/main_navigation.dart';
import '../onboarding/onboarding_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _checkUser();
      _isInit = true;
    }
  }

  void _checkUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      if (userProvider.user == null && !userProvider.isLoading) {
        userProvider.loadUser(authProvider.firebaseUser!.uid).then((_) {
          userProvider.loadNotifications();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Also check on build in case auth state changes later
    if (authProvider.isLoggedIn && userProvider.user == null && !userProvider.isLoading) {
       Future.microtask(() => _checkUser());
    }

    if (authProvider.isLoggedIn) {
      if (userProvider.isLoading || userProvider.user == null) {
        return const Scaffold(
          backgroundColor: Color(0xFF0D0D1A),
          body: Center(
            child: CircularProgressIndicator(color: Colors.amber),
          ),
        );
      }
      return const MainNavigation();
    } else {
      return const OnboardingScreen();
    }
  }
}
