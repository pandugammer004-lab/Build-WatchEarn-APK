import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/helpers.dart';
import '../../data/models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Safely get FirebaseAuth instance (not available on web without init)
  FirebaseAuth? get _auth {
    if (kIsWeb) return null;
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get authStateChanges {
    if (kIsWeb || _auth == null) return const Stream.empty();
    return _auth!.authStateChanges();
  }

  User? get currentUser => kIsWeb ? null : _auth?.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) throw Exception('Google Sign-In not available on web preview.');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);
      await _checkAndCreateUserDocument(userCredential.user);
      return userCredential;
    } catch (e) {
      throw Exception(_handleAuthError(e.toString()));
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    if (kIsWeb) throw Exception('Login requires Firebase setup. Use the mobile app.');
    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception(_handleAuthError(e.toString()));
    }
  }

  Future<UserCredential> signUpWithEmail(String name, String email, String password, String? referralCode) async {
    if (kIsWeb) throw Exception('Signup requires Firebase setup. Use the mobile app.');
    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        await _checkAndCreateUserDocument(userCredential.user, name: name, referredBy: referralCode);
      }
      return userCredential;
    } catch (e) {
      throw Exception(_handleAuthError(e.toString()));
    }
  }

  Future<void> _checkAndCreateUserDocument(User? user, {String? name, String? referredBy}) async {
    if (user == null || kIsWeb) return;
    
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser == null) {
      final newUser = UserModel(
        uid: user.uid,
        name: name ?? user.displayName ?? 'User',
        email: user.email ?? '',
        profilePic: user.photoURL ?? '',
        coins: 0,
        totalEarned: 0,
        totalWithdrawn: 0,
        vipPlan: 'free',
        referralCode: Helpers.generateReferralCode(user.uid),
        referredBy: referredBy ?? '',
        totalReferrals: 0,
        streak: 1,
        lastLogin: DateTime.now(),
        videosWatched: 0,
        totalWatchTimeSeconds: 0,
        joinDate: DateTime.now(),
        badges: [],
        favorites: [],
        watchedVideoIds: [],
        notificationsEnabled: true,
        autoplayEnabled: true,
        videoQuality: 'auto',
        dailyVideosWatched: 0,
        dailyAdsWatched: 0,
        dailyShares: 0,
        dailyCategoriesWatched: 0,
        lastDailyReset: DateTime.now(),
        totalSpins: 0,
        totalScratchCards: 0,
        fcmToken: '',
      );
      await _firestoreService.createUser(newUser);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (kIsWeb) throw Exception('Password reset requires Firebase setup.');
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception(_handleAuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) return;
    try {
      await Future.wait([
        _auth!.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception("Error signing out");
    }
  }

  Future<void> deleteAccount() async {
    if (kIsWeb) return;
    try {
      await currentUser?.delete();
    } catch (e) {
      throw Exception(_handleAuthError(e.toString()));
    }
  }

  String _handleAuthError(String error) {
    if (error.contains('user-not-found')) return 'No user found for that email.';
    if (error.contains('wrong-password')) return 'Wrong password provided.';
    if (error.contains('email-already-in-use')) return 'The account already exists for that email.';
    if (error.contains('invalid-email')) return 'The email address is badly formatted.';
    if (error.contains('weak-password')) return 'The password provided is too weak.';
    return 'Authentication failed. Please try again.';
  }
}
