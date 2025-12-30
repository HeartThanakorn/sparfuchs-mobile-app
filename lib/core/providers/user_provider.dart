import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// StreamProvider for currently authenticated user
/// Emits null when user is signed out, otherwise emits the User object
final userProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Provider for checking if user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Provider for current user's UID (nullable)
final userIdProvider = Provider<String?>((ref) {
  final asyncUser = ref.watch(userProvider);
  return asyncUser.maybeWhen(
    data: (user) => user?.uid,
    orElse: () => null,
  );
});
