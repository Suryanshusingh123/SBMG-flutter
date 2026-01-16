import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_services.dart';
import '../../screens/auth/admin_login_screen.dart';
import '../../theme/citizen_colors.dart';
import 'citizen_reset_password_flow_screen.dart';
import 'profile_screen.dart';
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
    final primaryTextColor = CitizenColors.textPrimary(context);
    return Scaffold(
      backgroundColor: CitizenColors.background(context),
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
                        color: primaryTextColor,
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
                            _showLanguageBottomSheet(context);
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

                    // Logout
                    InkWell(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: CitizenColors.surface(context),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                          color: CitizenColors.surface(context),
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 24.sp, color: Colors.red),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  l10n.logout,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Login as Admin
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: CitizenColors.surface(context),
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
            iconPath: 'assets/icons/bottombar/home.png',
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavItem(
            iconPath: 'assets/icons/bottombar/complaints.png',
            label: AppLocalizations.of(context)!.myComplaint,
          ),
          BottomNavItem(
            iconPath: 'assets/icons/bottombar/schemes.png',
            label: AppLocalizations.of(context)!.schemes,
          ),
          BottomNavItem(
            iconPath: 'assets/icons/bottombar/settings.png',
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
    Color? iconColor,
  }) {
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    final finalIconColor = iconColor ?? primaryTextColor;
    final finalTextColor = iconColor ?? primaryTextColor;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: CitizenColors.surface(context),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: finalIconColor),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: finalTextColor,
                ),
              ),
            ),
            if (iconColor == null)
              Icon(Icons.chevron_right, size: 24.sp, color: secondaryTextColor),
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
    final primaryTextColor = CitizenColors.textPrimary(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: CitizenColors.surface(context),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: primaryTextColor),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: primaryTextColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: CitizenColors.light,
            activeTrackColor: AppColors.primaryColor,
            inactiveThumbColor: CitizenColors.light,
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
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: CitizenColors.surface(context),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: primaryTextColor),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: primaryTextColor,
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
                  color: CitizenColors.light,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, size: 24.sp, color: secondaryTextColor),
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
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        color: CitizenColors.surface(context),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: primaryTextColor),
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
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 24.sp, color: secondaryTextColor),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (bottomSheetContext) {
        final primaryTextColor = CitizenColors.textPrimary(bottomSheetContext);
        final secondaryTextColor = CitizenColors.textSecondary(
          bottomSheetContext,
        );
        final surfaceColor = CitizenColors.surface(bottomSheetContext);

        Widget languageOptionTile({
          required String title,
          required String languageCode,
          required String currentLanguageCode,
          required VoidCallback onSelect,
        }) {
          final isSelected = currentLanguageCode == languageCode;

          return InkWell(
            onTap: onSelect,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.circle_outlined,
                    color: isSelected
                        ? AppColors.primaryColor
                        : secondaryTextColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      color: AppColors.primaryColor,
                      size: 20.sp,
                    ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: surfaceColor,
          padding: EdgeInsets.all(20.w),
          child: Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              final currentLanguageCode = localeProvider.locale.languageCode;

              Future<void> handleLanguageSelection(String code) async {
                await localeProvider.setLocale(Locale(code));
                if (mounted) {
                  Navigator.pop(bottomSheetContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChanged),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.language,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24.sp,
                          color: secondaryTextColor,
                        ),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  languageOptionTile(
                    title: l10n.english,
                    languageCode: 'en',
                    currentLanguageCode: currentLanguageCode,
                    onSelect: () => handleLanguageSelection('en'),
                  ),
                  SizedBox(height: 12.h),
                  languageOptionTile(
                    title: l10n.hindi,
                    languageCode: 'hi',
                    currentLanguageCode: currentLanguageCode,
                    onSelect: () => handleLanguageSelection('hi'),
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          ),
        );
      },
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
        builder: (context, setState) {
          final primaryTextColor = CitizenColors.textPrimary(context);
          final secondaryTextColor = CitizenColors.textSecondary(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              color: CitizenColors.surface(context),
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
                          color: primaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24.sp,
                          color: secondaryTextColor,
                        ),
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
                      color: primaryTextColor,
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
                        color: secondaryTextColor,
                      ),
                    ),
                  SizedBox(height: 24.h),

                  // Feedback label
                  Text(
                    l10n.enterFeedback,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
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
                          color: secondaryTextColor,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12.w),
                        counterText: '${feedbackController.text.length}/100',
                      ),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: primaryTextColor,
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
                        foregroundColor: CitizenColors.light,
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
          );
        },
      ),
    );
  }

  void _showFeedbackSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final primaryTextColor = CitizenColors.textPrimary(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: CitizenColors.surface(context),
              borderRadius: BorderRadius.circular(16.r),
            ),
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
                  child: const Icon(
                    Icons.star,
                    color: CitizenColors.light,
                    size: 32,
                  ),
                ),
                SizedBox(height: 20.h),

                // Success message
                Text(
                  l10n.yourFeedbackIsSuccessfullySubmitted,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
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
                      foregroundColor: CitizenColors.light,
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
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: CitizenColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: CitizenColors.surface(context),
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                l10n.areYouSureYouWantToLogOut,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                l10n.youllNeedToSignInAgainToAccessTheApp,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: secondaryTextColor,
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
                        l10n.close,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Confirm logout button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final authService = AuthService();
                        await authService.logout();
                        
                        // Clear auth provider state
                        if (context.mounted) {
                          final authProvider = context.read<AuthProvider>();
                          await authProvider.logout();
                        }

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
                        backgroundColor: Colors.red,
                        foregroundColor: CitizenColors.light,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.logout,
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
