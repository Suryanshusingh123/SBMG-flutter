import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../providers/smd_complaints_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/location_display_helper.dart';
import '../../utils/date_time_utils.dart';
import '../../widgets/resolution_details_sheet.dart';

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
  bool _isClosing = false;
  double? _latitude;
  double? _longitude;

  // Store original media data
  List<dynamic>? _originalMediaUrls;

  /// Resolves status string from API. When status is null, derives from status_id.
  /// 1=OPEN, 2=RESOLVED, 3=VERIFIED, 4=CLOSED
  String get _resolvedStatus {
    final raw = _data['status']?.toString().trim();
    if (raw != null && raw.isNotEmpty) return raw.toUpperCase();
    final statusId = _data['status_id'];
    if (statusId == null) return 'OPEN';
    switch (statusId is int ? statusId : int.tryParse(statusId.toString())) {
      case 1:
        return 'OPEN';
      case 2:
        return 'RESOLVED';
      case 3:
        return 'VERIFIED';
      case 4:
        return 'CLOSED';
      default:
        return 'OPEN';
    }
  }

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

  Future<void> _closeComplaint() async {
    final complaintId = int.tryParse(_data['id'].toString());
    if (complaintId == null) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.closeComplaint),
        content: Text(l10n.closeComplaintConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isClosing = true);
    try {
      await _apiService.closeComplaintBySmd(
        complaintId: complaintId,
      );
      if (!mounted) return;
      // Re-fetch full complaint details so timeline (closed_at) and status update in UI
      await _fetchComplaintDetails();
      if (!mounted) return;
      setState(() {
        _isClosing = false;
      });
      context.read<SmdComplaintsProvider>().loadComplaints();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.complaintHasBeenClosed)));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isClosing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
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
    } else if (complaintType is String && complaintType.trim().isNotEmpty) {
      return complaintType.trim();
    } else if (_data['complaint_type_name'] != null) {
      return _data['complaint_type_name'];
    }

    // Resolve from complaint_type_id when API returns id but not type name
    final typeId = _data['complaint_type_id'];
    if (typeId != null && context.mounted) {
      final id = typeId is int ? typeId : int.tryParse(typeId.toString());
      if (id != null) {
        final resolved = context
            .read<SmdComplaintsProvider>()
            .getComplaintTypeNameById(id);
        if (resolved != null && resolved.isNotEmpty) return resolved;
      }
    }

    // Fallback to default
    return AppLocalizations.of(context)!.roadMaintenance;
  }

  bool get _isClosed {
    final statusId = _data['status_id'];
    final closedAt = _data['closed_at'];
    return closedAt != null ||
        statusId == 4 ||
        (statusId != null && statusId.toString() == '4');
  }

  /// True when complaint is verified (by VDO) and not yet closed — SMD can close only then.
  bool get _isVerifiedAndNotClosed {
    if (_isClosed) return false;
    final status = _resolvedStatus;
    final verifiedAt = _data['verified_at'];
    return status == 'VERIFIED' || verifiedAt != null;
  }

  // Dynamic status text based on API fields
  String get _dynamicStatusText {
    final status = _resolvedStatus;
    final resolvedAt = _data['resolved_at'];
    final verifiedAt = _data['verified_at'];
    final closedAt = _data['closed_at'];
    final l10n = AppLocalizations.of(context)!;

    // Check if closed (use status_id when status/closed_at may be null from API)
    if (status == 'CLOSED' || _isClosed) {
      return l10n.complaintHasBeenClosed;
    }

    // Check if verified but not closed - show awaiting citizen message
    if (status == 'VERIFIED' || (verifiedAt != null && closedAt == null)) {
      return l10n.awaitingForCitizenToCloseComplaint;
    }

    // Check if resolved but not verified - show awaiting VDO message
    if (status == 'RESOLVED' || (resolvedAt != null && verifiedAt == null)) {
      return l10n.awaitingForVdoToVerify;
    }

    // Open status - show awaiting supervisor message
    return l10n.awaitingForSupervisorToTakeAction;
  }

  // Dynamic location text based on API fields
  String _getLocationText() {
    final l10n = AppLocalizations.of(context)!;
    String? readString(List<String> keys) {
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
      locationField: readString(['location', 'Location']),
      district: readString(['district_name', 'districtName']),
      block: readString(['block_name', 'blockName']),
      village: readString(['village_name', 'villageName']),
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
            content: Text(AppLocalizations.of(context)!.couldNotOpenGoogleMaps),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotOpenGoogleMaps),
          ),
        );
      }
    }
  }

  // Dynamic status color based on current state
  Color get _dynamicStatusColor {
    final status = _resolvedStatus;

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
              '${_data['district_name'] ?? AppLocalizations.of(context)!.district} | ${_data['block_name'] ?? AppLocalizations.of(context)!.block} | ${_data['village_name'] ?? AppLocalizations.of(context)!.gp}',
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

            // Close complaint button (SMD) - only for verified complaints, not yet closed
            if (_isVerifiedAndNotClosed) ...[
              const SizedBox(height: 16),
              _buildCloseComplaintButton(),
            ],

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
    final status = _resolvedStatus.toLowerCase();
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

  Widget _buildCloseComplaintButton() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isClosing ? null : _closeComplaint,
          icon: _isClosing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_circle_outline, size: 20),
          label: Text(_isClosing ? l10n.loading : l10n.closeComplaint),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
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
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noImagesAvailable,
            style: const TextStyle(
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
            _getComplaintTypeName,
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
            _data['description'] ??
                AppLocalizations.of(context)!.noDescriptionAvailable,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),

          // Get Directions Button
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _openGoogleMaps(_latitude, _longitude);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.getDirections,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    final updatedAt = _data['updated_at'];

    // Complaint is closed when closed_at is set OR status_id is 4 (API may not set closed_at)
    final isClosed = _isClosed;

    // Check if there's a resolution comment
    final hasResolutionComment = _hasResolutionComment;
    final hasVerificationComment = _hasVerificationComment;

    // Always add complaint created item
    final l10n = AppLocalizations.of(context)!;
    items.add({
      'title': l10n.complaintCreated,
      'subtitle': _formatTimelineSubtitle('Citizen', createdAt),
      'isCompleted': true,
      'showLine':
          resolvedAt != null ||
          verifiedAt != null ||
          isClosed ||
          hasResolutionComment ||
          hasVerificationComment,
      'stage': 'created',
    });

    // Add resolved item if resolved_at is present or has resolution comment
    if (resolvedAt != null || hasResolutionComment) {
      items.add({
        'title': l10n.resolved,
        'subtitle': _formatTimelineSubtitle(
          l10n.contractorSupervisor,
          resolvedAt ?? _getResolutionDateFromComments(),
        ),
        'isCompleted': true,
        'showLine':
            verifiedAt != null || isClosed || hasVerificationComment,
        'stage': 'resolved',
      });
    }

    // Add verified item if verified_at is present or has verification comment
    if (verifiedAt != null || hasVerificationComment) {
      items.add({
        'title': l10n.verified,
        'subtitle': _formatTimelineSubtitle(
          l10n.vdo,
          verifiedAt ?? _getVerificationDateFromComments(),
        ),
        'isCompleted': true,
        'showLine': isClosed,
        'stage': 'verified',
      });
    }

    // Add closed item when closed_at is present OR status_id is 4 (SMD closed)
    if (isClosed) {
      final closedDate = closedAt ?? updatedAt ?? '';
      items.add({
        'title': AppLocalizations.of(context)!.closed,
        'subtitle': _formatTimelineSubtitle('SMD', closedDate),
        'isCompleted': true,
        'showLine': false, // Last item, no line needed
        'stage': 'closed',
      });
    }

    return items;
  }

  String _formatTimelineSubtitle(String user, String? dateString) {
    String formattedDate = DateTimeUtils.formatComplaintDetailIST(dateString);
    if (formattedDate == 'Unknown') {
      formattedDate = AppLocalizations.of(context)!.unknownDate;
    }
    return '$user • $formattedDate';
  }

  void _onTimelineStageTap(Map<String, dynamic> item) {
    final stage = item['stage'] as String?;
    if (stage == 'resolved') {
      ResolutionDetailsSheet.show(context, _data);
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

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.timeline,
            style: const TextStyle(
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
              onTap: () => _onTimelineStageTap(item),
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
    final content = Row(
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
      ],
    );
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: content,
      );
    }
    return content;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    final formatted = DateTimeUtils.formatComplaintDetailIST(dateStr);
    return formatted == 'Unknown' ? 'Unknown' : formatted;
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
