import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../theme/app_theme.dart';

/// Reusable list tile for an individual expense transaction with Edit and Delete support.
class ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: ListTile(
        onTap: onTap ?? onEdit,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMd,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: expense.categoryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(
            expense.categoryIcon,
            color: expense.categoryColor,
            size: 22,
          ),
        ),
        title: Text(
          expense.note,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.border, width: 0.8),
              ),
              child: Text(
                expense.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                expense.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '-${expense.formattedAmount}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (onDelete != null || onEdit != null) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
                          SizedBox(width: 8),
                          Text('Edit Expense'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.error),
                          SizedBox(width: 8),
                          Text('Delete Expense', style: TextStyle(color: AppTheme.error)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
