import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/expense_controller.dart';
import '../../models/expense_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_text_field.dart';

/// Screen allowing the user to input and create a new expense entry.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final ExpenseController _expenseController = Get.find<ExpenseController>();

  ExpenseModel? _existingExpense;
  bool get _isEditMode => _existingExpense != null;

  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _existingExpense = Get.arguments as ExpenseModel?;
    if (_existingExpense != null) {
      _amountController.text = _existingExpense!.amount.toStringAsFixed(0);
      _noteController.text = _existingExpense!.note;
      _selectedCategory = _existingExpense!.category;
      _selectedDate = _existingExpense!.date;
    } else {
      _selectedCategory = _expenseController.selectedCategory.value;
      _selectedDate = _expenseController.selectedDate.value;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      if (_isEditMode) {
        _expenseController.updateExpense(
          expenseId: _existingExpense!.id,
          amount: amount,
          category: _selectedCategory,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );
      } else {
        _expenseController.addExpense(
          amount: amount,
          category: _selectedCategory,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount Input Card
                CustomCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLg,
                    vertical: AppTheme.spaceMd,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Spent',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              autofocus: true,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final parsed = double.tryParse(value.trim());
                                if (parsed == null || parsed <= 0) {
                                  return 'Please enter a valid amount greater than 0';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.category_outlined,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(color: AppTheme.border, width: 1),
                        ),
                      ),
                      items: _expenseController.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Date Selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.border, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceMd),

                // Note Field
                CustomTextField(
                  controller: _noteController,
                  label: 'Note / Description',
                  hintText: 'e.g. Lunch with team, Groceries',
                  prefixIcon: Icons.edit_note_rounded,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: AppTheme.spaceXl),

                // Add / Update Expense Button
                Obx(
                  () => CustomButton(
                    text: _isEditMode ? 'Update Expense' : 'Add Expense',
                    isLoading: _expenseController.isLoading.value,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _handleSubmit,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),

                const Center(
                  child: Text(
                    'Stored securely in your Cloud Firestore database.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
