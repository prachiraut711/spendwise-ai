import 'package:get/get.dart';
import '../screens/ai_insights/ai_insights_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/expenses/add_expense_screen.dart';
import '../screens/expenses/expense_history_screen.dart';
import '../screens/home/main_navigation_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Centralized route definitions for SpendWise AI.
abstract class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const addExpense = '/add-expense';
  static const expenses = '/expenses';
  static const analytics = '/analytics';
  static const aiInsights = '/ai-insights';
  static const profile = '/profile';
}

/// Route bindings and page registrations for GetX.
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.addExpense,
      page: () => const AddExpenseScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.expenses,
      page: () => const ExpenseHistoryScreen(showBackButton: true),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.analytics,
      page: () => const AnalyticsScreen(showBackButton: true),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.aiInsights,
      page: () => const AiInsightsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(showBackButton: true),
      transition: Transition.rightToLeft,
    ),
  ];
}
