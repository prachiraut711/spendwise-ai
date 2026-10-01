import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/expense_controller.dart';
import '../../models/expense_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/expense_list_tile.dart';

/// Visually polished Expense History screen connected to Cloud Firestore.
class ExpenseHistoryScreen extends StatefulWidget {
  final bool showBackButton;

  const ExpenseHistoryScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ExpenseHistoryScreen> createState() => _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  String _selectedCategoryFilter = 'All';

  void _showFilterModal(BuildContext context, ExpenseController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'All',
                  ...controller.categories,
                ].map((category) {
                  final isSelected = category == _selectedCategoryFilter;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategoryFilter = category;
                      });
                      Navigator.pop(context);
                    },
                    selectedColor: AppTheme.primaryLight,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryDark : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ExpenseModel expense, ExpenseController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete "${expense.note}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteExpense(expense.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseController expenseController = Get.find<ExpenseController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton || Navigator.canPop(context),
        title: const Text('Expense History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Search expenses',
            onPressed: () {
              Get.snackbar(
                'Search',
                'Search across your Firestore expenses.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter categories',
            onPressed: () => _showFilterModal(context, expenseController),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            // 1. Loading State
            if (expenseController.isLoading.value && expenseController.expenses.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      'Loading your expenses...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 2. Error State
            if (expenseController.hasError.value && expenseController.expenses.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppTheme.error,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Something went wrong. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: expenseController.initExpensesListener,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Filter items based on selected category
            final allItems = expenseController.expenses;
            final items = _selectedCategoryFilter == 'All'
                ? allItems
                : allItems
                    .where((e) =>
                        e.category.toLowerCase() ==
                        _selectedCategoryFilter.toLowerCase())
                    .toList();

            // 3. Empty State
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppTheme.textMuted.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      const Text(
                        'No expenses yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add your first expense to start tracking your spending.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 4. Populated List with Edit and Delete
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceMd,
                    vertical: AppTheme.spaceSm,
                  ),
                  itemCount: items.length + (_selectedCategoryFilter != 'All' ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_selectedCategoryFilter != 'All' && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Filtered by: $_selectedCategoryFilter',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryFilter = 'All';
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppTheme.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final itemIndex = _selectedCategoryFilter != 'All' ? index - 1 : index;
                    final expense = items[itemIndex];
                    return ExpenseListTile(
                      expense: expense,
                      onEdit: () {
                        Get.toNamed(AppRoutes.addExpense, arguments: expense);
                      },
                      onDelete: () => _confirmDelete(context, expense, expenseController),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
