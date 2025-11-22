import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/location_display_helper.dart';

class VdoComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;

  const VdoComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<VdoComplaintDetailsScreen> createState() =>
      _VdoComplaintDetailsScreenState();
}

class _VdoComplaintDetailsScreenState extends State<VdoComplaintDetailsScreen> {
  // API service
  final ApiService _apiService = ApiService();

  // State for fetching complaint details
  Map<String, dynamic>? _complaintData;
  bool _isLoading = true;
  String? _errorMessage;
  double? _latitude;
  double? _longitude;

  // State for resolution bottom sheet
  final TextEditingController _resolutionCommentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      print('📡 Fetching complaint details for ID: ${widget.complaintId}');
      final data = await _apiService.getComplaintDetails(
        complaintId: widget.complaintId,
      );

      final coords = LocationResolver.extractCoordinates(data);

      // Log the lat and long values
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📍 Location Data from API:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('   - lat: ${coords.$1}');
      print('   - long: ${coords.$2}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      setState(() {
        _complaintData = data;
        _isLoading = false;
        _latitude = coords.$1;
        _longitude = coords.$2;
      });
    } catch (e) {
      print('❌ Error fetching complaint details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load complaint details';
      });
    }
  }

  String get _getStatusHeading {
    final status = _complaintData?['status_id'];
    final closedAt = _complaintData?['closed_at'];
    final verifiedAt = _complaintData?['verified_at'];
    final resolvedAt = _complaintData?['resolved_at'];

    // First check if closed
    if (status == 4 || closedAt != null) {
      return 'Successfully disposed';
    }

    // Then check if verified but not closed
    if (status == 3 || (verifiedAt != null && closedAt == null)) {
      return 'Successfully resolved, waiting for user to close';
    }

    // Then check if resolved
    if (status == 2 || resolvedAt != null) {
      return 'Verification pending by VDO';
    }

    // Open status
    return 'Waiting for supervisor to resolve';
  }

  String get _dynamicStatusText {
    final status = _complaintData?['status_id'];
    final closedAt = _complaintData?['closed_at'];
    final verifiedAt = _complaintData?['verified_at'];
    final resolvedAt = _complaintData?['resolved_at'];

    print('🔍 Status Check: status_id = $status');
    print('🔍 Status Check: verified_at = $verifiedAt');
    print('🔍 Status Check: closed_at = $closedAt');

    final l10n = AppLocalizations.of(context)!;

    // First check if closed
    if (status == 4 || closedAt != null) {
      return l10n.complaintResolved;
    }

    // Then check if verified but not closed
    if (status == 3 || (verifiedAt != null && closedAt == null)) {
      return l10n.complaintVerified;
    }

    // Then check if resolved
    if (status == 2 || resolvedAt != null) {
      return l10n.waitingVerificationFromVdo;
    }

    // Open status
    return l10n.waitingForSupervisorToResolve;
  }

  String get _dynamicStatusSubtext {
    final status = _complaintData?['status_id'];
    final closedAt = _complaintData?['closed_at'];
    final verifiedAt = _complaintData?['verified_at'];
    final resolvedAt = _complaintData?['resolved_at'];
    final createdAt = _complaintData?['created_at'];

    final l10n = AppLocalizations.of(context)!;

    // If closed, show "Closed at" date
    if (status == 4 || closedAt != null) {
      if (closedAt != null) {
        return _formatDate(closedAt);
      }
      return l10n.closed;
    }

    // If verified but not closed, show "Verified at" date
    if (status == 3 || (verifiedAt != null && closedAt == null)) {
      if (verifiedAt != null) {
        return _formatDate(verifiedAt);
      }
      return l10n.verified;
    }

    // If resolved, show "Resolved at" date
    if (status == 2 || resolvedAt != null) {
      if (resolvedAt != null) {
        return _formatDate(resolvedAt);
      }
      return l10n.resolved;
    }

    // Open status - show "Created at" date
    if (status == 1 && createdAt != null) {
      return _formatDate(createdAt);
    }

    return l10n.complaintCreated;
  }

  Color get _dynamicStatusColor {
    final status = _complaintData?['status_id'];

    // If closed, return green
    if (status == 4 || _complaintData?['closed_at'] != null) {
      return const Color(0xFF10B981);
    }

    // If verified but not closed, return blue
    if (status == 3 ||
        (_complaintData?['verified_at'] != null &&
            _complaintData?['closed_at'] == null)) {
      return const Color(0xFF3B82F6);
    }

    switch (status) {
      case 4:
        return const Color(0xFF10B981); // Green for closed
      case 3:
        return const Color(0xFF3B82F6); // Blue for verified
      case 2:
        return const Color(0xFFF59E0B); // Green for resolved
      case 1:
      default:
        return const Color(0xFFF59E0B); // Orange for open
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF009B56)),
          ),
        ),
      );
    }

    // Only show error screen if we don't have complaint data
    // If we have data but error message exists, it's likely from a refresh failure
    // and we should still show the complaint details
    if (_complaintData == null && _errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                _errorMessage ?? 'Failed to load complaint details',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStatusHeading,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              '${_complaintData!['district_name'] ?? 'District'} | ${_complaintData!['block_name'] ?? 'Block'} | ${_complaintData!['village_name'] ?? 'GP'}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            // Status Banner
            _buildStatusBanner(),

            SizedBox(height: 20.h),

            // Images
            _buildImages(),

            SizedBox(height: 20.h),

            // Complaint Details
            _buildComplaintDetails(),

            SizedBox(height: 20.h),

            // Timeline
            _buildTimeline(),

            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildMarkCompletedButton(),
    );
  }

  Widget _buildStatusBanner() {
    final statusId = _complaintData?['status_id'];
    final verifiedAt = _complaintData?['verified_at'];
    final closedAt = _complaintData?['closed_at'];

    // Determine background and border colors based on status
    Color backgroundColor;
    Color borderColor;
    bool isClosed;

    // Check if complaint is closed
    isClosed = statusId == 4 || closedAt != null;

    // Check if complaint is verified but not closed
    final isVerified =
        statusId == 3 || (verifiedAt != null && closedAt == null);

    if (isClosed) {
      backgroundColor = const Color(0xFFD1FAE5); // Green for closed
      borderColor = const Color(0xFF10B981);
    } else if (isVerified) {
      backgroundColor = const Color(0xFFDBEAFE); // Light blue for verified
      borderColor = const Color(0xFF3B82F6);
    } else {
      backgroundColor = const Color(0xFFFFF3CD); // Orange for pending
      borderColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: _dynamicStatusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isClosed ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 14.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dynamicStatusText,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _dynamicStatusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dynamicStatusSubtext,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 16.sp),
        ],
      ),
    );
  }

  Widget _buildImages() {
    final media = _complaintData?['media'] as List<dynamic>? ?? [];

    if (media.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Text(
            'No images available',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
          ),
        ),
      );
    }

    if (media.length == 1) {
      final mediaUrl = ApiConstants.getMediaUrl(media[0]['media_url']);
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        height: 200.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            mediaUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50.sp,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      );
    }

    // Multiple images
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  ApiConstants.getMediaUrl(media[0]['media_url']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50.sp,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  media.length > 1
                      ? ApiConstants.getMediaUrl(media[1]['media_url'])
                      : ApiConstants.getMediaUrl(media[0]['media_url']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50.sp,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintDetails() {
    final complaintType = _complaintData?['complaint_type'];

    // Try to determine complaint type name
    String complaintTypeName = 'Road Maintenance';
    if (complaintType is Map && complaintType['name'] != null) {
      complaintTypeName = complaintType['name'];
    } else if (complaintType is String) {
      complaintTypeName = complaintType;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                complaintTypeName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                _formatDate(_complaintData?['created_at']),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 18),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _getLocationDisplay(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Text(
            _complaintData?['description'] ?? 'No description available',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  String _getLocationDisplay() {
    final l10n = AppLocalizations.of(context)!;
    return LocationDisplayHelper.buildDisplay(
      cacheKey: 'vdo-detail-${widget.complaintId}',
      latitude: _latitude,
      longitude: _longitude,
      locationField: _complaintData?['location'] as String?,
      district: _complaintData?['district_name'] as String?,
      block: _complaintData?['block_name'] as String?,
      village: _complaintData?['village_name'] as String?,
      scheduleUpdate: () {
        if (!mounted) return;
        setState(() {});
      },
      unavailableLabel: l10n.locationNotAvailable,
    );
  }

  Widget _buildTimeline() {
    final timelineItems = _buildTimelineItems();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.timeline,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          ...timelineItems.map(
            (item) => _buildTimelineItem(
              item['title'],
              item['subtitle'],
              item['isCompleted'],
              showLine: item['showLine'],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimelineItems() {
    List<Map<String, dynamic>> items = [];

    final createdAt = _complaintData?['created_at'];
    final resolvedAt = _complaintData?['resolved_at'];
    final verifiedAt = _complaintData?['verified_at'];
    final closedAt = _complaintData?['closed_at'];

    // Check comments for resolution/verification
    final comments = _complaintData?['comments'] as List<dynamic>? ?? [];
    final hasResolutionComment = comments.any(
      (comment) =>
          comment['comment'].toString().toUpperCase().contains('[RESOLVED]'),
    );
    final hasVerificationComment = comments.any(
      (comment) =>
          comment['comment'].toString().toUpperCase().contains('[VERIFIED]'),
    );

    final l10n = AppLocalizations.of(context)!;

    // Always add complaint created
    items.add({
      'title': l10n.complaintCreated,
      'subtitle': _formatTimelineSubtitle('Citizen', createdAt),
      'isCompleted': true,
      'showLine':
          resolvedAt != null ||
          verifiedAt != null ||
          closedAt != null ||
          hasResolutionComment ||
          hasVerificationComment,
    });

    // Add resolved if present
    if (resolvedAt != null || hasResolutionComment) {
      items.add({
        'title': l10n.resolved,
        'subtitle': _formatTimelineSubtitle('Vendor / Supervisor', resolvedAt),
        'isCompleted': true,
        'showLine':
            verifiedAt != null || closedAt != null || hasVerificationComment,
      });
    }

    // Add verified if present
    if (verifiedAt != null || hasVerificationComment) {
      items.add({
        'title': l10n.verified,
        'subtitle': _formatTimelineSubtitle('VDO', verifiedAt),
        'isCompleted': true,
        'showLine': closedAt != null,
      });
    }

    // Add closed if present
    if (closedAt != null) {
      items.add({
        'title': l10n.closed,
        'subtitle': _formatTimelineSubtitle('Citizen', closedAt),
        'isCompleted': true,
        'showLine': false,
      });
    }

    return items;
  }

  String _formatTimelineSubtitle(String user, String? dateString) {
    String formattedDate = 'Unknown date';
    if (dateString != null && dateString.isNotEmpty) {
      try {
        // Parse the UTC date
        final date = DateTime.parse(dateString);

        // Convert to IST (UTC+5:30)
        final istDate = date.add(const Duration(hours: 5, minutes: 30));

        formattedDate = DateFormat('MMM d, yyyy, h:mm a').format(istDate);
      } catch (e) {
        formattedDate = 'Unknown date';
      }
    }
    return '$user · $formattedDate';
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted, {
    bool showLine = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            if (showLine)
              Container(
                width: 2.w,
                height: 40.h,
                color: const Color(0xFF10B981),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      // Convert to IST (UTC+5:30)
      final istDate = dateTime.add(const Duration(hours: 5, minutes: 30));
      return DateFormat('MMM d, yyyy').format(istDate);
    } catch (e) {
      return date;
    }
  }

  // ignore: unused_element
  Future<void> _openGoogleMaps(double? lat, double? long) async {
    if (lat == null || long == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationNotAvailable),
          ),
        );
      }
      return;
    }

    // Create Google Maps URL with lat/long
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$long',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.couldNotOpenGoogleMaps,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    }
  }

  Widget _buildMarkCompletedButton() {
    final statusId = _complaintData?['status_id'];

    // Show button when status is resolved (VDO can verify resolved complaints)
    if (statusId != 2) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleSeeResolution,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.seeResolution,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _handleSeeResolution() {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔍 VDO SEE RESOLUTION: Opening bottom sheet');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🆔 Complaint ID: ${widget.complaintId}');

    // Clear the comment controller for new comment
    _resolutionCommentController.clear();

    // Get resolution data from complaint data
    final resolvedAt = _complaintData?['resolved_at'];
    final comments = _complaintData?['comments'] as List<dynamic>? ?? [];
    final media = _complaintData?['media'] as List<dynamic>? ?? [];

    print('📅 Resolved At: $resolvedAt');
    print('💬 Total Comments: ${comments.length}');
    print('🖼️ Total Media: ${media.length}');

    // Find resolution comment (comment with [RESOLVED] prefix or after resolved_at)
    String? resolutionComment;
    if (comments.isNotEmpty) {
      final resolvedComments = comments.where((comment) {
        final commentText = comment['comment']?.toString().toUpperCase() ?? '';
        return commentText.contains('[RESOLVED]');
      }).toList();

      print('🔍 Found ${resolvedComments.length} resolved comment(s)');

      if (resolvedComments.isNotEmpty) {
        // Get the latest resolved comment
        resolvedComments.sort((a, b) {
          final aDate = DateTime.tryParse(a['commented_at'] ?? '');
          final bDate = DateTime.tryParse(b['commented_at'] ?? '');
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });
        resolutionComment = resolvedComments.first['comment'];
        print('✅ Resolution Comment Found: $resolutionComment');
      } else {
        print('⚠️ No resolution comment found');
      }
    } else {
      print('⚠️ No comments available');
    }

    // Find resolution image (media uploaded after resolved_at)
    String? resolutionImageUrl;
    if (resolvedAt != null && media.isNotEmpty) {
      final resolvedDateTime = DateTime.parse(resolvedAt);
      print('📅 Resolved DateTime: $resolvedDateTime');

      final resolutionMedia = media.where((m) {
        final uploadedAt = DateTime.tryParse(m['uploaded_at'] ?? '');
        if (uploadedAt == null) return false;
        return uploadedAt.isAfter(resolvedDateTime);
      }).toList();

      print(
        '🔍 Found ${resolutionMedia.length} media uploaded after resolution',
      );

      if (resolutionMedia.isNotEmpty) {
        // Get the latest resolution media
        resolutionMedia.sort((a, b) {
          final aDate = DateTime.tryParse(a['uploaded_at'] ?? '');
          final bDate = DateTime.tryParse(b['uploaded_at'] ?? '');
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });
        resolutionImageUrl = resolutionMedia.first['media_url'];
        print('✅ Resolution Image Found: $resolutionImageUrl');
      } else {
        print('⚠️ No resolution image found (no media after resolved_at)');
      }
    } else {
      if (resolvedAt == null) {
        print('⚠️ No resolved_at timestamp, cannot find resolution image');
      }
      if (media.isEmpty) {
        print('⚠️ No media available');
      }
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📊 Resolution Summary:');
    print(
      '   - Resolution Comment: ${resolutionComment != null ? "✅ Available" : "❌ Not Available"}',
    );
    print(
      '   - Resolution Image: ${resolutionImageUrl != null ? "✅ Available" : "❌ Not Available"}',
    );
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => _ResolutionBottomSheet(
          commentController: _resolutionCommentController,
          resolutionComment: resolutionComment,
          resolutionImageUrl: resolutionImageUrl,
          onSubmitted: () {
            _submitVerification();
          },
        ),
      ),
    );
  }

  Future<void> _submitVerification() async {
    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔵 VDO VERIFICATION: Submit Verification');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🆔 Complaint ID: ${widget.complaintId}');
      print('💬 Comment: ${_resolutionCommentController.text}');
      print('📁 Media Files: null (not sending media)');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Call verify API with comment only (no media for now)
      await _apiService.verifyComplaint(
        complaintId: widget.complaintId,
        comment: _resolutionCommentController.text,
        mediaFiles: null,
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🟢 VDO VERIFICATION: Success');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ Complaint verified successfully');
      print('🆔 Complaint ID: ${widget.complaintId}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Close bottom sheet
      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint verified successfully'),
            backgroundColor: AppColors.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear any previous error message before refreshing
        setState(() {
          _errorMessage = null;
        });

        // Refresh complaint details
        print('🔄 Refreshing complaint details...');
        try {
          await _fetchComplaintDetails();
          print('✅ Complaint details refreshed');
        } catch (refreshError) {
          print('⚠️ Failed to refresh complaint details: $refreshError');
          // If refresh fails but we have existing data, don't show error screen
          // Just show a warning snackbar
          if (_complaintData != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Complaint verified, but failed to refresh details'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            // Don't set error message if we have existing data
            setState(() {
              _errorMessage = null;
            });
          }
        }
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ VDO VERIFICATION: Error');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🆔 Complaint ID: ${widget.complaintId}');
      print('💥 Error: $e');
      print('💥 Error Type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify complaint: $e')),
        );
      }
    }
  }
}

class _ResolutionBottomSheet extends StatelessWidget {
  final TextEditingController commentController;
  final String? resolutionComment;
  final String? resolutionImageUrl;
  final VoidCallback onSubmitted;

  const _ResolutionBottomSheet({
    required this.commentController,
    required this.resolutionComment,
    required this.resolutionImageUrl,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.resolution,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Resolution Image (if available)
              if (resolutionImageUrl != null)
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      ApiConstants.getMediaUrl(resolutionImageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50.sp,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Resolution Comment (if available)
              if (resolutionComment != null) ...[
                if (resolutionImageUrl != null) SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    resolutionComment!.replaceAll('[RESOLVED]', '').trim(),
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      color: const Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 24.h),

              // Comment section
              Text(
                AppLocalizations.of(context)!.comment,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: commentController,
                  maxLines: 4,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    )!.writeYourCommentHere,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.r),
                  ),
                  style: const TextStyle(fontFamily: 'Noto Sans', fontSize: 14),
                ),
              ),
              SizedBox(height: 20.h),

              // Mark as completed button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      onSubmitted();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.markCompleted,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
