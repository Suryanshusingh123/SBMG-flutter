import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sbmg/screens/citizen/language_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../config/connstants.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../providers/citizen_schemes_provider.dart';
import '../../providers/citizen_events_provider.dart';
import '../../providers/citizen_bookmarks_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/common/banner_carousel.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../services/auth_services.dart';
import '../../theme/citizen_colors.dart';
import 'vendor_details_screen.dart';
import 'gp_master_data_details_screen.dart';
import 'notifications_screen.dart';
import 'scheme_details_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();

    // Load data using providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schemesProvider = context.read<SchemesProvider>();
      final eventsProvider = context.read<EventsProvider>();

      if (schemesProvider.featuredSchemes.isEmpty) {
        schemesProvider.loadFeaturedSchemes(limit: 3);
      }

      if (eventsProvider.events.isEmpty) {
        eventsProvider.loadEvents(limit: 15);
      }
    });
  }

  // Helper method to get dynamic greeting based on current time
  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return l10n.goodEvening;
    } else {
      return l10n.goodNight;
    }
  }

  // Helper method to get appropriate icon based on current time
  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 18) {
      return Icons
          .wb_sunny; // Sun icon for morning, afternoon, and early evening
    } else {
      return Icons.nightlight_round; // Moon icon for evening and night
    }
  }

  // Helper method to get current date in formatted string
  String _getCurrentDate() {
    final now = DateTime.now();
    return DateFormat('d MMM yyyy').format(now);
  }

  // Helper method to format date
  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return DateFormat('MMM d yyyy').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  // Check authentication before navigating to create complaint
  Future<void> _checkAuthAndNavigate(BuildContext context) async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn) {
      // User is logged in, navigate to create complaint
      Navigator.pushNamed(context, '/create-complaint');
    } else {
      // User is not logged in, show dialog
      _showLoginRequiredDialog(context);
    }
  }

  // Check authentication before navigating to my complaints
  Future<void> _checkAuthAndNavigateToComplaints(BuildContext context) async {
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();

    if (isLoggedIn) {
      // User is logged in, navigate to my complaints
      Navigator.pushNamed(context, '/my-complaints');
    } else {
      // User is not logged in, show dialog
      _showLoginRequiredForComplaintsDialog(context);
    }
  }

  // Show dialog when login is required
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                Navigator.pushNamed(context, '/citizen-login');
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

  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          _showLocationServiceDialog();
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showLocationPermissionDialog();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      // Permission granted
      if (mounted) {
        setState(() {
          // Location permission is granted
        });
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    }
  }

  void _showLocationServiceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.locationServicesRequired),
          content: Text(l10n.locationServicesMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: Text(l10n.openSettings),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.skip),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPermissionDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.locationPermissionRequired),
          content: Text(l10n.locationPermissionMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _requestLocationPermission();
              },
              child: Text(l10n.grantPermission),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.skip),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    // This method is not used as we navigate directly to language screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CitizenColors.surface(context),
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.english),
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChanged),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF009B56),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.hindi),
                onTap: () {
                  localeProvider.setLocale(const Locale('hi'));
                  Navigator.pop(context);
                  // Show snackbar after a small delay to ensure new locale is loaded
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (mounted) {
                      final newL10n = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(newL10n.languageChanged),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF009B56),
                        ),
                      );
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show dialog when login is required for viewing complaints
  void _showLoginRequiredForComplaintsDialog(BuildContext context) {
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
            l10n.loginRequiredForComplaints,
            style: const TextStyle(fontFamily: 'Noto Sans', fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                Navigator.pushNamed(context, '/citizen-login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                l10n.login,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Prevent back navigation - user should logout instead
        _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: CitizenColors.background(context),
        body: SafeArea(
          child: Column(
            children: [
              // Top Header
              _buildTopHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Banner Carousel
                      const BannerCarousel(
                        imagePaths: [
                          'assets/images/dash1.jpeg',
                          'assets/images/dash2.jpeg',
                          'assets/images/dash3.jpeg',
                          'assets/images/dash4.jpeg',
                          'assets/images/dash5.jpeg',
                        ],
                      ),

                      Image.asset('assets/images/Group.png'),

                      SizedBox(height: 8.h),

                      // Call Us Banner
                      _buildCallUsBanner(),

                      SizedBox(height: 20.h),

                      // Featured Schemes Section
                      _buildFeaturedSchemesSection(),

                      SizedBox(height: 20.h),

                      // Action Cards Section
                      _buildActionCardsSection(),

                      SizedBox(height: 20.h),

                      // Events Section
                      _buildEventsSection(),

                      SizedBox(height: 20.h),

                      // Social Media Section
                      _buildSocialMediaSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Action Button
        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          child: FloatingActionButton.extended(
            onPressed: () {
              // Check if user is logged in before navigating
              _checkAuthAndNavigate(context);
            },
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
                // Already on home
                break;
              case 1:
                _checkAuthAndNavigateToComplaints(context);
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/schemes');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/settings');
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
      ),
    );
  }

  Widget _buildTopHeader() {
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_getGreetingIcon(), color: Color(0xFF009B56), size: 20.sp),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getCurrentDate(),
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/Vector.png',
                  width: 24,
                  height: 24,
                  color: secondaryTextColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
                icon: Image.asset(
                  'assets/icons/Translate.png',
                  width: 24,
                  height: 24,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallUsBanner() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED), // Light beige color
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          l10n.callUsMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFFC2410C), // Burnt orange/brown color
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFeaturedSchemesSection() {
    final l10n = AppLocalizations.of(context)!;
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Consumer<SchemesProvider>(
      builder: (context, schemesProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.featuredScheme,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                      letterSpacing: 0,
                      height: 1.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/schemes');
                    },
                    child: Text(
                      l10n.viewAll,
                      style: const TextStyle(
                        color: Color(0xFF009B56),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Scrollable Schemes
            SizedBox(
              height: 200,
              child: schemesProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF009B56),
                        ),
                      ),
                    )
                  : schemesProvider.featuredSchemes.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noSchemesAvailable,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: schemesProvider.featuredSchemes.length,
                      itemBuilder: (context, index) {
                        return _buildSchemeCard(
                          schemesProvider.featuredSchemes[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchemeCard(Scheme scheme) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchemeDetailsScreen(
              scheme: scheme,
              initialBookmarkState: Provider.of<BookmarksProvider>(
                context,
                listen: false,
              ).isSchemeBookmarked(scheme.id),
            ),
          ),
        );
      },
      child: Container(
        width: 350,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: scheme.media.isNotEmpty
                    ? Image.network(
                        ApiConstants.getMediaUrl(scheme.media.first.mediaUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Suppress error logs for 404s since we have fallback
                          return Image.asset(
                            'assets/images/schemes.png',
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/schemes.png',
                        fit: BoxFit.cover,
                      ),
              ),
              // Gradient overlay with scheme name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    scheme.name,
                    style: TextStyle(
                      color: CitizenColors.light,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCardsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Survey Details Card
          Expanded(
            child: _buildActionCard(
              icon: Icons.description,
              title: l10n.surveyDetails,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GpMasterDataDetailsScreen(),
                  ),
                );
              },
            ),
          ),

          SizedBox(width: 16.w),

          // Get Contractor Details Card
          Expanded(
            child: _buildActionCard(
              icon: Icons.business,
              title: l10n.getContractorDetails,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VendorDetailsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final primaryTextColor = CitizenColors.textPrimary(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140, // Fixed height for both cards
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: CitizenColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF009B56).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF009B56), size: 24.sp),
            ),

            // Title
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryTextColor,
                    letterSpacing: 0,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF009B56),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final l10n = AppLocalizations.of(context)!;
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Consumer<EventsProvider>(
      builder: (context, eventsProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '${eventsProvider.eventsCount} ${eventsProvider.eventsCount != 1 ? l10n.eventsPlural : l10n.events}',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                  letterSpacing: 0,
                  height: 1.0,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Events List
            eventsProvider.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF009B56),
                        ),
                      ),
                    ),
                  )
                : eventsProvider.events.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Text(
                        l10n.noEventsAvailable,
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: eventsProvider.events.length > 15
                        ? 15
                        : eventsProvider.events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(
                        eventsProvider.events[index],
                        index,
                      );
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(Event event, int index) {
    return GestureDetector(
      onTap: () {
        // Show event details in a dialog
        _showEventDetails(event);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Banner with eventbanner.png
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: event.media.isNotEmpty
                        ? Image.network(
                            ApiConstants.getMediaUrl(
                              event.media.first.mediaUrl,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Suppress error logs for 404s since we have fallback
                              return Image.asset(
                                'assets/images/eventbanner.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/eventbanner.png',
                            fit: BoxFit.cover,
                          ),
                  ),

                  // Bookmark Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Consumer<BookmarksProvider>(
                      builder: (context, bookmarksProvider, child) {
                        final isBookmarked = bookmarksProvider
                            .isEventBookmarked(event.id);
                        return GestureDetector(
                          onTap: () {
                            bookmarksProvider.toggleEventBookmark(
                              event.id,
                              !isBookmarked,
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isBookmarked
                                  ? const Color(0xFF009B56)
                                  : CitizenColors.light.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? CitizenColors.light
                                  : const Color(0xFF4CAF50),
                              size: 20.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Event Details
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: CitizenColors.surface(context),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 110.w),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Color(0xFF009B56),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              '${_formatDate(event.startTime, includeYear: false)} - ${_formatDate(event.endTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _showEventDetails(Event event) {
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Event Image
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: event.media.isNotEmpty
                        ? Image.network(
                            ApiConstants.getMediaUrl(event.media.first.mediaUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/eventbanner.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/eventbanner.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // Event Details
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: secondaryTextColor),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: const Color(0xFF009B56),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${_formatDate(event.startTime)} - ${_formatDate(event.endTime)}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (event.description != null && event.description!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: primaryTextColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: CitizenColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Connect with Swachh Rajasthan',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: CitizenColors.textPrimary(context),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  assetPath: 'assets/images/InstagramLogo.png',
                  platform: 'Instagram',
                  url: 'https://instagram.com/SwachhRajasthan_',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/XLogo.png',
                  platform: 'X',
                  url: 'https://x.com/SwachRajasthan',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/FacebookLogo.png',
                  platform: 'Facebook',
                  url: 'https://www.facebook.com/share/16UZeZDuvF/',
                ),
                SizedBox(width: 20.w),
                _buildSocialIcon(
                  assetPath: 'assets/images/YoutubeLogo.png',
                  platform: 'YouTube',
                  url: 'https://youtube.com/@swachhrajasthan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required String assetPath,
    required String platform,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => _launchSocialLink(url, platform),
      child: SizedBox(width: 40, height: 40, child: Image.asset(assetPath)),
    );
  }

  Future<void> _launchSocialLink(String url, String platform) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showLinkError(platform);
      }
    } catch (_) {
      if (mounted) {
        _showLinkError(platform);
      }
    }
  }

  void _showLinkError(String platform) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Could not open $platform link.'),
          backgroundColor: Colors.red,
        ),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                // Exit the app
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
}
