import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// GetX controller managing Firebase Authentication and user session states.
class AuthController extends GetxController {
  final FirebaseAuth? _customAuth;
  final StorageService _storageService;

  AuthController({
    FirebaseAuth? auth,
    StorageService? storageService,
  })  : _customAuth = auth,
        _storageService = storageService ?? StorageService();

  bool get isFirebaseAvailable => _storageService.isFirebaseAvailable;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    if (isFirebaseAvailable) {
      return FirebaseAuth.instance;
    }
    return null;
  }

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;
  final Rxn<User> firebaseUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Bind reactive auth state stream when Firebase is initialized
    try {
      final auth = _auth;
      if (auth != null) {
        firebaseUser.bindStream(auth.authStateChanges());
      }
    } catch (e) {
      debugPrint('[AuthController.onInit] Notice: $e');
    }
  }

  bool get isAuthenticated => _auth?.currentUser != null;
  String get currentUserId => _auth?.currentUser?.uid ?? '';
  String get userDisplayName =>
      _auth?.currentUser?.displayName?.isNotEmpty == true
          ? _auth!.currentUser!.displayName!
          : 'SpendWise User';
  String get userEmail => _auth?.currentUser?.email ?? '';

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  /// Authenticates an existing user via Firebase Authentication.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      Get.snackbar(
        'Firebase Setup Needed',
        'Firebase is not yet configured. Please add your configuration to authenticate.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.info_outline, color: AppTheme.warning),
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[AuthController.login] Attempting login for email: $email');

      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      isLoading.value = false;
      debugPrint('[AuthController.login] Login successful for UID: ${auth.currentUser?.uid}');

      // Navigate to Home upon success
      Get.offAllNamed(AppRoutes.home);

      Get.snackbar(
        'Welcome Back!',
        'Signed in successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController.login] FirebaseAuthException [${e.code}]: ${e.message}');
      isLoading.value = false;
      _showFriendlyAuthError(e);
    } catch (e, stack) {
      debugPrint('[AuthController.login] Unexpected error: $e\n$stack');
      isLoading.value = false;
      Get.snackbar(
        'Sign In Failed',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Registers a new user with email/password and stores their profile in Firestore.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      Get.snackbar(
        'Firebase Setup Needed',
        'Firebase is not yet configured. Please add your configuration to register.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.info_outline, color: AppTheme.warning),
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[AuthController.register] Attempting createUserWithEmailAndPassword: $email');

      // 1. Create Firebase Auth user
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      debugPrint('[AuthController.register] Created user in Firebase Auth. UID: ${user?.uid}');

      if (user != null) {
        // Update display name
        try {
          await user.updateDisplayName(name.trim());
          debugPrint('[AuthController.register] Display name updated: $name');
        } catch (e) {
          debugPrint('[AuthController.register] updateDisplayName notice: $e');
        }

        // 2. Store user profile in Cloud Firestore: users/{uid}
        try {
          await _storageService.createUserProfile(
            uid: user.uid,
            name: name.trim(),
            email: email.trim(),
          );
        } catch (e, stack) {
          debugPrint('[AuthController.register] Firestore createUserProfile failed: $e\n$stack');
          // Notice: We don't abort since Auth user is already created, but we inform developer/user
        }
      }

      isLoading.value = false;

      // 3. Navigate to Home
      Get.offAllNamed(AppRoutes.home);

      // 4. Success snackbar
      Get.snackbar(
        'Account Created',
        'Welcome to SpendWise AI, ${name.trim()}!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.verified_user_outlined, color: AppTheme.primary),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController.register] FirebaseAuthException [${e.code}]: ${e.message}');
      isLoading.value = false;
      _showFriendlyAuthError(e);
    } on FirebaseException catch (e) {
      debugPrint('[AuthController.register] FirebaseException [${e.code}]: ${e.message}');
      isLoading.value = false;
      Get.snackbar(
        'Database Notice (${e.code})',
        e.message ?? 'Firestore operation failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e, stack) {
      debugPrint('[AuthController.register] Unexpected error: $e\n$stack');
      isLoading.value = false;
      Get.snackbar(
        'Registration Failed',
        'Could not create account: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Signs the user out from Firebase and routes back to Login.
  Future<void> logout() async {
    try {
      final auth = _auth;
      if (auth != null) {
        debugPrint('[AuthController.logout] Signing out user: ${auth.currentUser?.uid}');
        await auth.signOut();
      }
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Signed Out',
        'You have successfully signed out.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e, stack) {
      debugPrint('[AuthController.logout] Error signing out: $e\n$stack');
      Get.snackbar(
        'Error',
        'Failed to sign out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Maps technical Firebase error codes into friendly user messages.
  void _showFriendlyAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email. Please register.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password. Please verify your credentials.';
        break;
      case 'email-already-in-use':
        message = 'This email address is already registered. Please sign in instead.';
        break;
      case 'weak-password':
        message = 'The password is too weak. Please use at least 6 characters.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled. Please contact support.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again in a few moments.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      default:
        message = e.message ?? 'Authentication failed. Please try again.';
    }

    Get.snackbar(
      'Authentication Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
