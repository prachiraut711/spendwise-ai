import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Data model representing structured spending insights returned by Gemini via Firebase AI.
class AiInsightModel {
  final String overall;
  final String topCategory;
  final double topCategoryAmount;
  final List<String> insights;
  final String savingTip;

  AiInsightModel({
    required this.overall,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.insights,
    required this.savingTip,
  });

  String get formattedTopAmount => '₹${topCategoryAmount.toStringAsFixed(0)}';

  /// Parses AI response text safely, handling raw JSON, markdown code-blocks, or fallback text.
  factory AiInsightModel.parse(String responseText, {
    required String fallbackCategory,
    required double fallbackCategoryAmount,
    required double totalSpend,
  }) {
    try {
      // 1. Clean markdown code fences if present (e.g. ```json ... ```)
      String cleanText = responseText.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      // 2. Parse JSON
      final Map<String, dynamic> data = jsonDecode(cleanText);

      final overall = data['overall'] as String? ??
          'Your total spending this month is ₹${totalSpend.toStringAsFixed(0)}.';
      final topCat = data['topCategory'] as String? ?? fallbackCategory;
      final topAmount = (data['topCategoryAmount'] as num?)?.toDouble() ??
          fallbackCategoryAmount;
      final rawInsights = data['insights'] as List<dynamic>? ?? [];
      final insightsList = rawInsights
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final savingTip = data['savingTip'] as String? ??
          'Consider reviewing discretionary expenses in your top category to save more.';

      return AiInsightModel(
        overall: overall,
        topCategory: topCat,
        topCategoryAmount: topAmount,
        insights: insightsList.isNotEmpty
            ? insightsList
            : [
                'Your primary spending focus is $topCat.',
                'Keeping track of frequent small expenses helps maintain budget discipline.',
              ],
        savingTip: savingTip,
      );
    } catch (e) {
      debugPrint('[AiInsightModel.parse] JSON parse failed, using fallback parser: $e');

      // Fallback: extract bullet points and lines from plain text response
      final lines = responseText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final bullets = lines
          .where((l) => l.startsWith('•') || l.startsWith('-') || l.startsWith('*'))
          .map((l) => l.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
          .toList();

      return AiInsightModel(
        overall: lines.isNotEmpty
            ? lines.first
            : 'Your spending is focused primarily on $fallbackCategory.',
        topCategory: fallbackCategory,
        topCategoryAmount: fallbackCategoryAmount,
        insights: bullets.isNotEmpty
            ? bullets
            : [
                'Highest expenditure recorded in $fallbackCategory.',
                'Total monthly spending stands at ₹${totalSpend.toStringAsFixed(0)}.',
              ],
        savingTip: lines.length > 1
            ? lines.last
            : 'Set a weekly limit on $fallbackCategory to optimize monthly savings.',
      );
    }
  }
}
