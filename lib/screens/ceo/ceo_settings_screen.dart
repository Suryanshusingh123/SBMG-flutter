import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/locale_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../services/auth_services.dart';
import '../../services/api_services.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../supervisor/reset_password_flow_screen.dart';
import '../citizen/language_screen.dart';
import '../citizen/bookmarks_screen.dart';
import '../../widgets/common/feedback_form_content.dart';

class CeoSettingsScreen extends StatefulWidget {
  /// When true, this screen is shown inside [CeoShellScreen]; bottom nav is provided by the shell.
  final bool isEmbeddedInShell;

  const CeoSettingsScreen({super.key, this.isEmbeddedInShell = false});

  @override
  State<CeoSettingsScreen> createState() => _CeoSettingsScreenState();
}

class _CeoSettingsScreenState extends State<CeoSettingsScreen> {
  bool _notificationsEnabled = false;
  int _selectedIndex = 3; // Settings tab is selected
  bool? _hasExistingFeedback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFeedbackStatus());
  }

  Future<void> _loadFeedbackStatus() async {
    try {
      final existing = await ApiService().getMyFeedback(isPublicUser: false);
      if (mounted) setState(() => _hasExistingFeedback = existing != null);
    } catch (_) {
      if (mounted) setState(() => _hasExistingFeedback = false);
    }
  }

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
                    AppLocalizations.of(context)!.settings,
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
                      title: AppLocalizations.of(context)!.changePassword,
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
                      title: AppLocalizations.of(context)!.notifications,
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
                      title: AppLocalizations.of(context)!.faqs,
                      onTap: () {
                        // TODO: Navigate to FAQs screen
                      },
                    ),
                    _buildDivider(),

                    // Give us Feedback / Update your feedback
                    _buildSettingItem(
                      icon: Icons.thumb_up_outlined,
                      title: _hasExistingFeedback == true
                          ? AppLocalizations.of(context)!.updateYourFeedback
                          : AppLocalizations.of(context)!.giveUsFeedback,
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
                          title: AppLocalizations.of(context)!.language,
                          label: localeProvider.locale.languageCode == 'hi'
                              ? AppLocalizations.of(context)!.hindi
                              : AppLocalizations.of(context)!.english,
                          onTap: () async {
                            final locale = localeProvider.locale;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Localizations(
                                  locale: locale,
                                  delegates: const [
                                    AppLocalizations.delegate,
                                    GlobalMaterialLocalizations.delegate,
                                    GlobalWidgetsLocalizations.delegate,
                                    GlobalCupertinoLocalizations.delegate,
                                  ],
                                  child: const LanguageScreen(),
                                ),
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

                    // My Collection (schemes only)
                    _buildSettingItemWithSubtitle(
                      icon: Icons.bookmark_outline,
                      title: AppLocalizations.of(context)!.myCollection,
                      subtitle: AppLocalizations.of(context)!.bookmarkedSchemes,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookmarksScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Login as Citizen
                    _buildActionTile(
                      title: AppLocalizations.of(context)!.loginAsCitizen,
                      onTap: () {
                        _handleLoginAsCitizen(context);
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Logout
                    _buildActionTile(
                      title: AppLocalizations.of(context)!.logout,
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

      // Bottom nav is provided by CeoShellScreen when isEmbeddedInShell
      bottomNavigationBar: widget.isEmbeddedInShell
          ? null
          : _buildBottomNavigationBar(),
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
            activeThumbColor: Colors.white,
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
                      fontSize: 12.sp,
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

  Widget _buildBottomNavigationBar() {
    final l10n = AppLocalizations.of(context)!;

    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to different screens based on selection
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/ceo-dashboard');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/ceo-complaints');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/ceo-monitoring');
            break;
          case 3:
            // Already on settings
            break;
        }
      },
      items: [
        BottomNavItem(iconPath: 'assets/icons/bottombar/home.png', label: l10n.home),
        BottomNavItem(iconPath: 'assets/icons/bottombar/complaints.png', label: l10n.complaints),
        BottomNavItem(iconPath: 'assets/icons/bottombar/inspection.png', label: l10n.inspection),
        BottomNavItem(iconPath: 'assets/icons/bottombar/settings.png', label: l10n.settings),
      ],
    );
  }


  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      builder: (context) => FutureBuilder<Map<String, dynamic>?>(
        future: ApiService().getMyFeedback(isPublicUser: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(40.w),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return FeedbackFormContent(
            existingFeedback: snapshot.data,
            isPublicUser: false,
            onSuccess: (isUpdate) {
              Navigator.pop(context);
              setState(() => _hasExistingFeedback = true);
              _showFeedbackSuccessDialog(context, isUpdate: isUpdate);
            },
          );
        },
      ),
    );
  }

  void _showFeedbackSuccessDialog(BuildContext context, {bool isUpdate = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
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
                child: const Icon(Icons.star, color: Colors.white, size: 32),
              ),
              SizedBox(height: 20.h),

              // Success message
              Text(
                isUpdate
                    ? AppLocalizations.of(context)!.yourFeedbackHasBeenUpdated
                    : AppLocalizations.of(
                        context,
                      )!.yourFeedbackIsSuccessfullySubmitted,
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
                    AppLocalizations.of(context)!.close,
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
    // Clear CEO session
    final authService = AuthService();
    await authService.logout();
    
    // Clear bookmarks when user logs out
    if (context.mounted) {
      final bookmarksProvider = context.read<BookmarksProvider>();
      bookmarksProvider.clearBookmarks();
    }

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
        backgroundColor: Colors.white,
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
                AppLocalizations.of(context)!.areYouSureYouWantToLogOut,
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
                AppLocalizations.of(
                  context,
                )!.youllNeedToSignInAgainToAccessTheApp,
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
                        AppLocalizations.of(context)!.close,
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
                        
                        // Clear bookmarks when user logs out
                        if (context.mounted) {
                          final bookmarksProvider = context.read<BookmarksProvider>();
                          bookmarksProvider.clearBookmarks();
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
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
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
