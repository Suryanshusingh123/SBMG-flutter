import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_services.dart';
import 'reset_password_flow_screen.dart';
import '../citizen/language_screen.dart';

class SupervisorSettingsScreen extends StatefulWidget {
  const SupervisorSettingsScreen({super.key});

  @override
  State<SupervisorSettingsScreen> createState() =>
      _SupervisorSettingsScreenState();
}

class _SupervisorSettingsScreenState extends State<SupervisorSettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Change Password
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ResetPasswordFlowScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    // Notifications with toggle
                    _buildSettingItemWithToggle(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildDivider(),

                    // Theme
                    _buildSettingItem(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      onTap: () {
                        _showThemeBottomSheet(context);
                      },
                    ),
                    _buildDivider(),

                    // FAQs
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: 'FAQs',
                      onTap: () {
                        // TODO: Navigate to FAQs screen
                      },
                    ),
                    _buildDivider(),

                    // Give us Feedback
                    _buildSettingItem(
                      icon: Icons.thumb_up_outlined,
                      title: 'Give us Feedback',
                      onTap: () {
                        _showFeedbackBottomSheet(context);
                      },
                    ),
                    _buildDivider(),

                    // Language
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, child) {
                        return _buildSettingItemWithLabel(
                          icon: Icons.language_outlined,
                          title: 'Language',
                          label: localeProvider.locale.languageCode == 'hi'
                              ? 'Hindi'
                              : 'English',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LanguageScreen(),
                              ),
                            );
                            // Refresh the UI after returning from language screen
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Login as Citizen
                    _buildActionTile(
                      title: 'Login as Citizen',
                      onTap: () {
                        _handleLoginAsCitizen(context);
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Logout
                    _buildActionTile(
                      title: 'Logout',
                      icon: Icons.logout,
                      iconColor: const Color(0xFFEF4444),
                      textColor: const Color(0xFFEF4444),
                      backgroundColor: Colors.white,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 56.w),
      child: Divider(height: 1, thickness: 1, color: const Color(0xFFE5E7EB)),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: Colors.white,
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: const Color(0xFF111827)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItemWithToggle({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: const Color(0xFF111827)),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItemWithLabel({
    required IconData icon,
    required String title,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: Colors.white,
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: const Color(0xFF111827)),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right,
              size: 24.sp,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.list_alt, 'Complaint', 1),
          _buildNavItem(Icons.grid_view, 'Attendance', 2),
          _buildNavItem(Icons.settings, 'Settings', 3, isActive: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool isActive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/supervisor-complaints');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/supervisor-attendance');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/supervisor-settings');
          }
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8F5E8) : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isActive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9CA3AF),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 4.h),
              if (isActive)
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
              else
                SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Dark Mode option
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return InkWell(
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Dark Mode'),
                        backgroundColor: const Color(0xFF009B56),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.dark_mode_outlined,
                          size: 24.sp,
                          color: themeProvider.isDarkMode
                              ? AppColors.primaryColor
                              : const Color(0xFF111827),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (themeProvider.isDarkMode)
                          Icon(
                            Icons.check,
                            size: 20.sp,
                            color: AppColors.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 8.h),

            // Light Mode option
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return InkWell(
                  onTap: () {
                    themeProvider.setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Light Mode'),
                        backgroundColor: const Color(0xFF009B56),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode_outlined,
                          size: 24.sp,
                          color: !themeProvider.isDarkMode
                              ? AppColors.primaryColor
                              : const Color(0xFF111827),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Text(
                            'Light Mode',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (!themeProvider.isDarkMode)
                          Icon(
                            Icons.check,
                            size: 20.sp,
                            color: AppColors.primaryColor,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    int selectedRating = -1;
    final feedbackController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Give us Feedback',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Question
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 16.h),

                // Emoji rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final emojis = ['😢', '😞', '😐', '🙂', '😄'];
                    final isSelected = selectedRating == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: isSelected
                              ? const Color(0xFFD1FAE5)
                              : Colors.transparent,
                        ),
                        child: Text(
                          emojis[index],
                          style: TextStyle(fontSize: 32.sp),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8.h),

                // Instruction text
                if (selectedRating == -1)
                  Text(
                    'Choose your experience',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                SizedBox(height: 24.h),

                // Feedback label
                Text(
                  'Enter Feedback',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),

                // Feedback text area
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Enter Feedback',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                      counterText: '${feedbackController.text.length}/100',
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                SizedBox(height: 24.h),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedRating == -1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please rate your experience'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Show success dialog
                      Navigator.pop(context);
                      _showFeedbackSuccessDialog(context);

                      // Clear controllers
                      feedbackController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star icon
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB800),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 32),
              ),
              SizedBox(height: 20.h),

              // Success message
              Text(
                'Your feedback is successfully submitted',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 24.h),

              // Close button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24.sp,
                  color: iconColor ?? const Color(0xFF111827),
                ),
                SizedBox(width: 16.w),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? const Color(0xFF111827),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 24.sp,
                color: iconColor ?? const Color(0xFF111827),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoginAsCitizen(BuildContext context) async {
    // Clear supervisor session
    final authService = AuthService();
    await authService.logout();

    // Navigate to citizen home screen and clear navigation stack
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/citizen-dashboard',
        (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'You\'ll need to sign in again to access your account.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  // Close button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: const Color(0xFF374151),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Confirm button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authService = AuthService();
                        await authService.logout();

                        if (context.mounted) {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/landing',
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
