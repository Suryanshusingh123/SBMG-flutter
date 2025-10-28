import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/auth/admin_login_screen.dart';
import 'citizen_reset_password_flow_screen.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'bookmarks_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3; // Settings tab is selected
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header with time
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.settings,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
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
                      title: l10n.changePassword,
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

                    // Profile
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: l10n.profile,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    // Notifications with toggle
                    _buildSettingItemWithToggle(
                      icon: Icons.notifications_outlined,
                      title: l10n.notifications,
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
                      title: l10n.theme,
                      onTap: () {
                        _showThemeBottomSheet(context);
                      },
                    ),
                    _buildDivider(),

                    // FAQs
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: l10n.faqs,
                      onTap: () {
                        // TODO: Navigate to FAQs screen
                      },
                    ),
                    _buildDivider(),

                    // Give us Feedback
                    _buildSettingItem(
                      icon: Icons.thumb_up_outlined,
                      title: l10n.giveUsFeedback,
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
                          title: l10n.language,
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
                    _buildDivider(),

                    // My Collection
                    _buildSettingItemWithSubtitle(
                      icon: Icons.bookmark_outline,
                      title: l10n.myCollection,
                      subtitle: l10n.bookmarks,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookmarksScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    SizedBox(height: 16.h),

                    // Login as Admin
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: _buildSettingItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: l10n.loginAsAdmin,
                        showDivider: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminLoginScreen(),
                            ),
                          );
                        },
                      ),
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to different screens based on selection
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/citizen-dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/my-complaints');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/schemes');
              break;
            case 3:
              // Already on Settings
              break;
          }
        },
        items: [
          BottomNavItem(
            icon: Icons.home,
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavItem(
            icon: Icons.list_alt,
            label: AppLocalizations.of(context)!.myComplaint,
          ),
          BottomNavItem(
            icon: Icons.account_balance,
            label: AppLocalizations.of(context)!.schemes,
          ),
          BottomNavItem(
            icon: Icons.settings,
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
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
    bool showDivider = true,
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

  Widget _buildSettingItemWithSubtitle({
    required IconData icon,
    required String title,
    required String subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
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

  void _showThemeBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.theme,
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
                        content: Text(l10n.darkMode),
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
                            l10n.darkMode,
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
                        content: Text(l10n.lightMode),
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
                            l10n.lightMode,
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.giveUsFeedback,
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
                  l10n.howWasYourExperience,
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
                    l10n.chooseYourExperience,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                SizedBox(height: 24.h),

                // Feedback label
                Text(
                  l10n.enterFeedback,
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
                      hintText: l10n.enterFeedback,
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
                            content: Text(l10n.pleaseRateYourExperience),
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
                      l10n.submit,
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
    final l10n = AppLocalizations.of(context)!;
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
                color: Colors.white,
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
                l10n.yourFeedbackIsSuccessfullySubmitted,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
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
                    l10n.close,
                    style: const TextStyle(
                      fontSize: 16,
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
}
