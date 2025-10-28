import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/api_services.dart';
import '../../config/connstants.dart';
import '../../providers/citizen_auth_provider.dart';
import '../../l10n/app_localizations.dart';

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

  // Feedback controller
  final TextEditingController _feedbackController = TextEditingController();

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
        setState(() {
          _complaintData = data;
          _isLoading = false;
        });
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

    if (_errorMessage != null || _complaintData == null) {
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
              'Complaint ID #${_complaintData!['id']}',
              style: const TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              '${_complaintData!['district_name'] ?? 'District'} | ${_complaintData!['block_name'] ?? 'Block'} | ${_complaintData!['village_name'] ?? 'GP'}',
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
              color: Colors.white,
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
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
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
              color: const Color(0xFF6B7280),
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
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                _formatDate(_complaintData?['created_at']),
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF6B7280), size: 20),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _complaintData?['location'] ?? 'Location not available',
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _complaintData?['description'] ?? 'No description available.',
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

  Widget _buildTimeline() {
    final timelineItems = _buildTimelineItems();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
        'title': 'Closed',
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
                style: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4.h),
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
        color: Colors.white,
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
                  Icon(Icons.close, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Text(
                    AppLocalizations.of(context)!.notSatisfied,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
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
                  const Icon(Icons.check, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.markCompleted,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
    if (dateStr == null) return 'Unknown';
    try {
      // Parse the UTC date
      final date = DateTime.parse(dateStr);

      // Convert to IST (UTC+5:30)
      final istDate = date.add(const Duration(hours: 5, minutes: 30));

      return DateFormat('MMM d, yyyy, h:mm a').format(istDate);
    } catch (e) {
      print('❌ Error formatting date: $e');
      return 'Unknown';
    }
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
                    AppLocalizations.of(context)!.feedbackRequired,
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
              SizedBox(height: 20.h),

              // Feedback label
              Text(
                AppLocalizations.of(context)!.feedback,
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
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
                      color: Colors.white,
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
                color: const Color(0xFF111827),
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
                    color: Colors.white,
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
