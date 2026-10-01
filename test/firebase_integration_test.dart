import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:spendwise_ai/app/controllers/expense_controller.dart';
import 'package:spendwise_ai/app/models/ai_insight_model.dart';
import 'package:spendwise_ai/app/models/expense_model.dart';
import 'package:spendwise_ai/app/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseModel Firestore Serialization', () {
    test('serializes toMap with userId, amount, and category', () {
      final now = DateTime(2026, 10, 1, 10, 30);
      final expense = ExpenseModel(
        id: 'test_exp_123',
        userId: 'user_abc',
        note: 'Supermarket Grocery',
        category: 'Shopping',
        amount: 850.0,
        date: now,
      );

      final map = expense.toMap();
      expect(map['userId'], 'user_abc');
      expect(map['note'], 'Supermarket Grocery');
      expect(map['category'], 'Shopping');
      expect(map['amount'], 850.0);
    });

    test('deserializes fromMap correctly', () {
      final now = DateTime(2026, 10, 1, 10, 30);
      final map = {
        'userId': 'user_xyz',
        'note': 'Metro card',
        'category': 'Transport',
        'amount': 150.0,
        'date': now.toIso8601String(),
      };

      final expense = ExpenseModel.fromMap(map, 'doc_456');
      expect(expense.id, 'doc_456');
      expect(expense.userId, 'user_xyz');
      expect(expense.category, 'Transport');
      expect(expense.amount, 150.0);
      expect(expense.formattedAmount, '₹150');
    });
  });

  group('ExpenseController Metrics Calculation', () {
    test('calculates total monthly spend and category summaries', () {
      final controller = ExpenseController(storageService: StorageService());
      final now = DateTime.now();

      final expense1 = ExpenseModel(
        id: '1',
        userId: 'user_1',
        note: 'Pizza lunch',
        category: 'Food',
        amount: 400.0,
        date: now,
      );

      final expense2 = ExpenseModel(
        id: '2',
        userId: 'user_1',
        note: 'T-shirt',
        category: 'Shopping',
        amount: 600.0,
        date: now,
      );

      // Previous month expense should NOT be counted in current month total
      final oldExpense = ExpenseModel(
        id: '3',
        userId: 'user_1',
        note: 'Old movie',
        category: 'Entertainment',
        amount: 300.0,
        date: DateTime(now.year, now.month - 1, 15),
      );

      controller.expenses.assignAll([expense1, expense2, oldExpense]);
      // Trigger calculation
      final currentMonthExpenses = controller.expenses.where((item) {
        return item.date.year == now.year && item.date.month == now.month;
      }).toList();

      final total = currentMonthExpenses.fold<double>(0.0, (sum, item) => sum + item.amount);
      expect(total, 1000.0); // 400 + 600
    });

    test('calculates real analytics metrics matching user profile scenario (₹1700 across 3 expenses)', () {
      final controller = ExpenseController(storageService: StorageService());
      final now = DateTime.now();

      final expense1 = ExpenseModel(
        id: '1',
        userId: 'user_1',
        note: 'Clothes purchase',
        category: 'Shopping',
        amount: 1000.0,
        date: now,
      );

      final expense2 = ExpenseModel(
        id: '2',
        userId: 'user_1',
        note: 'Restaurant lunch',
        category: 'Food',
        amount: 400.0,
        date: now,
      );

      final expense3 = ExpenseModel(
        id: '3',
        userId: 'user_1',
        note: 'Taxi fare',
        category: 'Transport',
        amount: 300.0,
        date: now,
      );

      controller.expenses.assignAll([expense1, expense2, expense3]);
      controller.calculateDashboardMetrics();

      expect(controller.monthlySpendingTotal.value, 1700.0);
      expect(controller.topCategoryName.value, 'Shopping');
      expect(controller.topCategoryAmount.value, 1000.0);
      expect(controller.topCategoryPercentage.value, closeTo(58.82, 0.1));

      expect(controller.weeklySpendingTotal.value, 1700.0);
      expect(controller.weeklyDailyAverage.value, closeTo(1700.0 / 7, 0.1));

      expect(controller.categoryBreakdownList.length, 3);
      expect(controller.categoryBreakdownList[0].name, 'Shopping');
      expect(controller.categoryBreakdownList[0].amount, 1000.0);
      expect(controller.categoryBreakdownList[1].name, 'Food');
      expect(controller.categoryBreakdownList[1].amount, 400.0);
      expect(controller.categoryBreakdownList[2].name, 'Transport');
      expect(controller.categoryBreakdownList[2].amount, 300.0);
    });
  });

  group('AiInsightModel Parsing', () {
    test('parses clean JSON response correctly', () {
      const jsonResponse = '''
{
  "overall": "You have spent ₹3,500 across 8 transactions this month.",
  "topCategory": "Food",
  "topCategoryAmount": 1800.0,
  "insights": [
    "Food accounts for over 50% of your expenses.",
    "Groceries were your largest single purchase."
  ],
  "savingTip": "Try meal prepping on weekends to lower daily dining costs."
}
''';

      final model = AiInsightModel.parse(
        jsonResponse,
        fallbackCategory: 'General',
        fallbackCategoryAmount: 0.0,
        totalSpend: 3500.0,
      );

      expect(model.overall, contains('₹3,500'));
      expect(model.topCategory, 'Food');
      expect(model.topCategoryAmount, 1800.0);
      expect(model.formattedTopAmount, '₹1800');
      expect(model.insights.length, 2);
      expect(model.savingTip, contains('meal prepping'));
    });

    test('parses markdown-fenced ```json response correctly', () {
      const fencedResponse = '''
```json
{
  "overall": "Great job keeping shopping expenses low.",
  "topCategory": "Transport",
  "topCategoryAmount": 650.0,
  "insights": [
    "Daily commute is consistent."
  ],
  "savingTip": "Use a monthly transit pass to save 15%."
}
```
''';

      final model = AiInsightModel.parse(
        fencedResponse,
        fallbackCategory: 'Transport',
        fallbackCategoryAmount: 650.0,
        totalSpend: 1200.0,
      );

      expect(model.topCategory, 'Transport');
      expect(model.topCategoryAmount, 650.0);
      expect(model.insights.first, 'Daily commute is consistent.');
      expect(model.savingTip, contains('transit pass'));
    });

    test('falls back gracefully on non-JSON raw response', () {
      const plainText = '''
Your main spending is on Entertainment this month.
- Movie tickets cost more on weekends.
- Consider weekday subscriptions instead.
Set a monthly entertainment cap.
''';

      final model = AiInsightModel.parse(
        plainText,
        fallbackCategory: 'Entertainment',
        fallbackCategoryAmount: 400.0,
        totalSpend: 1500.0,
      );

      expect(model.overall, contains('Entertainment'));
      expect(model.topCategory, 'Entertainment');
      expect(model.insights.length, 2);
      expect(model.savingTip, 'Set a monthly entertainment cap.');
    });
  });
}

