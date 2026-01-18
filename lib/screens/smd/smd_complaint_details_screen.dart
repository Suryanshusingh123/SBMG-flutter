import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/location_display_helper.dart';
import '../../utils/date_time_utils.dart';

class SmdComplaintDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> complaint;

  const SmdComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<SmdComplaintDetailsScreen> createState() =>
      _SmdComplaintDetailsScreenState();
}

class _SmdComplaintDetailsScreenState extends State<SmdComplaintDetailsScreen> {
  // API service
  final ApiService _apiService = ApiService();

  // State for fetching complaint details
  Map<String, dynamic>? _complaintData;
  bool _isLoading = true;
  double? _latitude;
  double? _longitude;

  // Store original media data
  List<dynamic>? _originalMediaUrls;

  // Use fetched data or fallback to passed complaint
  Map<String, dynamic> get _data {
    final data = _complaintData ?? widget.complaint;
    // If media_urls is empty in fetched data but we have original, use original
    final mediaUrls = data['media_urls'] as List<dynamic>? ?? [];
    if (mediaUrls.isEmpty &&
        _originalMediaUrls != null &&
        _originalMediaUrls!.isNotEmpty) {
      data['media_urls'] = _originalMediaUrls;
    }
    return data;
  }

  @override
  void initState() {
    super.initState();
    // Store original media URLs from passed complaint
    _originalMediaUrls = widget.complaint['media_urls'] as List<dynamic>?;
    if (_originalMediaUrls == null || _originalMediaUrls!.isEmpty) {
      // Try firstMediaUrl if media_urls is empty
      final firstMediaUrl = widget.complaint['firstMediaUrl'];
      if (firstMediaUrl != null && firstMediaUrl.toString().isNotEmpty) {
        _originalMediaUrls = [firstMediaUrl];
      }
    }
    _updateCoordinatesFromData(widget.complaint);
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final complaintId = int.tryParse(widget.complaint['id'].toString());
      if (complaintId != null) {
        print('📡 Fetching complaint details for ID: $complaintId');
        final data = await _apiService.getComplaintDetails(
          complaintId: complaintId,
        );
        setState(() {
          _complaintData = data;
          _isLoading = false;
          _updateCoordinatesFromData(data);
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching complaint details: $e');
      setState(() => _isLoading = false);
    }
  }

  void _updateCoordinatesFromData(Map<String, dynamic> data) {
    final coords = LocationResolver.extractCoordinates(data);
    _latitude = coords.$1 ?? _latitude;
    _longitude = coords.$2 ?? _longitude;
  }

  // Get complaint type name for AppBar
  String get _getComplaintTypeName {
    final complaintType = _data['complaint_type'];

    // Try to determine complaint type name
    if (complaintType is Map && complaintType['name'] != null) {
      return complaintType['name'];
    } else if (complaintType is String) {
      return complaintType;
    } else if (_data['complaint_type_name'] != null) {
      return _data['complaint_type_name'];
    }
    
    // Fallback to default
    return 'Road Maintenance';
  }

  // Dynamic status text based on API fields
  String get _dynamicStatusText {
    final status = _data['status']?.toString().toUpperCase() ?? 'OPEN';

    switch (status) {
      case 'OPEN':
        return 'Complaint is open and awaiting resolution';
      case 'RESOLVED':
        return 'Complaint has been resolved';
      case 'VERIFIED':
        return 'Complaint has been verified';
      case 'CLOSED':
        return 'Complaint has been closed';
      default:
        return 'Complaint is open';
    }
  }

  // Dynamic location text based on API fields
  String _getLocationText() {
    final l10n = AppLocalizations.of(context)!;
    String? _readString(List<String> keys) {
      for (final key in keys) {
        final value = _data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
      return null;
    }

    return LocationDisplayHelper.buildDisplay(
      cacheKey: 'smd-detail-${_data['id']}',
      latitude: _latitude,
      longitude: _longitude,
      locationField: _readString(['location', 'Location']),
      district: _readString(['district_name', 'districtName']),
      block: _readString(['block_name', 'blockName']),
      village: _readString(['village_name', 'villageName']),
      scheduleUpdate: () {
        if (!mounted) return;
        setState(() {});
      },
      unavailableLabel: l10n.locationNotAvailable,
    );
  }

  // Dynamic status color based on current state
  Color get _dynamicStatusColor {
    final status = _data['status']?.toString().toUpperCase() ?? 'OPEN';

    switch (status) {
      case 'CLOSED':
        return const Color(0xFF10B981); // Green for closed
      case 'VERIFIED':
        return const Color(0xFF3B82F6); // Blue for verified
      case 'RESOLVED':
        return const Color(0xFFF59E0B); // Orange for resolved
      case 'OPEN':
      default:
        return const Color(0xFFEF4444); // Red for open
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

    print('📱 COMPLAINT DETAILS SCREEN LOADED:');
    print('   - Complaint ID: ${_data['id']}');
    print('   - Complaint Status: ${_data['status']}');
    print('   - Media URLs: ${_data['media_urls']}');
    print('   - Comments: ${_data['comments']}');

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
              _getComplaintTypeName,
              style: const TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              '${_data['district_name'] ?? 'District'} | ${_data['block_name'] ?? 'Block'} | ${_data['village_name'] ?? 'GP'}',
              style: const TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            _buildStatusBanner(),

            const SizedBox(height: 20),

            // Images
            _buildImages(),

            const SizedBox(height: 20),

            // Complaint Details
            _buildComplaintDetails(),

            const SizedBox(height: 20),

            // Timeline
            _buildTimeline(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _data['status']?.toString().toLowerCase() ?? 'open';
    final isCompleted =
        status == 'resolved' || status == 'verified' || status == 'closed';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
                width: 2,
              ),
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dynamicStatusText,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _dynamicStatusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_data['created_at']),
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages() {
    // Try to get media_urls first, then fallback to firstMediaUrl
    List<dynamic> mediaUrls = _data['media_urls'] as List<dynamic>? ?? [];

    // If media_urls is empty, try to use firstMediaUrl from toMap
    if (mediaUrls.isEmpty &&
        _data['firstMediaUrl'] != null &&
        _data['firstMediaUrl'].toString().isNotEmpty) {
      mediaUrls = [_data['firstMediaUrl']];
    }

    print('🖼️ BUILDING IMAGES (Complaint Details):');
    print('   - Complaint ID: ${_data['id']}');
    print('   - Media URLs count: ${mediaUrls.length}');
    print('   - Media URLs: $mediaUrls');
    print('   - FirstMediaUrl from data: ${_data['firstMediaUrl']}');

    if (mediaUrls.isEmpty) {
      print('   - No media URLs found, showing placeholder');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade50,
        ),
        child: const Center(
          child: Text(
            'No images available',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    if (mediaUrls.length == 1) {
      print('   - Single image found, loading network image');
      print('   - Image URL: ${mediaUrls.first}');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _buildMediaUrl(mediaUrls.first.toString()),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('❌ IMAGE LOAD ERROR (Complaint Details):');
              print('   - Error: $error');
              print('   - StackTrace: $stackTrace');
              return Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print('✅ IMAGE LOADED SUCCESSFULLY (Complaint Details)');
                return child;
              }
              print(
                '⏳ LOADING IMAGE (Complaint Details): ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}',
              );
              return Container(
                color: Colors.grey.shade100,
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      );
    }

    // Multiple images - show first two in a row
    print(
      '   - Multiple images found (${mediaUrls.length}), showing first two',
    );
    print('   - First image URL: ${mediaUrls[0]}');
    print('   - Second image URL: ${mediaUrls[1]}');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _buildMediaUrl(mediaUrls[0].toString()),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
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
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _buildMediaUrl(mediaUrls[1].toString()),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
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

  // Helper method to build media URL using ApiConstants
  String _buildMediaUrl(String mediaPath) {
    print('🖼️ MEDIA URL DEBUG (Complaint Details):');
    print('   - Input path: $mediaPath');

    // Use ApiConstants helper method for proper URL encoding
    final finalUrl = ApiConstants.getMediaUrl(mediaPath);

    print('   - Final URL: $finalUrl');

    return finalUrl;
  }

  Widget _buildComplaintDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _data['complaint_type'] ?? 'Road Maintenance',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getLocationText(),
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                _formatDate(_data['created_at']),
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _data['description'] ?? 'No description available.',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Timeline data helpers
  List<Map<String, dynamic>> get _timelineItems {
    List<Map<String, dynamic>> items = [];

    final createdAt = _data['created_at'];
    final resolvedAt = _data['resolved_at'];
    final verifiedAt = _data['verified_at'];
    final closedAt = _data['closed_at'];

    // Check if there's a resolution comment
    final hasResolutionComment = _hasResolutionComment;
    final hasVerificationComment = _hasVerificationComment;

    // Always add complaint created item
    items.add({
      'title': 'Complaint created',
      'subtitle': _formatTimelineSubtitle('Citizen', createdAt),
      'isCompleted': true,
      'showLine':
          resolvedAt != null ||
          verifiedAt != null ||
          closedAt != null ||
          hasResolutionComment ||
          hasVerificationComment,
      'onTap': null,
    });

    // Add resolved item if resolved_at is present or has resolution comment
    if (resolvedAt != null || hasResolutionComment) {
      items.add({
        'title': 'Resolved',
        'subtitle': _formatTimelineSubtitle(
          'Vendor / Supervisor',
          resolvedAt ?? _getResolutionDateFromComments(),
        ),
        'isCompleted': true,
        'showLine':
            verifiedAt != null || closedAt != null || hasVerificationComment,
        'onTap': null,
      });
    }

    // Add verified item if verified_at is present or has verification comment
    if (verifiedAt != null || hasVerificationComment) {
      items.add({
        'title': 'Verified',
        'subtitle': _formatTimelineSubtitle(
          'VDO',
          verifiedAt ?? _getVerificationDateFromComments(),
        ),
        'isCompleted': true,
        'showLine': closedAt != null,
        'onTap': null,
      });
    }

    // Add closed item if closed_at is present
    if (closedAt != null) {
      items.add({
        'title': AppLocalizations.of(context)!.closed,
        'subtitle': _formatTimelineSubtitle('Citizen', closedAt),
        'isCompleted': true,
        'showLine': false, // Last item, no line needed
        'onTap': null,
      });
    }

    return items;
  }

  String _formatTimelineSubtitle(String user, String? dateString) {
    String formattedDate = DateTimeUtils.formatDateStringIST(dateString);
    if (formattedDate == 'Unknown') {
      formattedDate = 'Unknown date';
    }
    return '$user • $formattedDate';
  }

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          ..._timelineItems.map(
            (item) => _buildTimelineItem(
              item['title'],
              item['subtitle'],
              item['isCompleted'],
              showLine: item['showLine'],
              onTap: item['onTap'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted, {
    bool showLine = true,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            if (showLine)
              Container(width: 2, height: 40, color: const Color(0xFF10B981)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          GestureDetector(
            onTap: onTap,
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    final formatted = DateTimeUtils.formatDateStringIST(dateStr);
    return formatted;
  }

  // Helper methods to check for resolution/verification comments
  bool get _hasResolutionComment {
    final comments = _data['comments'] as List<dynamic>? ?? [];
    return comments.any(
      (comment) =>
          comment['comment'].toString().toUpperCase().contains('[RESOLVED]'),
    );
  }

  bool get _hasVerificationComment {
    final comments = _data['comments'] as List<dynamic>? ?? [];
    return comments.any(
      (comment) =>
          comment['comment'].toString().toUpperCase().contains('[VERIFIED]'),
    );
  }

  String _getResolutionDateFromComments() {
    final comments = _data['comments'] as List<dynamic>? ?? [];
    for (final comment in comments) {
      if (comment['comment'].toString().toUpperCase().contains('[RESOLVED]')) {
        return comment['commented_at'] ?? '';
      }
    }
    return '';
  }

  String _getVerificationDateFromComments() {
    final comments = _data['comments'] as List<dynamic>? ?? [];
    for (final comment in comments) {
      if (comment['comment'].toString().toUpperCase().contains('[VERIFIED]')) {
        return comment['commented_at'] ?? '';
      }
    }
    return '';
  }
}
