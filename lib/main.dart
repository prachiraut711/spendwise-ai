import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:get/get.dart';
import 'app/controllers/auth_controller.dart';
import 'app/controllers/expense_controller.dart';
import 'app/controllers/navigation_controller.dart';
import 'app/routes/app_routes.dart';
import 'app/services/storage_service.dart';
import 'app/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before starting the Flutter application
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaEnterpriseProvider('recaptcha-debug-provider'),
        androidProvider: AndroidProvider.debug,
      );
      debugPrint('[FirebaseAppCheck] Activated successfully.');
    } catch (e) {
      debugPrint('[FirebaseAppCheck] Initialization notice: $e');
    }


  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }


  // Set system UI overlay style for a clean fintech look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services and core controllers
  Get.put(StorageService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ExpenseController(), permanent: true);
  Get.put(NavigationController(), permanent: true);

  // Simple authentication state check:
  // If user is already authenticated, open main dashboard; otherwise, open Login.
  String initialRoute = AppRoutes.login;
  try {
    if (FirebaseAuth.instance.currentUser != null) {
      initialRoute = AppRoutes.home;
    }
  } catch (_) {
    initialRoute = AppRoutes.login;
  }

  runApp(SpendWiseApp(initialRoute: initialRoute));
}

/// SpendWise AI Root Application configured with GetX and Firebase-aware routing.
class SpendWiseApp extends StatelessWidget {
  final String initialRoute;

  const SpendWiseApp({
    super.key,
    this.initialRoute = AppRoutes.login,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController(), permanent: true);
    }
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController(), permanent: true);
    }

    return GetMaterialApp(
      title: 'SpendWise AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}
