import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'auth_controller.dart';

/// GetX controller managing user expense state, Firestore synchronization, and analytics metrics.
class ExpenseController extends GetxController {
  final StorageService _storageService;

  ExpenseController({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // Available categories
  final List<String> categories = const [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  // Observable reactive state
  final expenses = <ExpenseModel>[].obs;
  final categorySummaries = <CategoryModel>[].obs;
  final totalMonthlySpent = 0.0.obs;
  final lastMonthComparison = 'Overview for current month'.obs;

  // Analytics reactive state (calculated from user's real Firestore expenses)
  final selectedAnalyticsMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;
  final monthlySpendingTotal = 0.0.obs;
  final monthlyBudget = 15000.0.obs;
  final monthlyBudgetPercent = 0.0.obs;
  final topCategoryName = ''.obs;
  final topCategoryAmount = 0.0.obs;
  final topCategoryPercentage = 0.0.obs;
  final weeklySpendingTotal = 0.0.obs;
  final weeklyDailyAverage = 0.0.obs;
  final weeklyDailyAmounts = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  final categoryBreakdownList = <CategoryBreakdownItem>[].obs;

  // Form selection state
  final selectedCategory = 'Food'.obs;
  final selectedDate = DateTime.now().obs;

  // Loading and Error states
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  StreamSubscription<List<ExpenseModel>>? _expenseSubscription;

  @override
  void onInit() {
    super.onInit();
    // Calculate initial dashboard categories
    _calculateDashboardMetrics();
    // Start listening to expenses when controller initializes
    initExpensesListener();
  }

  @override
  void onClose() {
    _expenseSubscription?.cancel();
    super.onClose();
  }

  /// Sets up real-time listener for current user's expenses
  void initExpensesListener() {
    final AuthController authController = Get.find<AuthController>();

    // Listen to all reactive auth state changes
    ever(authController.firebaseUser, (user) {
      debugPrint('[ExpenseController] Auth state changed: user=${user?.uid}');
      if (user != null && user.uid.isNotEmpty) {
        _bindExpensesStream(user.uid);
      } else {
        _expenseSubscription?.cancel();
        expenses.clear();
        _calculateDashboardMetrics();
      }
    });

    // If a user is already authenticated on launch, bind stream immediately
    final uid = authController.currentUserId;
    if (uid.isNotEmpty) {
      _bindExpensesStream(uid);
    }
  }

  void _bindExpensesStream(String userId) {
    _expenseSubscription?.cancel();
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      debugPrint('[ExpenseController] Binding expenses stream for UID: $userId');
      _expenseSubscription = _storageService.streamUserExpenses(userId).listen(
        (data) {
          debugPrint('[ExpenseController] Received ${data.length} expenses for UID: $userId');
          expenses.assignAll(data);
          _calculateDashboardMetrics();
          isLoading.value = false;
          hasError.value = false;
        },
        onError: (error, stack) {
          debugPrint('[ExpenseController] Stream error: $error\n$stack');
          hasError.value = true;
          if (error is FirebaseException) {
            errorMessage.value = 'Firestore error [${error.code}]: ${error.message}';
          } else {
            errorMessage.value = 'Error: $error';
          }
          isLoading.value = false;
        },
      );
    } catch (e, stack) {
      debugPrint('[ExpenseController] Failed to bind stream: $e\n$stack');
      hasError.value = true;
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  /// Public calculation method to recalculate metrics when expenses are updated.
  void calculateDashboardMetrics() {
    _calculateDashboardMetrics();
  }

  /// Calculates total monthly spending and category breakdown from the user's expenses
  void _calculateDashboardMetrics() {
    final now = DateTime.now();

    // Filter current month expenses
    final currentMonthExpenses = expenses.where((item) {
      return item.date.year == now.year && item.date.month == now.month;
    }).toList();

    // 1. Total Monthly Spend
    final total = currentMonthExpenses.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );
    totalMonthlySpent.value = total;

    // 2. Category totals for dashboard
    final defaultBudgets = {
      'Food': 5000.0,
      'Transport': 3000.0,
      'Shopping': 6000.0,
      'Entertainment': 4000.0,
    };

    final mainDashboardCategories = ['Food', 'Transport', 'Shopping', 'Entertainment'];
    final List<CategoryModel> summaries = [];

    for (final catName in mainDashboardCategories) {
      final catTotal = currentMonthExpenses
          .where((item) => item.category.toLowerCase() == catName.toLowerCase())
          .fold<double>(0.0, (sum, item) => sum + item.amount);

      final icon = _getCategoryIcon(catName);
      final color = _getCategoryColor(catName);
      final budget = defaultBudgets[catName] ?? 4000.0;

      summaries.add(
        CategoryModel(
          name: catName,
          amount: catTotal,
          budget: budget,
          icon: icon,
          color: color,
        ),
      );
    }

    categorySummaries.assignAll(summaries);
    lastMonthComparison.value = 'Tracked across ${currentMonthExpenses.length} transactions';

    // Synchronize analytics metrics from real user expenses
    _calculateAnalyticsMetrics();
  }

  /// Calculates analytics and trends metrics strictly from real user-scoped Firestore expenses.
  void _calculateAnalyticsMetrics() {
    final targetMonth = selectedAnalyticsMonth.value;

    // 1. Filter expenses for the currently selected month
    final monthExpenses = expenses.where((exp) {
      return exp.date.year == targetMonth.year && exp.date.month == targetMonth.month;
    }).toList();

    final monthTotal = monthExpenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);
    monthlySpendingTotal.value = monthTotal;

    final budget = monthlyBudget.value;
    monthlyBudgetPercent.value = budget > 0 ? (monthTotal / budget).clamp(0.0, 1.0) : 0.0;

    // 2. Highest Spending Category for selected month
    final Map<String, double> categoryTotals = {};
    for (final exp in monthExpenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    if (categoryTotals.isNotEmpty && monthTotal > 0) {
      var highestCategory = '';
      var highestAmount = 0.0;
      categoryTotals.forEach((cat, amt) {
        if (amt > highestAmount) {
          highestAmount = amt;
          highestCategory = cat;
        }
      });
      topCategoryName.value = highestCategory;
      topCategoryAmount.value = highestAmount;
      topCategoryPercentage.value = (highestAmount / monthTotal) * 100;
    } else {
      topCategoryName.value = '';
      topCategoryAmount.value = 0.0;
      topCategoryPercentage.value = 0.0;
    }

    // 3. Category Breakdown List sorted descending
    final breakdown = <CategoryBreakdownItem>[];
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final pct = monthTotal > 0 ? (entry.value / monthTotal) * 100 : 0.0;
      breakdown.add(CategoryBreakdownItem(
        name: entry.key,
        amount: entry.value,
        percentage: pct,
        color: _getCategoryColor(entry.key),
      ));
    }
    categoryBreakdownList.assignAll(breakdown);

    // 4. Weekly Spending Summary (calculated from the current week: Monday to Sunday)
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));

    final weekExpenses = expenses.where((exp) {
      return (exp.date.isAfter(startOfWeek) || exp.date.isAtSameMomentAs(startOfWeek)) &&
             (exp.date.isBefore(endOfWeek) || exp.date.isAtSameMomentAs(endOfWeek));
    }).toList();

    final weekTotal = weekExpenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);
    weeklySpendingTotal.value = weekTotal;
    weeklyDailyAverage.value = weekTotal / 7.0;

