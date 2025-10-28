import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sbmg/config/connstants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final PageController _textPageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      image: 'assets/images/on1.png',
      title: 'One click complaint',
      description:
          'See a problem in your area? Don\'t wait. No long forms, no waiting in queues—just quick action.',
    ),
    const OnboardingPage(
      image: 'assets/images/on2.png',
      title: 'Government Schemes in\nOne Place',
      description:
          'Discover all the central and state government schemes that you are eligible for.',
    ),
    const OnboardingPage(
      image: 'assets/images/on3.png',
      title: 'Know Upcoming Events',
      description:
          'Get timely updates on all local happenings, including health camps, government workshops, gram sabha meetings.',
    ),
    const OnboardingPage(
      image: 'assets/images/on4.png',
      title: 'Contractor Details for Your Panchayat',
      description:
          'Easily access the details of government contractors, ongoing projects, and work status in your Gram Panchayat to ensure accountability.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _textPageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/landing');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _textPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _textPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 100.h),
                  // Top section: Image (animates)
                  Expanded(
                    flex: 2,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Image.asset(
                            _pages[index].image,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),

                  // Fixed Progress Indicators
                  Padding(
                    padding: EdgeInsets.only(top: 40.h, bottom: 32.h),
                    child: IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (indicatorIndex) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            width: 52.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: indicatorIndex <= _currentPage
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom section: Text (animates with its own PageView)
                  Expanded(
                    flex: 2,
                    child: PageView.builder(
                      controller: _textPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: 20.w, right: 20.w),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  _pages[index].title,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'sans-serif',
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                // Description
                                Text(
                                  _pages[index].description,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: 'sans-serif',
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Navigation Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                  // Back Button
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'sans-serif',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 16.w),

                  // Next/Continue Button
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Continue' : 'Next',
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}
