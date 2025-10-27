import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/complaint_model.dart';
import '../../providers/citizen_auth_provider.dart';
import '../../providers/citizen_complaints_provider.dart';
import '../../widgets/common/auth_required_screen.dart';
import '../../widgets/common/custom_bottom_navigation.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  int _selectedIndex = 1; // My Complaint tab is selected
  String _selectedStatus = 'Open'; // Default to Open tab
  int _selectedStatusIndex = 0;
  bool _hasLoadedComplaints = false; // Flag to prevent multiple API calls

  @override
  void initState() {
    super.initState();

    // Load complaints after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadComplaintsIfNeeded();
    });
  }

  void _loadComplaintsIfNeeded() {
    final authProvider = context.read<AuthProvider>();
    final complaintsProvider = context.read<ComplaintsProvider>();

    print('🔍 _loadComplaintsIfNeeded called');
    print('🔍 isLoggedIn: ${authProvider.isLoggedIn}');
    print('🔍 token: ${authProvider.token != null}');
    print('🔍 isLoadingComplaints: ${complaintsProvider.isLoadingComplaints}');
    print('🔍 hasLoadedComplaints: $_hasLoadedComplaints');

    if (authProvider.isLoggedIn &&
        authProvider.token != null &&
        !complaintsProvider.isLoadingComplaints &&
        !_hasLoadedComplaints) {
      print('🚀 Loading complaints...');
      _hasLoadedComplaints = true;
      complaintsProvider.loadMyComplaints(token: authProvider.token!);
    }
  }

  void _refreshComplaints() {
    final authProvider = context.read<AuthProvider>();
    final complaintsProvider = context.read<ComplaintsProvider>();

    if (authProvider.isLoggedIn &&
        authProvider.token != null &&
        !complaintsProvider.isLoadingComplaints) {
      complaintsProvider.loadMyComplaints(token: authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ComplaintsProvider>(
      builder: (context, authProvider, complaintsProvider, child) {
        // Load complaints when authentication is complete and user is logged in
        if (!authProvider.isCheckingAuth && 
            authProvider.isLoggedIn && 
            !_hasLoadedComplaints &&
            !complaintsProvider.isLoadingComplaints) {
          print('🔄 Consumer2: Triggering complaint load');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadComplaintsIfNeeded();
          });
        }
        
        // Show loading while checking authentication
        if (authProvider.isCheckingAuth) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            ),
          );
        }

        // Show auth required screen if not logged in
        if (!authProvider.isLoggedIn) {
          return AuthRequiredScreen(
            title: AppLocalizations.of(context)!.myComplaint,
            message: AppLocalizations.of(context)!.toViewYourComplaintStatus,
          );
        }

        return _buildComplaintsScreen(complaintsProvider);
      },
    );
  }

  Widget _buildComplaintsScreen(ComplaintsProvider complaintsProvider) {
    // Show loading indicator while complaints are being fetched
    if (complaintsProvider.isLoadingComplaints) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF009B56)),
        ),
      );
    }

    // Filter complaints based on selected status
    final filteredComplaints = complaintsProvider.complaints.where((complaint) {
      return _selectedStatus == 'Open'
          ? complaint.status == 'open'
          : complaint.status == 'closed';
    }).toList();

    print('📊 Total complaints: ${complaintsProvider.complaints.length}');
    print('📊 Filtered complaints: ${filteredComplaints.length}');
    print('📊 Selected status: $_selectedStatus');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Status Tabs
            _buildStatusTabs(complaintsProvider),

            // Complaints List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _refreshComplaints();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filteredComplaints.length,
                  itemBuilder: (context, index) {
                    return _buildComplaintCard(filteredComplaints[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate to different screens based on selection
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/citizen-dashboard');
              break;
            case 1:
              // Already on My Complaints
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/schemes');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
        items: [
          BottomNavItem(
            icon: Icons.home,
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavItem(
            icon: Icons.list_alt,
            label: AppLocalizations.of(context)!.myComplaint,
          ),
          BottomNavItem(
            icon: Icons.account_balance,
            label: AppLocalizations.of(context)!.schemes,
          ),
          BottomNavItem(
            icon: Icons.settings,
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.myComplaint,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          Row(
            children: [
              // Calendar icon with count
              Icon(Icons.calendar_today, size: 24.sp, color: Colors.black),
              SizedBox(width: 12.w),
              Icon(Icons.swap_vert, size: 24.sp, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(ComplaintsProvider complaintsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final openCount = complaintsProvider.complaints
        .where((c) => c.status == 'open')
        .length;
    final closedCount = complaintsProvider.complaints
        .where((c) => c.status == 'closed')
        .length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(child: _buildStatusTab(l10n.open, openCount, 0)),
          SizedBox(width: 16.w),
          Expanded(child: _buildStatusTab(l10n.closed, closedCount, 1)),
        ],
      ),
    );
  }

  Widget _buildStatusTab(String status, int count, int index) {
    final isSelected = _selectedStatusIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusIndex = index;
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF009B56) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF009B56),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              status,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : const Color(0xFF6B7280),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF009B56)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ComplaintDetailsScreen(complaint: complaint),
        //   ),
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Complaint Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  // Complaint image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      complaint.imagePaths.first,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade400,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Date badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _formatDate(complaint.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Complaint Details
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Complaint Type and Updates
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF009B56),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        complaint.type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '| 2 Updates',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          complaint.imageLocations.first.address ??
                              'Location not available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Description
                  Text(
                    complaint.description,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
                  ),

                  // Latest update indicator (if applicable)
                  if (complaint.status == 'open') ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: const Text(
                        '(latest update)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF856404),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
