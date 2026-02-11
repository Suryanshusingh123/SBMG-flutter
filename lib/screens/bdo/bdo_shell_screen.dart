import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import 'bdo_home_screen.dart';
import 'bdo_complaints_screen.dart';
import 'bdo_inspection_screen.dart';
import 'bdo_settings_screen.dart';

/// Shell that wraps the main BDO tab screens with a single bottom navigation bar.
/// Uses IndexedStack to keep tab state when switching. Detail screens (complaint
/// details, new inspection, etc.) are pushed on top and do not show the bottom bar.
class BdoShellScreen extends StatefulWidget {
  /// Initial tab index (0=Home, 1=Complaints, 2=Inspection, 3=Settings).
  /// Used when navigating from login/redirect to a specific tab.
  final int initialIndex;

  const BdoShellScreen({super.key, this.initialIndex = 0});

  @override
  State<BdoShellScreen> createState() => _BdoShellScreenState();
}

class _BdoShellScreenState extends State<BdoShellScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Exit App',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          content: Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  color: const Color(0xFF6B7280),
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const BdoHomeScreen(isEmbeddedInShell: true),
            const BdoComplaintsScreen(isEmbeddedInShell: true),
            const BdoInspectionScreen(isEmbeddedInShell: true),
            const BdoSettingsScreen(isEmbeddedInShell: true),
          ],
        ),
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
              label: l10n.complaints,
            ),
            BottomNavItem(
              iconPath: 'assets/icons/bottombar/inspection.png',
              label: l10n.inspection,
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
