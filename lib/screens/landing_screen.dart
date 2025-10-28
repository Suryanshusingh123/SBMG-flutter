import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sbmg/config/connstants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  SizedBox(height: 20.h),

                  // Top Logos
                  Row(
                    children: [
                      // Top Left - Swach Logo
                      Padding(
                        padding: EdgeInsets.only(left: 20.w),
                        child: Image.asset(
                          'assets/logos/swach.png',
                          width: 70.w,
                          height: 70.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      // Top Right - Glasses Logo
                      Padding(
                        padding: EdgeInsets.only(right: 20.w),
                        child: Image.asset(
                          'assets/logos/glasses.png',
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5.h),

                  // Map Image
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Image.asset(
                      'assets/images/map.png',
                      width: 220.w,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Text Images
                  Image.asset(
                    'assets/images/sbdmwritten.png',
                    width: 180.w,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(height: 8.h),
                  Image.asset(
                    'assets/images/rj.png',
                    width: 190.w,
                    fit: BoxFit.fitWidth,
                  ),

                  SizedBox(height: 20.h),

                  // Satyamev Logo
                  Image.asset(
                    'assets/logos/satyamev.png',
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),

              // Bottom Buttons
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    children: [
                      // Login as Admin Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/admin-login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Login as Admin',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Continue as Citizen Button
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/citizen-dashboard',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue as Citizen',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
