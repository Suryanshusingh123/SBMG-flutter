import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/citizen_bookmarks_provider.dart';
import '../../models/scheme_model.dart';
import '../../l10n/app_localizations.dart';

class SchemeDetailsScreen extends StatefulWidget {
  final Scheme scheme;
  final bool initialBookmarkState;
  final Function(int schemeId, bool isBookmarked)? onBookmarkChanged;

  const SchemeDetailsScreen({
    super.key,
    required this.scheme,
    this.initialBookmarkState = false,
    this.onBookmarkChanged,
  });

  @override
  State<SchemeDetailsScreen> createState() => _SchemeDetailsScreenState();
}

class _SchemeDetailsScreenState extends State<SchemeDetailsScreen> {
  int _selectedTabIndex = 0; // Details tab by default

  String _getMediaUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return '';
    }
    return ApiConstants.getMediaUrl(mediaUrl);
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrl = widget.scheme.media.isNotEmpty
        ? widget.scheme.media.first.mediaUrl
        : null;
    final imageUrl = mediaUrl != null && mediaUrl.isNotEmpty
        ? _getMediaUrl(mediaUrl)
        : '';

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
          widget.scheme.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // Image section with bookmark
          Container(
            height: 180.h,
            width: double.infinity,
            child: Stack(
              children: [
                // Image
                imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180.h,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/schemes.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180.h,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Image.asset(
                            'assets/images/schemes.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180.h,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/schemes.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180.h,
                      ),

                // Bookmark icon
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Consumer<BookmarksProvider>(
                    builder: (context, bookmarksProvider, child) {
                      final isBookmarked = bookmarksProvider.isSchemeBookmarked(
                        widget.scheme.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          bookmarksProvider.toggleSchemeBookmark(
                            widget.scheme.id,
                            !isBookmarked,
                          );
                          // Notify parent screen about bookmark change
                          if (widget.onBookmarkChanged != null) {
                            widget.onBookmarkChanged!(
                              widget.scheme.id,
                              !isBookmarked,
                            );
                          }
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
          ),

          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTab(AppLocalizations.of(context)!.details, 0),
                ),
                Expanded(
                  child: _buildTab(AppLocalizations.of(context)!.benefits, 1),
                ),
                Expanded(
                  child: _buildTab(
                    AppLocalizations.of(context)!.eligibility,
                    2,
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDetailsContent();
      case 1:
        return _buildBenefitsContent();
      case 2:
        return _buildEligibilityContent();
      default:
        return _buildDetailsContent();
    }
  }

  Widget _buildDetailsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Text(
        widget.scheme.description ?? 'No details available',
        style: TextStyle(
          fontSize: 14.sp,
          height: 1.6,
          color: const Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildBenefitsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.scheme.benefits ?? 'No benefits information available',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.scheme.eligibility ?? 'No eligibility information available',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.6,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}
