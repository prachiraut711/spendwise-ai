import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:spendwise_ai/app/routes/app_routes.dart';
import 'package:spendwise_ai/main.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('Verify all routes, screens, and interactions', (WidgetTester tester) async {
    // 1. Build and verify Login Screen
    await tester.pumpWidget(const SpendWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('SpendWise AI'), findsOneWidget);
    expect(find.text('Understand your spending. Make smarter decisions.'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Test form validation on empty sign in
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email'), findsOneWidget);

    // 2. Test navigation to Register Screen
    final registerLink = find.text('Create account');
    expect(registerLink, findsOneWidget);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);

    // Go back to login
    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);

    // 3. Open Home Dashboard
    Get.toNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    // Verify Home Screen elements
    expect(find.text('Good Morning 👋'), findsOneWidget);
    expect(find.text("Here's your spending overview"), findsOneWidget);
    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('✨ AI Spending Insight'), findsOneWidget);
    expect(find.text('View Insights'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);

    // Verify categories on dashboard
    expect(find.text('Food'), findsWidgets);
    expect(find.text('Transport'), findsWidgets);
    expect(find.text('Shopping'), findsWidgets);
    expect(find.text('Entertainment'), findsWidgets);

    // 4. Test AI Insights navigation
    await tester.tap(find.text('View Insights'));
    await tester.pumpAndSettle();

    expect(find.text('AI Spending Insights'), findsOneWidget);
    expect(find.text('SpendWise Intelligence'), findsOneWidget);
    expect(find.text('No expenses recorded yet'), findsOneWidget);


    // Go back to Home
    Get.back();
    await tester.pumpAndSettle();

    // 5. Test Bottom Navigation to Expenses
    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    expect(find.text('Expense History'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);

    // 6. Test Bottom Navigation to Analytics
    await tester.tap(find.byIcon(Icons.pie_chart_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Analytics & Trends'), findsOneWidget);
    expect(find.text('Monthly Spending Summary'), findsOneWidget);
    expect(find.text('Highest Spending Category'), findsOneWidget);
    expect(find.text('Weekly Spending Summary'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);

    // 7. Test Bottom Navigation to Profile
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('SpendWise User'), findsOneWidget);
    expect(find.text('INR (₹)'), findsOneWidget);
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.text('About SpendWise AI'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // 8. Test Add Expense Screen
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Amount Spent'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Note / Description'), findsOneWidget);
    expect(find.text('Stored securely in your Cloud Firestore database.'), findsOneWidget);
  });
}
