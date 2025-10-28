import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/connstants.dart';
import '../../providers/citizen_bookmarks_provider.dart';
import '../../providers/citizen_schemes_provider.dart';
import '../../providers/citizen_events_provider.dart';
import '../../models/scheme_model.dart';
import '../../models/event_model.dart';
import '../../l10n/app_localizations.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  int _selectedTabIndex = 0; // 0: Schemes, 1: Events

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

    return Container(
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
                          color: isBookmarked ? Colors.black : Colors.white,
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
                          color: isBookmarked ? Colors.white : Colors.black,
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
    );
  }

  Widget _buildTab(String label, int count, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            '$label ($count)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookmarksProvider>(
      builder: (context, bookmarksProvider, child) {
        // Get actual counts from provider
        final schemesCount = bookmarksProvider.bookmarkedSchemesCount;
        final eventsCount = bookmarksProvider.bookmarkedEventsCount;

        return _buildContent(context, schemesCount, eventsCount);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    int schemesCount,
    int eventsCount,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.bookmarks,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            children: [
              _buildTab(l10n.schemes, schemesCount, 0),
              _buildTab(l10n.events, eventsCount, 1),
            ],
          ),

          // Content based on selected tab
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildSchemesList()
                : _buildEventsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemesList() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<BookmarksProvider, SchemesProvider>(
      builder: (context, bookmarksProvider, schemesProvider, child) {
        // Get bookmarked scheme IDs
        final bookmarkedIds = bookmarksProvider.bookmarkedSchemeIds;

        // Filter schemes to show only bookmarked ones
        final bookmarkedSchemes = schemesProvider.schemes
            .where((scheme) => bookmarkedIds.contains(scheme.id))
            .toList();

        if (bookmarkedSchemes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.noBookmarkedSchemes,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
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
  }

  Widget _buildEventsList() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<BookmarksProvider, EventsProvider>(
      builder: (context, bookmarksProvider, eventsProvider, child) {
        // Get bookmarked event IDs
        final bookmarkedIds = bookmarksProvider.bookmarkedEventIds;

        // Filter events to show only bookmarked ones
        final bookmarkedEvents = eventsProvider.events
            .where((event) => bookmarkedIds.contains(event.id))
            .toList();

        if (bookmarkedEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64.sp,
                  color: const Color(0xFF6B7280),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.noBookmarkedEvents,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: bookmarkedEvents.length,
          itemBuilder: (context, index) {
            return _buildEventCard(bookmarkedEvents[index]);
          },
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
          // Event Banner
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
                                  : Colors.white.withOpacity(0.9),
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
                                  ? Colors.white
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
              color: Colors.white,
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
    );
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
    if (includeYear) {
      return DateFormat('MMM d yyyy').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
