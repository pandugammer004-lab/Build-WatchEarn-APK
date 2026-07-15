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
  bool _loadAttempted = false;

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
      if (userProvider.user == null && !userProvider.isLoading && !_loadAttempted) {
        _loadAttempted = true;
        userProvider.loadUser(authProvider.firebaseUser!.uid).then((_) {
          if (userProvider.user == null) {
            authProvider.signOut();
          } else {
            userProvider.loadNotifications();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!authProvider.isLoggedIn) {
      _loadAttempted = false;
    }

    // Also check on build in case auth state changes later
    if (authProvider.isLoggedIn && userProvider.user == null && !userProvider.isLoading && !_loadAttempted) {
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
      
      if (userProvider.user!.isBlocked) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, color: Colors.redAccent, size: 80),
                  const SizedBox(height: 24),
                  const Text('Account Suspended', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Your account has been blocked by the administrator.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => authProvider.signOut(),
                    child: const Text('Logout'),
                  )
                ],
              ),
            ),
          ),
        );
      }
      
      return const MainNavigation();
    } else {
      return const OnboardingScreen();
    }
  }
}
