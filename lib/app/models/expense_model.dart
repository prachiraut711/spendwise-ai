import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Expense model connected to Cloud Firestore under the `expenses` collection.
class ExpenseModel {
  final String id;
  final String userId;
  final String note;
  final String category;
  final double amount;
  final DateTime date;
  final DateTime? createdAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.note,
    required this.category,
    required this.amount,
    required this.date,
    this.createdAt,
  });

  /// Formatted currency string in INR (₹)
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  /// Formatted date string for user-friendly display
  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  /// Relative date indicator (Today, Yesterday, or formatted date)
  String get relativeDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return 'Today';
    } else if (expenseDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return formattedDate;
    }
  }

  /// Category icon mapping
  IconData get categoryIcon {
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

  /// Distinct category color theme
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFF97316); // Orange
      case 'transport':
        return const Color(0xFF3B82F6); // Blue
      case 'shopping':
        return const Color(0xFFEC4899); // Pink
      case 'entertainment':
        return const Color(0xFF8B5CF6); // Purple
      case 'bills':
        return const Color(0xFF0D9488); // Teal
      case 'health':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  /// Serializes model to Firestore document format
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'note': note,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Deserializes a Firestore DocumentSnapshot or Map
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime? parsedCreatedAt;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreatedAt = rawCreated.toDate();
    }

    return ExpenseModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      note: map['note'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      createdAt: parsedCreatedAt,
    );
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExpenseModel.fromMap(data, doc.id);
  }

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? note,
    String? category,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      note: note ?? this.note,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
