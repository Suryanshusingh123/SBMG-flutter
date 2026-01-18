import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../theme/citizen_colors.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../providers/citizen_auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/date_time_utils.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  // API service
  final ApiService _apiService = ApiService();

  // State for fetching complaint details
  Map<String, dynamic>? _complaintData;
  bool _isLoading = true;
  String? _errorMessage;
  double? _latitude;
  double? _longitude;
  String? _reverseGeocodedAddress;
  bool _isReverseGeocoding = false;
  bool _reverseGeocodeFailed = false;

  // Feedback controller
  final TextEditingController _feedbackController = TextEditingController();

  Color get _primaryTextColor => CitizenColors.textPrimary(context);
  Color get _secondaryTextColor => CitizenColors.textSecondary(context);

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      final complaintId = int.tryParse(widget.complaintId);
      if (complaintId != null) {
        print('📡 Fetching complaint details for ID: $complaintId');
        final data = await _apiService.getComplaintDetails(
          complaintId: complaintId,
        );
        final coordinates = _extractCoordinates(data);
        setState(() {
          _complaintData = data;
          _latitude = coordinates?.$1;
          _longitude = coordinates?.$2;
          _reverseGeocodedAddress = null;
          _reverseGeocodeFailed = false;
          _isLoading = false;
        });
        if (_hasValidCoordinates) {
          _reverseGeocodeCoordinates();
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid complaint ID';
        });
      }
    } catch (e) {
      print('❌ Error fetching complaint details: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load complaint details';
      });
    }
  }

  (double, double)? _extractCoordinates(Map<String, dynamic> data) {
    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null;
        return double.tryParse(trimmed);
      }
      return null;
    }

    double? lat;
    double? long;

    const latKeys = [
      'lat',
      'latitude',
      'lat_value',
      'latLongLat',
      'location_latitude',
    ];
    const longKeys = [
      'long',
      'lng',
      'longitude',
      'latLongLong',
      'location_longitude',
    ];

    for (final key in latKeys) {
      lat = parseCoordinate(data[key]);
      if (lat != null) break;
    }
    for (final key in longKeys) {
      long = parseCoordinate(data[key]);
      if (long != null) break;
    }

    if (lat == null || long == null) {
      final latLongString = data['lat_long'] ?? data['coordinates'];
      if (latLongString is String) {
        final parts = latLongString.split(',');
        if (parts.length == 2) {
          lat = parseCoordinate(parts[0]);
          long = parseCoordinate(parts[1]);
        }
      }
    }

    if (lat == null || long == null) {
      final media = data['media'];
      if (media is List && media.isNotEmpty) {
        final first = media.first;
        if (first is Map) {
          for (final key in latKeys) {
            lat = parseCoordinate(first[key]);
            if (lat != null) break;
          }
          for (final key in longKeys) {
            long = parseCoordinate(first[key]);
            if (long != null) break;
          }
        }
      }
    }

    if (lat == null || long == null) {
      return null;
    }

    if (lat.isNaN ||
        long.isNaN ||
        lat == 0.0 ||
        long == 0.0 ||
        lat > 90 ||
        lat < -90 ||
        long > 180 ||
        long < -180) {
      return null;
    }

    return (lat, long);
  }

  bool get _hasValidCoordinates => _latitude != null && _longitude != null;

  Future<void> _reverseGeocodeCoordinates() async {
    if (!_hasValidCoordinates || _isReverseGeocoding || _reverseGeocodeFailed) {
      return;
    }

    setState(() {
      _isReverseGeocoding = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        setState(() {
          _reverseGeocodeFailed = true;
          _isReverseGeocoding = false;
        });
        return;
      }

      final place = placemarks.first;
      final parts = <String>[];

      void addIfNotEmpty(String? value) {
        if (value != null) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty && !parts.contains(trimmed)) {
            parts.add(trimmed);
          }
        }
      }

      addIfNotEmpty(place.street);
      addIfNotEmpty(place.subLocality);
      addIfNotEmpty(place.locality);
      addIfNotEmpty(place.subAdministrativeArea);
      addIfNotEmpty(place.administrativeArea);
      addIfNotEmpty(place.postalCode);
      addIfNotEmpty(place.country);

      setState(() {
        _reverseGeocodedAddress = parts.isNotEmpty
            ? parts.join(', ')
            : '${_latitude!}, ${_longitude!}';
        _isReverseGeocoding = false;
        _reverseGeocodeFailed = false;
      });
    } catch (e) {
      debugPrint(
        '❌ Error reverse geocoding complaint ${_complaintData?['id']}: $e',
      );
      if (!mounted) return;
      setState(() {
        _isReverseGeocoding = false;
        _reverseGeocodeFailed = true;
      });
    }
  }

  String _getLocationDisplay() {
    debugPrint(
      '📍 Complaint Details Screen location data for ID ${_complaintData?['id']}',
    );
    debugPrint('📍 Cached address: $_reverseGeocodedAddress');
    debugPrint('📍 Raw location field: ${_complaintData?['location']}');
    debugPrint('📍 District: ${_complaintData?['district_name']}');
    debugPrint('📍 Block: ${_complaintData?['block_name']}');
    debugPrint('📍 Village: ${_complaintData?['village_name']}');

    if (_hasValidCoordinates) {
      if (_reverseGeocodedAddress != null &&
          _reverseGeocodedAddress!.isNotEmpty) {
        debugPrint(
          '✅ Using reverse-geocoded address: $_reverseGeocodedAddress',
        );
        return _reverseGeocodedAddress!;
      }

      if (!_isReverseGeocoding && !_reverseGeocodeFailed) {
        _reverseGeocodeCoordinates();
      }

      if (_isReverseGeocoding) {
        debugPrint('⏳ Reverse geocoding in progress for details page');
        return 'Fetching address...';
      }
    }

    final locationField = _complaintData?['location'];
    if (locationField is String && locationField.trim().isNotEmpty) {
      debugPrint('✅ Using location field: $locationField');
      return locationField.trim();
    }

    final parts = <String>[];
    void addPart(dynamic value) {
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) {
          parts.add(trimmed);
        }
      }
    }

    addPart(_complaintData?['district_name']);
    addPart(_complaintData?['block_name']);
    addPart(_complaintData?['village_name']);

    if (parts.isNotEmpty) {
      final fallback = parts.join(' | ');
      debugPrint('✅ Using district|block|village: $fallback');
      return fallback;
    }

    if (_hasValidCoordinates && !_reverseGeocodeFailed) {
      debugPrint('⌛ Showing placeholder while waiting for reverse geocoding');
      return 'Fetching address...';
    }

    debugPrint('❌ No location data available');
    return 'Location not available';
  }

  String get _getComplaintTypeName {
    final complaintType = _complaintData?['complaint_type'];

    // Try to determine complaint type name
    if (complaintType is Map && complaintType['name'] != null) {
      return complaintType['name'];
    } else if (complaintType is String) {
      return complaintType;
    } else if (_complaintData?['complaint_type_name'] != null) {
      return _complaintData!['complaint_type_name'];
    }
    
    // Fallback to default
    return 'Road Maintenance';
  }

  String get _dynamicStatusText {
    final status = _complaintData?['status_id'];

    print('🔍 Status Check: status_id = $status');
    print('🔍 Status Check: verified_at = ${_complaintData?['verified_at']}');
    print('🔍 Status Check: closed_at = ${_complaintData?['closed_at']}');

    // If verified but not closed, show "Verified"
    if (status == 3 ||
        (_complaintData?['verified_at'] != null &&
            _complaintData?['closed_at'] == null)) {
      return 'Verified';
    }

    // If closed, show "Closed"
    if (status == 4 || _complaintData?['closed_at'] != null) {
      return 'Closed';
    }

    switch (status) {
      case 1:
        return 'Under Process';
      case 2:
        return 'Verification Pending';
      case 3:
        return 'Verified';
      case 4:
        return 'Closed';
      default:
        return 'Under Process';
    }
  }

  String get _dynamicStatusSubtext {
    final status = _complaintData?['status_id'];

    // If verified but not closed, show "Waiting from your end"
    if (status == 3 ||
        (_complaintData?['verified_at'] != null &&
            _complaintData?['closed_at'] == null)) {
      return 'Waiting from your end';
    }

    // If closed, show "Closed"
    if (status == 4 || _complaintData?['closed_at'] != null) {
      return 'Closed';
    }

    switch (status) {
      case 1:
        return 'Waiting for supervisor to resolve';
      case 2:
        return 'Waiting for VDO to verify';
      case 3:
        return 'Waiting from your end';
      case 4:
        return 'Closed';
      default:
        return 'Waiting for supervisor to resolve';
    }
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
        return const Color(0xFFF59E0B); // Orange for verification pending
      case 1:
      default:
        return const Color(0xFFF59E0B); // Orange for under process
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: CitizenColors.background(context),
        appBar: AppBar(
          backgroundColor: CitizenColors.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _primaryTextColor),
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

    if (_errorMessage != null || _complaintData == null) {
      return Scaffold(
        backgroundColor: CitizenColors.background(context),
        appBar: AppBar(
          backgroundColor: CitizenColors.surface(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: _primaryTextColor),
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
      backgroundColor: CitizenColors.background(context),
      appBar: AppBar(
        backgroundColor: CitizenColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getComplaintTypeName,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _primaryTextColor,
              ),
            ),
            Text(
              '${_complaintData!['district_name'] ?? 'District'} | ${_complaintData!['block_name'] ?? 'Block'} | ${_complaintData!['village_name'] ?? 'GP'}',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _secondaryTextColor,
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
      bottomNavigationBar: _buildActionButtons(),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: _dynamicStatusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isClosed ? Icons.check : Icons.schedule,
              color: CitizenColors.light,
              size: 16.sp,
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
                    fontFamily: 'Noto Sans',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _dynamicStatusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dynamicStatusSubtext,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.info_outline, color: _secondaryTextColor, size: 20),
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
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14.sp,
              color: _secondaryTextColor,
            ),
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
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _primaryTextColor,
                ),
              ),
              Text(
                _formatDate(_complaintData?['created_at']),
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: _secondaryTextColor, size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _getLocationDisplay(),
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _complaintData?['description'] ?? 'No description available.',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _secondaryTextColor,
              height: 1.4,
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
              fontFamily: 'Noto Sans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _primaryTextColor,
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

    // Always add complaint created
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
    });

    // Add resolved if present
    if (resolvedAt != null || hasResolutionComment) {
      items.add({
        'title': 'Resolved',
        'subtitle': _formatTimelineSubtitle('Vendor / Supervisor', resolvedAt),
        'isCompleted': true,
        'showLine':
            verifiedAt != null || closedAt != null || hasVerificationComment,
      });
    }

    // Add verified if present
    if (verifiedAt != null || hasVerificationComment) {
      items.add({
        'title': 'Verified',
        'subtitle': _formatTimelineSubtitle('VDO', verifiedAt),
        'isCompleted': true,
        'showLine': closedAt != null,
      });
    }

    // Add closed if present
    if (closedAt != null) {
      items.add({
        'title': AppLocalizations.of(context)!.closed,
        'subtitle': _formatTimelineSubtitle('Citizen', closedAt),
        'isCompleted': true,
        'showLine': false,
      });
    }

    return items;
  }

  String _formatTimelineSubtitle(String user, String? dateString) {
    String formattedDate = DateTimeUtils.formatDateStringIST(dateString);
    if (formattedDate == 'Unknown') {
      formattedDate = 'Unknown date';
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
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primaryTextColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: _secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final statusId = _complaintData?['status_id'];
    final verifiedAt = _complaintData?['verified_at'];
    final closedAt = _complaintData?['closed_at'];

    // Only show action buttons when verified but not closed
    final isVerifiedAndNotClosed =
        (statusId == 3 || (verifiedAt != null && closedAt == null));

    if (!isVerifiedAndNotClosed) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: CitizenColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Handle not satisfied
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, color: _secondaryTextColor),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context)!.notSatisfied,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _showFeedbackBottomSheet,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: CitizenColors.light),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.markCompleted,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CitizenColors.light,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackBottomSheet() {
    _feedbackController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackBottomSheet(
        feedbackController: _feedbackController,
        complaintId: widget.complaintId,
        onSubmitted: () async {
          await _submitFeedback();
        },
      ),
    );
  }

  Future<void> _submitFeedback() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final token = authProvider.token;

      if (token == null) {
        print('❌ No authentication token found');
        return;
      }

      final complaintId = int.tryParse(widget.complaintId);
      if (complaintId == null) {
        print('❌ Invalid complaint ID');
        return;
      }

      final feedback = _feedbackController.text.trim();
      if (feedback.isEmpty) {
        print('❌ Feedback is empty');
        return;
      }

      print('🚀 Submitting feedback for complaint $complaintId');

      // Call the API to close the complaint
      await _apiService.closeComplaint(
        complaintId: complaintId,
        resolution: feedback,
        token: token,
      );

      // Close the feedback bottom sheet
      if (mounted) {
        Navigator.pop(context);

        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      print('❌ Error submitting feedback: $e');

      // Close the feedback bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SuccessBottomSheet(
        onClose: () {
          Navigator.pop(context);
          // Refresh complaint details
          _fetchComplaintDetails();
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    return DateTimeUtils.formatDateStringIST(dateStr);
  }
}

