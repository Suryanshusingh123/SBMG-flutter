import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/citizen_auth_provider.dart';
import '../../theme/citizen_colors.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import 'citizen_home_screen.dart';
import 'my_complaints_screen.dart';
import 'schemes_screen.dart';
import 'settings_screen.dart';

/// Shell that wraps the main citizen tab screens with a single bottom navigation bar.
/// Uses IndexedStack to keep tab state when switching. Detail screens (complaint
/// details, create complaint, etc.) are pushed on top and do not show the bottom bar.
class CitizenShellScreen extends StatefulWidget {
  /// Initial tab index (0=Home, 1=MyComplaints, 2=Schemes, 3=Settings).
  /// Used when navigating from login/OTP with redirectTo to a specific tab.
  final int initialIndex;

  const CitizenShellScreen({super.key, this.initialIndex = 0});

  @override
  State<CitizenShellScreen> createState() => _CitizenShellScreenState();
}

class _CitizenShellScreenState extends State<CitizenShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _checkAuthAndNavigate() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn) {
      Navigator.pushNamed(context, '/create-complaint');
    } else {
      _showLoginRequiredDialog(context);
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CitizenColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            l10n.loginRequired,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            l10n.loginRequiredForRaise,
            style: const TextStyle(fontFamily: 'Noto Sans', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(
                  context,
                  '/citizen-login',
                  arguments: {'redirectTo': '/create-complaint'},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w600,
                  color: CitizenColors.light,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CitizenColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Exit App',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: CitizenColors.textPrimary(context),
            ),
          ),
          content: Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14.sp,
              color: CitizenColors.textSecondary(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: CitizenColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Exit',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w600,
                  color: CitizenColors.light,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget? _buildFab() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: FloatingActionButton.extended(
        onPressed: _checkAuthAndNavigate,
        backgroundColor: const Color(0xFF009B56),
        foregroundColor: CitizenColors.light,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.raiseComplaint,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, size: 20.sp),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: CitizenColors.background(context),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            CitizenHomeScreen(
              isEmbeddedInShell: true,
              onNavigateToTab: (i) => setState(() => _selectedIndex = i),
            ),
            const MyComplaintsScreen(isEmbeddedInShell: true),
            const SchemesScreen(isEmbeddedInShell: true),
            const SettingsScreen(isEmbeddedInShell: true),
          ],
        ),
        floatingActionButton: _selectedIndex == 0 ? _buildFab() : null,
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
          items: [
            BottomNavItem(
              iconPath: 'assets/icons/bottombar/home.png',
              label: l10n.home,
            ),
            BottomNavItem(
              iconPath: 'assets/icons/bottombar/complaints.png',
              label: l10n.myComplaint,
            ),
            BottomNavItem(
              iconPath: 'assets/icons/bottombar/schemes.png',
              label: l10n.schemes,
            ),
            BottomNavItem(
              iconPath: 'assets/icons/bottombar/settings.png',
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
