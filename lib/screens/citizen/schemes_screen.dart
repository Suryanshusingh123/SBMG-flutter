import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/citizen_schemes_provider.dart';
import '../../providers/citizen_bookmarks_provider.dart';
import '../../models/scheme_model.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../l10n/app_localizations.dart';
import 'scheme_details_screen.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  int _selectedIndex = 2; // Schemes tab is selected

  @override
  void initState() {
    super.initState();
    // Load all schemes without limit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schemesProvider = context.read<SchemesProvider>();
      schemesProvider.loadSchemes(limit: 1000); // Fetch all schemes
    });
  }

  String _getMediaUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return ''; // Return empty to show placeholder
    }
    return ApiConstants.getMediaUrl(mediaUrl);
  }

  Widget _buildSchemeCard(Scheme scheme) {
    final mediaUrl = scheme.media.isNotEmpty
        ? scheme.media.first.mediaUrl
        : null;
    final imageUrl = mediaUrl != null && mediaUrl.isNotEmpty
        ? _getMediaUrl(mediaUrl)
        : '';

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
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with bookmark
            Stack(
              children: [
                // Image
                Container(
                  height: 160.h,
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
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/schemes.png',
                                fit: BoxFit.cover,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Image.asset(
                                'assets/images/schemes.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/schemes.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                // Bookmark icon
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Consumer<BookmarksProvider>(
                    builder: (context, bookmarksProvider, child) {
                      final isBookmarked = bookmarksProvider.isSchemeBookmarked(
                        scheme.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          bookmarksProvider.toggleSchemeBookmark(
                            scheme.id,
                            !isBookmarked,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border_outlined,
                            size: 20.sp,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    scheme.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Description
                  if (scheme.description != null)
                    Text(
                      scheme.description!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schemes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<SchemesProvider>(
        builder: (context, schemesProvider, child) {
          // Show loading indicator while schemes are being fetched
          if (schemesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            );
          }

          // Show error message if failed to load
          if (schemesProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    schemesProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      schemesProvider.loadSchemes(limit: 1000);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state if no schemes
          if (schemesProvider.schemes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox, size: 64, color: Color(0xFF6B7280)),
                  SizedBox(height: 16.h),
                  const Text(
                    'No schemes available',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          // Show schemes list
          return RefreshIndicator(
            onRefresh: () async {
              await schemesProvider.loadSchemes(limit: 1000);
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: schemesProvider.schemes.length,
              itemBuilder: (context, index) {
                return _buildSchemeCard(schemesProvider.schemes[index]);
              },
            ),
          );
        },
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
              // Already on Schemes
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
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
}
