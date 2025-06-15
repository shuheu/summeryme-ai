import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('User signed in: ${userCredential.user?.email}');
      }

      // バックエンドに認証情報を送信してユーザーを作成または取得
      if (userCredential.user != null) {
        await _authenticateWithBackend(userCredential.user!);
      }

      return userCredential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  // バックエンドに認証情報を送信
  Future<void> _authenticateWithBackend(User user) async {
    try {
      final result = await ApiService.authenticateUser(
        uid: user.uid,
        name: user.displayName ?? 'Unknown User',
      );

      if (result != null) {
        if (kDebugMode) {
          print('User authenticated with backend: ${result['user']}');
        }
      } else {
        if (kDebugMode) {
          print('Failed to authenticate user with backend');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error authenticating with backend: $e');
      }
      // バックエンド認証エラーはサイレントに処理（Firebase認証は成功しているため）
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate before deleting
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await user.reauthenticateWithCredential(credential);
          await user.delete();
          await _googleSignIn.signOut();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e');
      }
      rethrow;
    }
  }
}
