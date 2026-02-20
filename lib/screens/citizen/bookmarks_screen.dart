import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/bookmarks_provider.dart';
import '../../models/scheme_model.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/citizen_colors.dart';
import '../../services/auth_services.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Load bookmarked schemes from API when screen opens so bookmarks
    // added from scheme details page show up without visiting schemes list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksProvider>().loadBookmarkedSchemesList();
    });
  }
  String _getMediaUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return '';
    }
    return ApiConstants.getMediaUrl(mediaUrl);
  }

  Widget _buildBookmarkCard(Scheme scheme) {
    final mediaUrl = scheme.media.isNotEmpty
        ? scheme.media.first.mediaUrl
        : null;
    final imageUrl = mediaUrl != null && mediaUrl.isNotEmpty
        ? _getMediaUrl(mediaUrl)
        : '';
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                      onTap: () async {
                        // Check if user is logged in
                        final authService = AuthService();
                        final isLoggedIn = await authService.isLoggedIn();
                        
                        if (!isLoggedIn) {
                          // Show login required message (hide after 5s; action snackbars often ignore duration)
                          if (mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please login to bookmark schemes',
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: 'Login',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/citizen-login',
                                      arguments: {'redirectTo': '/schemes'},
                                    );
                                  },
                                ),
                              ),
                            );
                            Future.delayed(const Duration(seconds: 5), () {
                              messenger.hideCurrentSnackBar();
                            });
                          }
                          return;
                        }

                        try {
                          await bookmarksProvider.toggleSchemeBookmark(
                            scheme.id,
                            !isBookmarked,
                          );
                        } catch (e) {
                          // Show error message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: isBookmarked ? Colors.black : surfaceColor,
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
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20.sp,
                          color: isBookmarked
                              ? CitizenColors.light
                              : primaryTextColor,
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
                    color: primaryTextColor,
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
                      color: secondaryTextColor,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    return Scaffold(
      backgroundColor: CitizenColors.background(context),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.myCollection,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildSchemesList(),
    );
  }

  Widget _buildSchemesList() {
    final l10n = AppLocalizations.of(context)!;
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Consumer<BookmarksProvider>(
      builder: (context, bookmarksProvider, child) {
        // Check if user is logged in
        return FutureBuilder<bool>(
          future: AuthService().isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final isLoggedIn = snapshot.data ?? false;

            // If not logged in, show login prompt
            if (!isLoggedIn) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 64.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Please login to view your bookmarks',
                      style: TextStyle(fontSize: 16.sp, color: secondaryTextColor),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/citizen-login',
                          arguments: {'redirectTo': '/schemes'},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: CitizenColors.light,
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                      ),
                      child: Text('Login'),
                    ),
                  ],
                ),
              );
            }

            // Show loading while fetching bookmarked schemes from API
            if (bookmarksProvider.isLoadingBookmarkedList) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Use list from API so bookmarks added from scheme details page show up
            final bookmarkedSchemes = bookmarksProvider.bookmarkedSchemeList;

            if (bookmarkedSchemes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64.sp,
                      color: secondaryTextColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.noBookmarkedSchemes,
                      style: TextStyle(fontSize: 16.sp, color: secondaryTextColor),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: bookmarkedSchemes.length,
              itemBuilder: (context, index) {
                return _buildBookmarkCard(bookmarkedSchemes[index]);
              },
            );
          },
        );
      },
    );
  }
}
