import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../services/complaints_service.dart';
import '../../models/api_complaint_model.dart';

class VdoComplaintsScreen extends StatefulWidget {
  const VdoComplaintsScreen({super.key});

  @override
  State<VdoComplaintsScreen> createState() => _VdoComplaintsScreenState();
}

class _VdoComplaintsScreenState extends State<VdoComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 1; // Complaint tab is selected

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
  List<ApiComplaintModel> get _openComplaints => _complaints
      .where((c) => c.isOpen && !c.isActuallyResolved && !c.isActuallyVerified)
      .toList();

  List<ApiComplaintModel> get _resolvedComplaints => _complaints
      .where((c) => c.isActuallyResolved && !c.isActuallyVerified)
      .toList();

  List<ApiComplaintModel> get _verifiedComplaints =>
      _complaints.where((c) => c.isActuallyVerified).toList();

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
            style: TextStyle(fontSize: 16.sp, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadComplaints,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF009B56)),
          SizedBox(height: 16 ),
          Text(
            'Loading complaints...',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
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

  String _formatDate(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date != null) {
      return DateFormat('dd MMM').format(date);
    }
    return 'Unknown';
  }

  // Enhanced status methods for ApiComplaintModel
  Color _getComplaintStatusColor(ApiComplaintModel complaint) {
    if (complaint.isActuallyVerified) {
      return const Color(0xFF10B981); // Green for verified
    } else if (complaint.isActuallyResolved) {
      return const Color(0xFF3B82F6); // Blue for resolved
    } else if (complaint.isClosed) {
      return const Color(0xFF6B7280); // Gray for closed
    } else {
      return const Color(0xFFEF4444); // Red for open
    }
  }

  String _getComplaintStatusText(ApiComplaintModel complaint) {
    if (complaint.isActuallyVerified) {
      return 'Verified';
    } else if (complaint.isActuallyResolved) {
      return 'Resolved';
    } else if (complaint.isClosed) {
      return 'Closed';
    } else {
      return 'Open';
    }
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
              child: TabBarView(
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
                    'Complaint (${_complaints.length})',
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$_villageName • ${DateFormat('MMMM').format(DateTime.now())}',
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4B5563),
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Row(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today, size: 24, color: Colors.black),
                    ],
                  ),
                  SizedBox(width: 8.w),
                    Icon(Icons.swap_vert, size: 24, color: Colors.black),
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
        labelStyle: const TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14,
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
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (complaints.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text(
              'No complaints found',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         VdoComplaintDetailsScreen(complaint: complaint.toMap()),
        //   ),
        // );
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
                  complaint.hasMedia == true
                      ? Image.network(
                          complaint.firstMediaUrl.isNotEmpty
                              ? complaint.firstMediaUrl
                              : 'http://139.59.34.99:8000/assets/images/road.png',
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
                        _formatDate(complaint.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Noto Sans',
                          color: Colors.white,
                          fontSize: 12,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          complaint.description,
                          style: const TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getComplaintStatusColor(
                            complaint,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _getComplaintStatusText(complaint),
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: _getComplaintStatusColor(complaint),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    complaint.complaintType,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 12.h),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        complaint.villageName,
                        style: const TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            complaint.complaintType,
                            style: const TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    return CustomBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Navigate to different screens based on selection
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/vdo-dashboard');
            break;
          case 1:
            // Already on complaints
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/vdo-attendance');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/vdo-settings');
            break;
        }
      },
      items: const [
        BottomNavItem(icon: Icons.home, label: 'Home'),
        BottomNavItem(icon: Icons.list_alt, label: 'Complaints'),
        BottomNavItem(icon: Icons.assignment, label: 'Inspection'),
        BottomNavItem(icon: Icons.settings, label: 'Settings'),
      ],
    );
  }
}