class _FeedbackBottomSheet extends StatelessWidget {
  final TextEditingController feedbackController;
  final String complaintId;
  final VoidCallback onSubmitted;

  const _FeedbackBottomSheet({
    required this.feedbackController,
    required this.complaintId,
    required this.onSubmitted,
  });

  Color _primaryTextColor(BuildContext context) =>
      CitizenColors.textPrimary(context);
  Color _secondaryTextColor(BuildContext context) =>
      CitizenColors.textSecondary(context);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CitizenColors.surface(context),
        borderRadius: const BorderRadius.only(
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
                    AppLocalizations.of(context)!.feedbackRequired,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: _secondaryTextColor(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Feedback label
              Text(
                AppLocalizations.of(context)!.feedback,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: _primaryTextColor(context),
                ),
              ),
              SizedBox(height: 8.h),

              // Feedback text field
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    )!.writeYourFeedbackHere,
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

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (feedbackController.text.trim().isNotEmpty) {
                      onSubmitted();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.submit,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: CitizenColors.light,
                    ),
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

class _SuccessBottomSheet extends StatelessWidget {
  final VoidCallback onClose;

  const _SuccessBottomSheet({required this.onClose});

  Color _primaryTextColor(BuildContext context) =>
      CitizenColors.textPrimary(context);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CitizenColors.surface(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            SizedBox(height: 40.h),

            // Success icon
            Icon(Icons.star, color: const Color(0xFFFFD700), size: 48.sp),
            SizedBox(height: 20.h),

            // Success message
            Text(
              AppLocalizations.of(context)!.yourFeedbackIsSuccessfullySubmitted,
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: _primaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.close,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: CitizenColors.light,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
