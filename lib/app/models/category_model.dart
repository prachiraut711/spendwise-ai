import 'package:flutter/material.dart';

/// Spending category model representing category aggregates for dashboard cards.
class CategoryModel {
  final String name;
  final double amount;
  final double budget;
  final IconData icon;
  final Color color;

  CategoryModel({
    required this.name,
    required this.amount,
    required this.budget,
    required this.icon,
    required this.color,
  });

  /// Formatted amount in INR (₹)
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  /// Spending progress ratio between 0.0 and 1.0
  double get progressRatio => (budget > 0) ? (amount / budget).clamp(0.0, 1.0) : 0.0;

  /// Sample dashboard categories
  static List<CategoryModel> sampleCategories = [
    CategoryModel(
      name: 'Food',
      amount: 2450,
      budget: 4000,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFF97316),
    ),
    CategoryModel(
      name: 'Transport',
      amount: 1180,
      budget: 2500,
      icon: Icons.directions_subway_rounded,
      color: const Color(0xFF3B82F6),
    ),
    CategoryModel(
      name: 'Shopping',
      amount: 3200,
      budget: 5000,
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFEC4899),
    ),
    CategoryModel(
      name: 'Entertainment',
      amount: 1620,
      budget: 3000,
      icon: Icons.movie_filter_rounded,
      color: const Color(0xFF8B5CF6),
    ),
  ];
}
