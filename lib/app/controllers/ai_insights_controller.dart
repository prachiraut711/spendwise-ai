import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/ai_insight_model.dart';
import '../services/ai_service.dart';
import 'expense_controller.dart';

/// GetX controller managing AI spending insights state, generation, and error handling.
class AiInsightsController extends GetxController {
  final AiService _aiService;

  AiInsightsController({AiService? aiService})
      : _aiService = aiService ?? AiService();

  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final Rxn<AiInsightModel> insight = Rxn<AiInsightModel>();

  @override
  void onInit() {
    super.onInit();
    // Auto-generate insights if expenses exist and no insight is cached yet
    final expenseController = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : null;

    if (expenseController != null && expenseController.expenses.isNotEmpty) {
      generateInsights();
    }
  }

  /// Extracts user's spending data, calculates local aggregates, and queries Gemini via Firebase AI.
  Future<void> generateInsights() async {
    final ExpenseController expenseController = Get.find<ExpenseController>();
    final allExpenses = expenseController.expenses;

    if (allExpenses.isEmpty) {
      debugPrint('[AiInsightsController] No expenses recorded. Cannot generate insights.');
      insight.value = null;
      hasError.value = false;
      return;
    }

    // Filter current month expenses; if empty, use recent expenses
    final now = DateTime.now();
    var targetExpenses = allExpenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();

    if (targetExpenses.isEmpty) {
      targetExpenses = allExpenses.take(15).toList();
    }

    // 1. Calculate local spending aggregates
    final totalSpending = targetExpenses.fold<double>(
      0.0,
      (sum, item) => sum + item.amount,
    );

    final expenseCount = targetExpenses.length;
    final averageExpense = expenseCount > 0 ? totalSpending / expenseCount : 0.0;

    // Calculate category totals
    final Map<String, double> categoryTotals = {};
    for (final exp in targetExpenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    // Find top category
    String topCategory = 'Other';
    double topCategoryAmount = 0.0;
    categoryTotals.forEach((category, amount) {
      if (amount > topCategoryAmount) {
        topCategoryAmount = amount;
        topCategory = category;
      }
    });

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      debugPrint('[AiInsightsController] Calling AiService with local spending summary...');
      final result = await _aiService.generateSpendingInsights(
        totalSpending: totalSpending,
        expenseCount: expenseCount,
        categoryTotals: categoryTotals,
        topCategory: topCategory,
        topCategoryAmount: topCategoryAmount,
        averageExpense: averageExpense,
      );

      insight.value = result;
      isLoading.value = false;
      hasError.value = false;
      debugPrint('[AiInsightsController] Successfully loaded insights.');
    } catch (e, stack) {
      debugPrint('[AiInsightsController] Firebase AI Error: $e\n$stack');
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'Unable to generate insights right now. Please try again.';
    }
  }
}
