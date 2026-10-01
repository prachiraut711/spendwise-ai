import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';

/// Clean fintech Profile & Settings screen.
class ProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const ProfileScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  final AuthController _authController = Get.find<AuthController>();

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'SpendWise AI',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Version 1.0.0 (Foundation)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'SpendWise AI is a modern personal expense management platform engineered with Flutter, GetX, Firebase, and AI-driven spending insights.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Designed for clean architecture, minimal clutter, and portfolio-ready performance.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton || Navigator.canPop(context),
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Profile Card
            CustomCard(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primarySurface,
                          border: Border.all(color: AppTheme.primary, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    _authController.userDisplayName.isNotEmpty
                        ? _authController.userDisplayName
                        : 'SpendWise User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _authController.userEmail.isNotEmpty
                        ? _authController.userEmail
                        : 'Authenticated User',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Text(
                      'Free Tier • Personal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Settings Section
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Currency Option
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.currency_rupee_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Default Currency',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.primaryLight),
                      ),
                      child: const Text(
                        'INR (₹)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const Divider(indent: 56),

                  // Notifications Toggle
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Push Notifications',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Daily expense reminders and budget alerts',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    value: _notificationsEnabled,
                    activeColor: AppTheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                    },
                  ),
                  const Divider(indent: 56),

                  // About SpendWise AI
                  ListTile(
                    onTap: _showAboutDialog,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'About SpendWise AI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'App info and version details',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Logout Card / Button
            CustomCard(
              onTap: _authController.logout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
          ],
        ),
      ),
    ),
  ),
);
}
}