    // Daily amounts for Monday(0) through Sunday(6)
    final daily = List<double>.filled(7, 0.0);
    for (final exp in weekExpenses) {
      final dayIdx = exp.date.weekday - 1; // 1-7 mapped to 0-6
      if (dayIdx >= 0 && dayIdx < 7) {
        daily[dayIdx] += exp.amount;
      }
    }
    weeklyDailyAmounts.assignAll(daily);
  }

  void previousAnalyticsMonth() {
    final current = selectedAnalyticsMonth.value;
    selectedAnalyticsMonth.value = DateTime(current.year, current.month - 1);
    _calculateAnalyticsMetrics();
  }

  void nextAnalyticsMonth() {
    final current = selectedAnalyticsMonth.value;
    selectedAnalyticsMonth.value = DateTime(current.year, current.month + 1);
    _calculateAnalyticsMetrics();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_subway_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_filter_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFF97316);
      case 'transport':
        return const Color(0xFF3B82F6);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'entertainment':
        return const Color(0xFF8B5CF6);
      case 'bills':
        return const Color(0xFF0D9488);
      case 'health':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  /// Adds a new expense to Firestore tied to the authenticated user.
  Future<void> addExpense({
    required double amount,
    required String category,
    required String note,
    required DateTime date,
  }) async {
    final AuthController auth = Get.find<AuthController>();
    final uid = auth.currentUserId;

    if (uid.isEmpty) {
      Get.snackbar(
        'Authentication Error',
        'Please sign in to save expenses.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[ExpenseController.addExpense] Adding ₹$amount to $category for UID: $uid');

      final newExpense = ExpenseModel(
        id: '',
        userId: uid,
        note: note.isEmpty ? '$category Expense' : note,
        category: category,
        amount: amount,
        date: date,
      );

      final created = await _storageService.addExpense(newExpense);

      // Prepend locally for immediate UI reactivity
      expenses.removeWhere((item) => item.id == created.id);
      expenses.insert(0, created);
      _calculateDashboardMetrics();

      isLoading.value = false;
      Get.back();

      Get.snackbar(
        'Expense Added',
        'Saved ₹${amount.toStringAsFixed(0)} to your spending history.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
      );
    } catch (e, stack) {
      debugPrint('[ExpenseController.addExpense] Error: $e\n$stack');
      isLoading.value = false;
      Get.snackbar(
        'Save Error',
        e is FirebaseException ? '[${e.code}] ${e.message}' : 'Could not save expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Updates an existing expense in Firestore and refreshes local observable state.
  Future<void> updateExpense({
    required String expenseId,
    required double amount,
    required String category,
    required String note,
    required DateTime date,
  }) async {
    final AuthController auth = Get.find<AuthController>();
    final uid = auth.currentUserId;

    try {
      isLoading.value = true;
      debugPrint('[ExpenseController.updateExpense] Updating doc $expenseId for UID: $uid');

      final updated = ExpenseModel(
        id: expenseId,
        userId: uid,
        note: note.isEmpty ? '$category Expense' : note,
        category: category,
        amount: amount,
        date: date,
      );

      await _storageService.updateExpense(updated);

      final index = expenses.indexWhere((item) => item.id == expenseId);
      if (index != -1) {
        expenses[index] = updated;
        _calculateDashboardMetrics();
      }

      isLoading.value = false;
      Get.back();

      Get.snackbar(
        'Expense Updated',
        'Expense details updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
      );
    } catch (e, stack) {
      debugPrint('[ExpenseController.updateExpense] Error: $e\n$stack');
      isLoading.value = false;
      Get.snackbar(
        'Update Failed',
        e is FirebaseException ? '[${e.code}] ${e.message}' : 'Could not update expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Deletes an expense from Firestore with immediate local update.
  Future<void> deleteExpense(String expenseId) async {
    try {
      debugPrint('[ExpenseController.deleteExpense] Deleting doc $expenseId');
      await _storageService.deleteExpense(expenseId);
      expenses.removeWhere((item) => item.id == expenseId);
      _calculateDashboardMetrics();

      Get.snackbar(
        'Expense Deleted',
        'The expense item was removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e, stack) {
      debugPrint('[ExpenseController.deleteExpense] Error: $e\n$stack');
      Get.snackbar(
        'Delete Failed',
        e is FirebaseException ? '[${e.code}] ${e.message}' : 'Could not delete expense: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}

/// Represents an aggregated category row in the analytics breakdown.
class CategoryBreakdownItem {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  const CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

