import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_insight_model.dart';

/// Service interfacing with Firebase AI Logic using Gemini to generate spending insights.
class AiService {
  final FirebaseAI? _customFirebaseAI;
  final String _modelName;

  AiService({
    FirebaseAI? firebaseAI,
    String modelName = 'gemini-3.5-flash-lite',
  })  : _customFirebaseAI = firebaseAI,
        _modelName = modelName;

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<FirebaseAI?> _getFirebaseAIInstance() async {
    if (_customFirebaseAI != null) return _customFirebaseAI;
    if (isFirebaseAvailable) {
      FirebaseAppCheck? appCheck;
      FirebaseAuth? auth;

      // Safely test if App Check is activated and has a token available
      try {
        final token = await FirebaseAppCheck.instance.getToken();
        if (token != null && token.isNotEmpty) {
          appCheck = FirebaseAppCheck.instance;
          debugPrint('[AiService] AppCheck token acquired successfully.');
        }
      } catch (e) {
        debugPrint('[AiService] AppCheck not active on current platform/session: $e');
      }

      try {
        auth = FirebaseAuth.instance;
      } catch (e) {
        debugPrint('[AiService] Auth not accessible: $e');
      }

      return FirebaseAI.googleAI(
        app: Firebase.app(),
        appCheck: appCheck,
        auth: auth,
      );
    }
    return null;
  }

  /// Generates spending insights based solely on locally aggregated statistics.
  Future<AiInsightModel> generateSpendingInsights({
    required double totalSpending,
    required int expenseCount,
    required Map<String, double> categoryTotals,
    required String topCategory,
    required double topCategoryAmount,
    required double averageExpense,
  }) async {
    final ai = await _getFirebaseAIInstance();
    if (ai == null) {
      debugPrint('[AiService] Firebase AI is not available in current environment.');
      throw Exception('Firebase AI is not initialized.');
    }

    // Format category breakdown matching requested structure
    final categoryBreakdownBuffer = StringBuffer();
    categoryTotals.forEach((category, amount) {
      categoryBreakdownBuffer.writeln('$category: ₹${amount.toStringAsFixed(0)}');
    });

    // Security & Privacy: Send ONLY anonymous aggregated numbers. No user ID, email, or credentials.
    final prompt = '''
You are a personal financial advisor for SpendWise AI.
Analyze the following summarized spending data for the current month:

Total spending: ₹${totalSpending.toStringAsFixed(0)}
Number of expenses: $expenseCount
Top category: $topCategory
Top category amount: ₹${topCategoryAmount.toStringAsFixed(0)}
Category breakdown:
${categoryBreakdownBuffer.toString().trim()}

Then generate:
* one overall observation
* 2-3 insights
* one practical saving tip

Respond ONLY with a valid JSON object matching this exact schema:
{
  "overall": "One short overall observation about this month's spending",
  "topCategory": "$topCategory",
  "topCategoryAmount": $topCategoryAmount,
  "insights": [
    "One concise, helpful observation about category distribution",
    "One concise observation about transaction frequency or spending patterns"
  ],
  "savingTip": "One practical, actionable saving tip specifically for this spending profile"
}
''';

    debugPrint('[AiService] Calling Firebase AI Logic with model $_modelName...');
    debugPrint('[AiService] Summarized data: Top Category: $topCategory, Total: ₹$totalSpending, Count: $expenseCount');

    try {
      final model = ai.generativeModel(
        model: _modelName,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
        ),
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final responseText = response.text;
      debugPrint('[AiService] Gemini response received:\n$responseText');

      if (responseText == null || responseText.trim().isEmpty) {
        throw Exception('Empty response received from Gemini.');
      }

      return AiInsightModel.parse(
        responseText,
        fallbackCategory: topCategory,
        fallbackCategoryAmount: topCategoryAmount,
        totalSpend: totalSpending,
      );
    } on FirebaseAIException catch (e, stack) {
      debugPrint('[AiService] FirebaseAIException: [${e.runtimeType}] ${e.message}\n$stack');
      rethrow;
    } on FirebaseException catch (e, stack) {
      debugPrint('[AiService] FirebaseException: [${e.code}] ${e.message}\n$stack');
      rethrow;
    } catch (e, stack) {
      debugPrint('[AiService] Error generating insights with model $_modelName: $e\n$stack');
      rethrow;
    }
  }
}
