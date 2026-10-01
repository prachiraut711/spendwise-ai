import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';

/// Clean fintech analytics screen displaying spending distribution and breakdown from real Firestore data.
class AnalyticsScreen extends StatelessWidget {
  final bool showBackButton;

  const AnalyticsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.isRegistered<ExpenseController>()
        ? Get.find<ExpenseController>()
        : Get.put(ExpenseController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton || Navigator.canPop(context),
        title: const Text('Analytics & Trends'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Monthly Spending Summary Card
                _buildMonthlySummaryCard(controller),
                const SizedBox(height: AppTheme.spaceMd),

                // 2. Highest Spending Category Card
                _buildHighestCategoryCard(controller),
                const SizedBox(height: AppTheme.spaceLg),

                // 3. Weekly Spending Summary
                _buildSectionHeader('Weekly Spending Summary', Icons.bar_chart_rounded),
                const SizedBox(height: AppTheme.spaceSm),
                _buildWeeklySummaryCard(controller),
                const SizedBox(height: AppTheme.spaceLg),

                // 4. Category Breakdown Section
                _buildSectionHeader('Category Breakdown', Icons.pie_chart_rounded),
                const SizedBox(height: AppTheme.spaceSm),
                _buildCategoryBreakdownCard(controller),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryCard(ExpenseController controller) {
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Spending Summary',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Obx(() {
                final monthStr = DateFormat('MMM yyyy')
                    .format(controller.selectedAnalyticsMonth.value);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: controller.previousAnalyticsMonth,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_left_rounded, size: 18, color: AppTheme.primary),
                      ),
                    ),
                    Text(
                      monthStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    InkWell(
                      onTap: controller.nextAnalyticsMonth,
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.primary),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '₹${controller.monthlySpendingTotal.value.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Obx(
            () {
              final pct = (controller.monthlyBudgetPercent.value * 100).toInt();
              final budget = controller.monthlyBudget.value.toStringAsFixed(0);
              return Text(
                '$pct% of your monthly budget (₹$budget) used',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              );
            },
          ),
          const SizedBox(height: AppTheme.spaceMd),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: Obx(
              () => LinearProgressIndicator(
                value: controller.monthlyBudgetPercent.value,
                minHeight: 8,
                backgroundColor: AppTheme.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighestCategoryCard(ExpenseController controller) {
    return Obx(() {
      final topCat = controller.topCategoryName.value;
      final topAmt = controller.topCategoryAmount.value;
      final topPct = controller.topCategoryPercentage.value;
      final hasData = topCat.isNotEmpty && topAmt > 0;

      return CustomCard(
        backgroundColor: const Color(0xFFFDF2F8),
        border: Border.all(color: const Color(0xFFFBCFE8), width: 1.2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEC4899).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFDB2777),
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Highest Spending Category',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9D174D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData ? '$topCat — ₹${topAmt.toStringAsFixed(0)}' : 'No expenses recorded',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF831843),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? 'Represents ${topPct.toStringAsFixed(0)}% of this month’s total spend'
                        : 'Add expenses to see your top category breakdown',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9D174D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeeklySummaryCard(ExpenseController controller) {
    return Obx(() {
      final weekTotal = controller.weeklySpendingTotal.value;
      final weekAvg = controller.weeklyDailyAverage.value;
      final dailyAmounts = controller.weeklyDailyAmounts;

      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week: ₹${weekTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Avg: ₹${weekAvg.toStringAsFixed(0)}/day',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildWeeklyBarChart(dailyAmounts),
            const SizedBox(height: AppTheme.spaceMd),
            Center(
              child: Text(
                weekTotal > 0
                    ? 'Calculated from your current week transactions'
                    : 'No transactions recorded for the current week',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWeeklyBarChart(List<double> dailyAmounts) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxAmount = dailyAmounts.fold<double>(0.0, (max, amt) => amt > max ? amt : max);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final amount = i < dailyAmounts.length ? dailyAmounts[i] : 0.0;
        final isHighest = maxAmount > 0 && amount == maxAmount;
        final double barHeight = maxAmount > 0
            ? 8.0 + ((amount / maxAmount) * 82.0)
            : 8.0;

        return Column(
          children: [
            if (amount > 0)
              Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isHighest ? AppTheme.primary : AppTheme.textSecondary,
                ),
              )
            else
              const SizedBox(height: 12),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: barHeight,
              decoration: BoxDecoration(
                color: isHighest
                    ? AppTheme.primary
                    : (amount > 0 ? AppTheme.primary.withOpacity(0.35) : AppTheme.divider),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighest ? FontWeight.w700 : FontWeight.w500,
                color: isHighest ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryBreakdownCard(ExpenseController controller) {
    return Obx(() {
      final items = controller.categoryBreakdownList;
      final total = controller.monthlySpendingTotal.value;

      return CustomCard(
        child: Column(
          children: [
            _buildPieChart(total, items),
            const SizedBox(height: AppTheme.spaceMd),
            const Divider(),
            const SizedBox(height: AppTheme.spaceSm),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No expenses recorded for this month',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              ...items.map(
                (item) => _buildBreakdownRow(
                  item.name,
                  '₹${item.amount.toStringAsFixed(0)}',
                  '${item.percentage.toStringAsFixed(0)}%',
                  item.color,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPieChart(double total, List<CategoryBreakdownItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: items.isNotEmpty ? items.first.color : AppTheme.primary,
                width: 14,
              ),
              color: AppTheme.background,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pie_chart_outline, size: 28, color: AppTheme.primary),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            items.isNotEmpty
                ? '${items.length} categories active this month'
                : 'No category distribution to show',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String name, String amount, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
