import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/expense_list_tile.dart';
import '../../widgets/spending_category_card.dart';

/// Main Dashboard screen with spending summaries, categories, charts, and AI insight card.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.find<ExpenseController>();
    final NavigationController navigationController = Get.find<NavigationController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceMd,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              _buildHeader(),
              const SizedBox(height: AppTheme.spaceLg),

              // 2. Total Spending Card
              _buildTotalSpendingCard(expenseController),
              const SizedBox(height: AppTheme.spaceLg),

              // 3. AI Spending Insight Card
              _buildAiInsightCard(),
              const SizedBox(height: AppTheme.spaceLg),

              // 4. Categories Section
              _buildSectionTitle(
                title: 'Spending Categories',
                actionText: 'View All',
                onAction: () => navigationController.changeIndex(1),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _buildCategoryGrid(expenseController),
              const SizedBox(height: AppTheme.spaceLg),

              // 5. Spending Overview Section with Placeholder Chart
              _buildSectionTitle(
                title: 'Spending Overview',
                actionText: 'Analytics',
                onAction: () => navigationController.changeIndex(2),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              _buildChartPlaceholderCard(),
              const SizedBox(height: AppTheme.spaceLg),

              // 6. Recent Transactions Section
              _buildSectionTitle(
                title: 'Recent Transactions',
                actionText: 'See All',
                onAction: () => navigationController.changeIndex(1),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Obx(() {
                final recent = expenseController.expenses.take(3).toList();
                if (recent.isEmpty) {
                  return CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 36,
                            color: AppTheme.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No expenses recorded yet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap + Add Expense below to record your first transaction.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: recent
                      .map(
                        (exp) => ExpenseListTile(
                          expense: exp,
                          onEdit: () => Get.toNamed(AppRoutes.addExpense, arguments: exp),
                        ),
                      )
                      .toList(),
                );
              }),
              const SizedBox(height: 80), // Padding for floating action button
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildHeader() {
    final AuthController authController = Get.find<AuthController>();
    final userName = authController.userDisplayName.split(' ').first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty && userName != 'SpendWise'
                    ? 'Good Morning, $userName 👋'
                    : 'Good Morning 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                "Here's your spending overview",
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.textPrimary,
              size: 22,
            ),
            onPressed: () {
              Get.snackbar(
                'Notifications',
                'No new unread spending notifications.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSpendingCard(ExpenseController controller) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.aiGlowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              '₹${controller.totalMonthlySpent.value.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 14,
                  color: Color(0xFF34D399),
                ),
                const SizedBox(width: 4),
                Obx(
                  () => Text(
                    controller.lastMonthComparison.value,
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return CustomCard(
      backgroundColor: const Color(0xFFF0FDFA),
      border: Border.all(color: const Color(0xFF99F6E4), width: 1.2),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '✨ AI Spending Insight',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Your AI-powered spending analysis will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF115E59),
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.aiInsights),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('View Insights'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(ExpenseController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // 4 columns on tablets/desktops (>640px) and 2 columns on mobile
        final int crossAxisCount = width > 640 ? 4 : 2;
        final double horizontalSpacing = 12.0 * (crossAxisCount - 1);
        final double itemWidth = (width - horizontalSpacing) / crossAxisCount;

        // Target height of ~120px gives a compact, balanced fintech card
        // without excessive empty space on desktop or RenderFlex overflow on mobile.
        final double childAspectRatio = (itemWidth / 120.0).clamp(1.15, 1.8);

        return Obx(() {
          final categories = controller.categorySummaries;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return SpendingCategoryCard(category: category);
            },
          );
        });
      },
    );
  }

  Widget _buildChartPlaceholderCard() {
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Trajectory',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'Oct 1 - Oct 31',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          // Styled placeholder bars with smooth gradients
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar(height: 32, label: 'W1'),
                _buildBar(height: 58, label: 'W2'),
                _buildBar(height: 45, label: 'W3'),
                _buildBar(height: 72, label: 'W4', isActive: true),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Center(
            child: Text(
              'Spending overview chart area (fl_chart ready)',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double height, required String label, bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
