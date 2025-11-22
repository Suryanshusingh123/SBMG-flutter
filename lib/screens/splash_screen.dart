import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sbmg/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user has seen onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      // User hasn't seen onboarding, show it
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      // User has seen onboarding before, check login status
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        // User is logged in, first check for stored role (from admin/login)
        final storedRole = await authService.getRole();

        if (storedRole != null) {
          // Admin/contractor/supervisor etc login - navigate based on stored role
          print('📍 Found stored role: $storedRole');
          _navigateToRoleDashboard(storedRole.toLowerCase());
        } else {
          // No stored role, try to get from API (citizen login)
          print('📍 No stored role, trying to get from API...');
          final userResponse = await authService.getCurrentUser();

          if (!mounted) return;

          if (userResponse['success'] == true) {
            final user = userResponse['user'];
            var role = user['role']?.toLowerCase();

            if (role != null) {
              print('📍 Found role from API: $role');
              _navigateToRoleDashboard(role);
            } else {
              // No role found, go to landing
              print('📍 No role found in API response');
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/landing');
            }
          } else {
            // Failed to get user info, go to landing
            print('📍 Failed to get user info');
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/landing');
          }
        }
      } else {
        // User is not logged in, go to landing to show login options
        print('📍 User is not logged in');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/landing');
      }
    }
  }

  Future<void> _navigateToRoleDashboard(String? role) async {
    final authService = AuthService();

    switch (role) {
      case 'citizen':
        Navigator.pushReplacementNamed(context, '/citizen-dashboard');
        break;
      case 'worker': // WORKER role maps to supervisor
        Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
        break;
      case 'supervisor':
        Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
        break;
      case 'bdo':
        Navigator.pushReplacementNamed(context, '/bdo-dashboard');
        break;
      case 'admin': // ADMIN role maps to SMD
        // Check if SMD has selected a district
        final hasDistrict = await authService.hasSmdSelectedDistrict();
        if (hasDistrict) {
          Navigator.pushReplacementNamed(context, '/smd-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/smd-district-selection');
        }
        break;
      case 'vdo':
        Navigator.pushReplacementNamed(context, '/vdo-dashboard');
        break;
      case 'ceo':
        Navigator.pushReplacementNamed(context, '/ceo-dashboard');
        break;
      case 'smd':
        // Check if SMD has selected a district
        final hasDistrict = await authService.hasSmdSelectedDistrict();
        if (hasDistrict) {
          Navigator.pushReplacementNamed(context, '/smd-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/smd-district-selection');
        }
        break;
      case 'contractor':
        Navigator.pushReplacementNamed(context, '/contractor-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Top Left - Swach Logo
            Positioned(
              left: 20.w,
              top: 60.h,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/logos/swach.png',
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Top Right - Glasses Logo
            Positioned(
              right: 20.w,
              top: 60.h,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/logos/glasses.png',
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Center Content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Map image in center
                      Image.asset(
                        'assets/images/map.png',
                        width: 250.w,
                        height: 250.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20.h),
                      // Text images
                      Image.asset(
                        'assets/images/sbdmwritten.png',
                        width: 200.w,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(height: 5.h),
                      Image.asset(
                        'assets/images/rj.png',
                        width: 200.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom - Satyamev Logo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/ministers.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
