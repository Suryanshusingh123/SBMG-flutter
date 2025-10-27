import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/bdo_complaints_provider.dart';
import '../../widgets/common/custom_bottom_navigation.dart';
import '../../config/connstants.dart';

class BdoComplaintsScreen extends StatefulWidget {
  const BdoComplaintsScreen({super.key});

  @override
  State<BdoComplaintsScreen> createState() => _BdoComplaintsScreenState();
}

class _BdoComplaintsScreenState extends State<BdoComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 1; // Complaint tab is selected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BdoComplaintsProvider>().loadComplaints();
    });
  }

  Widget _buildErrorState(BdoComplaintsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            provider.errorMessage ?? 'Something went wrong',
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
            onPressed: () => provider.loadComplaints(),
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
    return Consumer<BdoComplaintsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(provider),

                // Status Tabs
                _buildStatusTabs(provider),

                // Complaints List
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.errorMessage != null
                      ? _buildErrorState(provider)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildComplaintsList(
                              provider.openComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.resolvedComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.verifiedComplaints,
                              provider,
                            ),
                            _buildComplaintsList(
                              provider.closedComplaints,
                              provider,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
            items: const [
              BottomNavItem(icon: Icons.home, label: 'Home'),
              BottomNavItem(icon: Icons.report_problem, label: 'Complaint'),
              BottomNavItem(icon: Icons.checklist, label: 'Inspection'),
              BottomNavItem(icon: Icons.settings, label: 'Settings'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BdoComplaintsProvider provider) {
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
                    '${provider.villageName} • ${DateFormat('MMMM').format(DateTime.now())}',
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

  Widget _buildStatusTabs(BdoComplaintsProvider provider) {
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
            'Open (${provider.openComplaints.length})',
            _tabController.index == 0,
          ),
          _buildTab(
            'Resolved (${provider.resolvedComplaints.length})',
            _tabController.index == 1,
          ),
          _buildTab(
            'Verified (${provider.verifiedComplaints.length})',
            _tabController.index == 2,
          ),
          _buildTab(
            'Closed (${provider.closedComplaints.length})',
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

  Widget _buildComplaintsList(
    List<dynamic> complaints,
    BdoComplaintsProvider provider,
  ) {
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
        return _buildComplaintCard(complaints[index], provider);
      },
    );
  }

  Widget _buildComplaintCard(
    dynamic complaint,
    BdoComplaintsProvider provider,
  ) {
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
                          ApiConstants.getMediaUrl(complaint.firstMediaUrl),
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

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/bdo-dashboard');
        break;
      case 1:
        // Already on complaints screen, do nothing
        break;
      case 2:
        Navigator.pushNamed(context, '/bdo-monitoring');
        break;
      case 3:
        Navigator.pushNamed(context, '/bdo-settings');
        break;
    }
  }
}
