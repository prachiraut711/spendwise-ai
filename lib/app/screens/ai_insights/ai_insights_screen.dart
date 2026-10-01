import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_insights_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

/// Screen presenting Gemini-powered spending insights via Firebase AI Logic.
class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AiInsightsController controller = Get.isRegistered<AiInsightsController>()
        ? Get.find<AiInsightsController>()
        : Get.put(AiInsightsController());

    final ExpenseController expenseController = Get.find<ExpenseController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Spending Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Regenerate Insights',
            onPressed: () {
              if (!controller.isLoading.value) {
                controller.generateInsights();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final hasExpenses = expenseController.expenses.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Large Assistant Header Card
              _buildHeaderCard(),
              const SizedBox(height: AppTheme.spaceLg),

              // Empty State (no expenses recorded)
              if (!hasExpenses) ...[
                _buildEmptyState(),
              ]
              // Loading State
              else if (controller.isLoading.value) ...[
                _buildLoadingState(),
              ]
              // Error State
              else if (controller.hasError.value && controller.insight.value == null) ...[
                _buildErrorState(controller),
              ]
              // Populated Insights State
              else if (controller.insight.value != null) ...[
                _buildInsightsContent(controller),
              ]
              // Initial State with Generate Button
              else ...[
                CustomCard(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ready to Analyze Your Spending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap below to send your spending summary to Gemini for automated financial analysis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceLg),
                      CustomButton(
                        text: 'Generate Insights',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: controller.generateInsights,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }),
);
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.aiGlowShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF5EEAD4),
              size: 34,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Text(
            'SpendWise Intelligence',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Powered by Firebase AI Logic & Gemini to provide practical spending insights and saving recommendations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Text(
            'No expenses recorded yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your first expense to generate AI-powered spending insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          CustomButton(
            text: 'Add Expense',
            icon: Icons.add_rounded,
            onPressed: () => Get.toNamed(AppRoutes.addExpense),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const CustomCard(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 20),
            Text(
              'Analyzing your spending patterns...',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Consulting Gemini via Firebase AI Logic',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AiInsightsController controller) {
    return CustomCard(
      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      backgroundColor: const Color(0xFFFEF2F2),
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF991B1B),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          CustomButton(
            text: 'Try Again',
            icon: Icons.refresh_rounded,
            backgroundColor: AppTheme.error,
            onPressed: controller.generateInsights,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent(AiInsightsController controller) {
    final item = controller.insight.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Generate / Regenerate Button
        CustomButton(
          text: 'Regenerate Insights',
          icon: Icons.auto_awesome_rounded,
          isLoading: controller.isLoading.value,
          onPressed: controller.generateInsights,
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // 1. Overall Section
        _buildSectionHeader('Overall', Icons.insights_rounded),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          child: Text(
            item.overall,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // 2. Top Category Section
        _buildSectionHeader('Top Category', Icons.star_rounded),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          backgroundColor: const Color(0xFFF0FDFA),
          border: Border.all(color: const Color(0xFF99F6E4), width: 1.2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Highest Expenditure',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.topCategory} — ${item.formattedTopAmount}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // 3. Insights Section
        _buildSectionHeader('Insights', Icons.lightbulb_outline_rounded),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: item.insights.map((bullet) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•  ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppTheme.spaceLg),

        // 4. Saving Tip Section
        _buildSectionHeader('Saving Tip', Icons.tips_and_updates_rounded),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          backgroundColor: const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💡 ',
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.savingTip,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78350F),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
