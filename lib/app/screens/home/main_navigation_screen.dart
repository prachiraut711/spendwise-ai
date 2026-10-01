import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../analytics/analytics_screen.dart';
import '../expenses/expense_history_screen.dart';
import '../profile/profile_screen.dart';
import 'home_screen.dart';

/// Main navigation shell hosting bottom navigation and the floating action button.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are registered
    final NavigationController navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }

    const screens = [
      HomeScreen(),
      ExpenseHistoryScreen(showBackButton: false),
      AnalyticsScreen(showBackButton: false),
      ProfileScreen(showBackButton: false),
    ];

    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: navController.currentIndex.value,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            border: const Border(
              top: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeIndex,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: AppTheme.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline_rounded),
                activeIcon: Icon(Icons.pie_chart_rounded),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'add_expense_fab',
          onPressed: () => Get.toNamed(AppRoutes.addExpense),
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text(
            'Add Expense',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
