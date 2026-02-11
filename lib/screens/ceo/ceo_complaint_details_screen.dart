import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../providers/ceo_complaints_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/location_display_helper.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/resolution_details_sheet.dart';

class CeoComplaintDetailsScreen extends StatefulWidget {
  final int complaintId;

  const CeoComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<CeoComplaintDetailsScreen> createState() =>
      _CeoComplaintDetailsScreenState();
}

class _CeoComplaintDetailsScreenState extends State<CeoComplaintDetailsScreen> {
  // API service
  final ApiService _apiService = ApiService();

  // State for fetching complaint details
  Map<String, dynamic>? _complaintData;
  bool _isLoading = true;
  bool _loadFailed = false;
  double? _latitude;
  double? _longitude;

  // State for resolution bottom sheet
  // ignore: unused_field
  final TextEditingController _resolutionCommentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final data = await _apiService.getComplaintDetails(
        complaintId: widget.complaintId,
      );

      final coords = LocationResolver.extractCoordinates(data);

      setState(() {
        _complaintData = data;
        _isLoading = false;
        _latitude = coords.$1;
        _longitude = coords.$2;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  String _getComplaintTypeDisplay(BuildContext context) {
    final name = _getComplaintTypeName;
    return name == 'Road Maintenance'
        ? AppLocalizations.of(context)!.roadMaintenance
        : name;
  }

  String get _getComplaintTypeName {
    final complaintType = _complaintData?['complaint_type'];

    // Try to determine complaint type name
    if (complaintType is Map && complaintType['name'] != null) {
      return complaintType['name'];
    } else if (complaintType is String && complaintType.trim().isNotEmpty) {
      return complaintType.trim();
    } else if (_complaintData?['complaint_type_name'] != null) {
      return _complaintData!['complaint_type_name'];
    }

    // Resolve from complaint_type_id when API returns id but not type name
    final typeId = _complaintData?['complaint_type_id'];
    if (typeId != null && context.mounted) {
      final id = typeId is int ? typeId : int.tryParse(typeId.toString());
      if (id != null) {
        final resolved = context.read<CeoComplaintsProvider>().getComplaintTypeNameById(id);
        if (resolved != null && resolved.isNotEmpty) return resolved;
      }
    }

    // Fallback to default
    return 'Road Maintenance';
  }

  String get _dynamicStatusText {
    final status = _complaintData?['status_id'];
    final closedAt = _complaintData?['closed_at'];
    final verifiedAt = _complaintData?['verified_at'];
    final resolvedAt = _complaintData?['resolved_at'];

    final l10n = AppLocalizations.of(context)!;

    // First check if closed
    if (status == 4 || closedAt != null) {
      return l10n.complaintHasBeenClosed;
    }

    // Then check if verified but not closed - show awaiting citizen message
    if (status == 3 || (verifiedAt != null && closedAt == null)) {
      return l10n.awaitingForCitizenToCloseComplaint;
    }

    // Then check if resolved but not verified - show awaiting VDO message
    if (status == 2 || (resolvedAt != null && verifiedAt == null)) {
      return l10n.awaitingForVdoToVerify;
    }

    // Open status - show awaiting supervisor message
    return l10n.awaitingForSupervisorToTakeAction;
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
        return const Color(0xFFF59E0B); // Orange for resolved
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

    if (_loadFailed || _complaintData == null) {
      final l10n = AppLocalizations.of(context)!;
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
                l10n.failedToLoadComplaintDetails,
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
              _getComplaintTypeDisplay(context),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            Text(
              '${_complaintData!['district_name'] ?? AppLocalizations.of(context)!.district}',
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
            AppLocalizations.of(context)!.noImagesAvailable,
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
    final l10n = AppLocalizations.of(context)!;
    final complaintType = _complaintData?['complaint_type'];

    // Try to determine complaint type name
    String complaintTypeName = 'Road Maintenance';
    if (complaintType is Map && complaintType['name'] != null) {
      complaintTypeName = complaintType['name'];
    } else if (complaintType is String && complaintType.trim().isNotEmpty) {
      complaintTypeName = complaintType.trim();
    } else {
      // Resolve from complaint_type_id when API returns id but not type name
      final typeId = _complaintData?['complaint_type_id'];
      if (typeId != null && context.mounted) {
        final id = typeId is int ? typeId : int.tryParse(typeId.toString());
        if (id != null) {
          final resolved = context.read<CeoComplaintsProvider>().getComplaintTypeNameById(id);
          if (resolved != null && resolved.isNotEmpty) complaintTypeName = resolved;
        }
      }
    }
    final displayTypeName = complaintTypeName == 'Road Maintenance'
        ? l10n.roadMaintenance
        : complaintTypeName;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayTypeName,
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
            _complaintData?['description'] ?? AppLocalizations.of(context)!.noDescriptionAvailable,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),

          // Get Directions Button
          if (_latitude != null && _longitude != null)
            GestureDetector(
              onTap: () {
                _openGoogleMaps(
                  _latitude,
                  _longitude,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/map.png',
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      AppLocalizations.of(context)!.getDirections,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
              onTap: () => _onTimelineStageTap(item),
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
      'subtitle': _formatTimelineSubtitle(AppLocalizations.of(context)!.citizen, createdAt),
      'isCompleted': true,
      'showLine':
          resolvedAt != null ||
          verifiedAt != null ||
          closedAt != null ||
          hasResolutionComment ||
          hasVerificationComment,
      'stage': 'created',
    });

    // Add resolved if present
    if (resolvedAt != null || hasResolutionComment) {
      items.add({
        'title': l10n.resolved,
        'subtitle': _formatTimelineSubtitle(l10n.contractorSupervisor, resolvedAt),
        'isCompleted': true,
        'showLine':
            verifiedAt != null || closedAt != null || hasVerificationComment,
        'stage': 'resolved',
      });
    }

    // Add verified if present
    if (verifiedAt != null || hasVerificationComment) {
      items.add({
        'title': l10n.verified,
        'subtitle': _formatTimelineSubtitle(AppLocalizations.of(context)!.vdo, verifiedAt),
        'isCompleted': true,
        'showLine': closedAt != null,
        'stage': 'verified',
      });
    }

    // Add closed if present
    if (closedAt != null) {
      items.add({
        'title': l10n.closed,
        'subtitle': _formatTimelineSubtitle(AppLocalizations.of(context)!.citizen, closedAt),
        'isCompleted': true,
        'showLine': false,
        'stage': 'closed',
      });
    }

    return items;
  }

  String _formatTimelineSubtitle(String user, String? dateString) {
    final l10n = AppLocalizations.of(context)!;
    String formattedDate = DateTimeUtils.formatComplaintDetailIST(dateString);
    if (formattedDate == 'Unknown') {
      formattedDate = l10n.unknownDate;
    }
    return '$user · $formattedDate';
  }

  void _onTimelineStageTap(Map<String, dynamic> item) {
    final stage = item['stage'] as String?;
    if (stage == 'resolved') {
      ResolutionDetailsSheet.show(context, _complaintData);
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(item['title'] as String),
          content: Text(item['subtitle'] as String),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted, {
    bool showLine = true,
    VoidCallback? onTap,
  }) {
    final content = Row(
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
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: content,
      );
    }
    return content;
  }

  String _formatDate(String? date) {
    final l10n = AppLocalizations.of(context)!;
    if (date == null) return l10n.na;
    final formatted = DateTimeUtils.formatComplaintDetailIST(date);
    return formatted == 'Unknown' ? l10n.na : formatted;
  }

  String _getLocationDisplay() {
    final l10n = AppLocalizations.of(context)!;
    return LocationDisplayHelper.buildDisplay(
      cacheKey: 'ceo-detail-${widget.complaintId}',
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

    const mode = LaunchMode.externalApplication;
    // Use directions URL so Maps opens the "Get directions" screen, not just the pin
    final directionsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$long',
    );
    final geoUri = Uri.parse('geo:0,0?q=$lat,$long');

    try {
      bool launched = false;
      try {
        launched = await launchUrl(directionsUrl, mode: mode);
      } catch (_) {}
      if (!launched) {
        launched = await launchUrl(geoUri, mode: mode);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpenGoogleMaps,
            ),
          ),
        );
      }
    } catch (e) {
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
  }
}
