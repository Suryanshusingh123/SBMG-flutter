import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../supervisor/theme_bottom_sheet.dart';
import '../supervisor/reset_password_flow_screen.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
// import '../supervisor/feedback_bottom_sheet.dart';
// import '../supervisor/language_bottom_sheet.dart';

class BdoSettingsScreen extends StatefulWidget {
  const BdoSettingsScreen({super.key});

  @override
  State<BdoSettingsScreen> createState() => _BdoSettingsScreenState();
}

class _BdoSettingsScreenState extends State<BdoSettingsScreen> {
  bool _notificationsEnabled = false;
  int _selectedIndex = 3; // Settings tab is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Regular Settings Items
            _buildSettingsSection([
              _buildSettingsItem(
                icon: Icons.lock,
                title: 'Reset Password',
                onTap: () => _navigateToResetPassword(),
              ),
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF009B56),
                ),
              ),
              _buildSettingsItem(
                icon: Icons.palette,
                title: 'Theme',
                onTap: () => _showThemeBottomSheet(),
              ),
              _buildSettingsItem(
                icon: Icons.thumb_up,
                title: 'Give us Feedback',
                onTap: () => _showFeedbackBottomSheet(),
              ),
              _buildSettingsItem(
                icon: Icons.translate,
                title: 'Language',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009B56),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'English',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () => _showLanguageBottomSheet(),
                showDivider: false,
              ),
            ]),

            SizedBox(height: 24.h),

            // Login as Citizen Card
            _buildCardSection([
              _buildSettingsItem(
                title: 'Login as Citizen',
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/citizen-dashboard');
                },
                showDivider: false,
              ),
            ]),

            SizedBox(height: 16.h),

            // Logout Card
            _buildCardSection([
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'Logout',
                textColor: const Color(0xFFEF4444),
                iconColor: const Color(0xFFEF4444),
                onTap: () {
                  _showLogoutDialog();
                },
                showDivider: false,
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSettingsSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildCardSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem({
    IconData? icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Icon
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? const Color(0xFF6B7280),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor ?? const Color(0xFF111827),
                          ),
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 14.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing Widget or Arrow
                  if (trailing != null)
                    trailing
                  else if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E7EB),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  void _showThemeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeBottomSheet(),
    );
  }

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordFlowScreen()),
    );
  }

  void _showLanguageBottomSheet() {
    // TODO: Implement LanguageBottomSheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Selection'),
        content: const Text('Language selection coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackBottomSheet() {
    // TODO: Implement FeedbackBottomSheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback'),
        content: const Text('Feedback feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/bdo-dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/bdo-complaints');
            break;
          case 2:
            Navigator.pushNamed(context, '/bdo-monitoring');
            break;
          case 3:
            // Already on settings
            break;
        }
      },
      items: const [
        BottomNavItem(icon: Icons.home, label: 'Home'),
        BottomNavItem(icon: Icons.report_problem, label: 'Complaint'),
        BottomNavItem(icon: Icons.checklist, label: 'Inspection'),
        BottomNavItem(icon: Icons.settings, label: 'Settings'),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.all(24.r),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You\'ll need to sign in again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                  height: 1.3,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF111827),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
