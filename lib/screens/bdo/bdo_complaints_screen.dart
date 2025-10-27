import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/complaints_service.dart';
import '../../models/api_complaint_model.dart';

class BdoComplaintsScreen extends StatefulWidget {
  const BdoComplaintsScreen({super.key});

  @override
  State<BdoComplaintsScreen> createState() => _BdoComplaintsScreenState();
}

class _BdoComplaintsScreenState extends State<BdoComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // API data
  final ComplaintsService _complaintsService = ComplaintsService();
  List<ApiComplaintModel> _complaints = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _villageName = 'Gram Panchayat';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _complaintsService.getComplaintsForSupervisor();

      if (response['success'] == true) {
        final complaints = response['complaints'] as List<ApiComplaintModel>;

        // Extract village name from first complaint if available
        String villageName = 'Gram Panchayat';
        if (complaints.isNotEmpty) {
          villageName = complaints[0].villageName;
        }

        setState(() {
          _complaints = complaints;
          _villageName = villageName;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load complaints';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
        _isLoading = false;
      });
    }
  }

  // Helper methods to filter complaints by status
  List<ApiComplaintModel> get _openComplaints =>
      _complaints.where((c) => c.isOpen).toList();

  List<ApiComplaintModel> get _resolvedComplaints =>
      _complaints.where((c) => c.isResolved).toList();

  List<ApiComplaintModel> get _verifiedComplaints =>
      _complaints.where((c) => c.isVerified).toList();

  List<ApiComplaintModel> get _closedComplaints =>
      _complaints.where((c) => c.isClosed).toList();

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadComplaints,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009B56),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Status Tabs
            _buildStatusTabs(),

            // Complaints List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildComplaintsList(_openComplaints),
                        _buildComplaintsList(_resolvedComplaints),
                        _buildComplaintsList(_verifiedComplaints),
                        _buildComplaintsList(_closedComplaints),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaint (23)',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$_villageName • ${DateFormat('MMMM').format(DateTime.now())}',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 24.sp,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.swap_vert, size: 24.sp, color: Colors.black),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF009B56), width: 3),
        ),
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          _buildTab(
            'Open (${_openComplaints.length})',
            _tabController.index == 0,
          ),
          _buildTab(
            'Resolved (${_resolvedComplaints.length})',
            _tabController.index == 1,
          ),
          _buildTab(
            'Verified (${_verifiedComplaints.length})',
            _tabController.index == 2,
          ),
          _buildTab(
            'Closed (${_closedComplaints.length})',
            _tabController.index == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          SizedBox(width: 8.w),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF009B56) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(List<ApiComplaintModel> complaints) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: const Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16.h),
            Text(
              'No complaints found',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        return _buildComplaintCard(complaints[index]);
      },
    );
  }

  Widget _buildComplaintCard(ApiComplaintModel complaint) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to complaint details if needed
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  complaint.hasMedia
                      ? Image.network(
                          complaint.firstMediaUrl,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/road.png',
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/road.png',
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        complaint.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          complaint.complaintType,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Image.asset(
                        'assets/icons/map.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 18.sp,
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          complaint.fullLocation,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Divider(color: Colors.grey.shade200, thickness: 2),

                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      letterSpacing: 0,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0),
          _buildNavItem(Icons.list_alt, 'Complaint', 1, isActive: true),
          _buildNavItem(Icons.people, 'Monitoring', 2),
          _buildNavItem(Icons.settings, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool isActive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/bdo-dashboard');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/bdo-monitoring');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/bdo-settings');
          }
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE8F5E8) : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.sp,
                color: isActive
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9CA3AF),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 4.h),
              if (isActive)
                Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )
              else
                SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
