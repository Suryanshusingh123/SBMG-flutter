import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';

class SmdInspectionLogScreen extends StatefulWidget {
  const SmdInspectionLogScreen({super.key});

  @override
  State<SmdInspectionLogScreen> createState() => _SmdInspectionLogScreenState();
}

class _SmdInspectionLogScreenState extends State<SmdInspectionLogScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<GramPanchayat> _gramPanchayats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGramPanchayats();
  }

  Future<void> _loadGramPanchayats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get district ID from SMD selected district and block ID from auth service
      final districtId = await _authService.getSmdSelectedDistrictId();

      print('🔄 Loading Gram Panchayats for SMD...');
      print('   - District ID: $districtId');

      if (districtId == null) {
        setState(() {
          _isLoading = false;
          _error =
              'District information not found. Please select a district first.';
        });
        return;
      }

      // Load all blocks for this district
      final blocks = await _apiService.getBlocks(districtId: districtId);

      // Load all GPs for all blocks
      List<GramPanchayat> allGps = [];
      for (final block in blocks) {
        final gps = await _apiService.getGramPanchayats(
          districtId: districtId,
          blockId: block.id,
          skip: 0,
          limit: 100,
        );
        allGps.addAll(gps);
      }

      final gramPanchayats = allGps;

      setState(() {
        _gramPanchayats = gramPanchayats;
        _isLoading = false;
      });

      print('✅ Loaded ${_gramPanchayats.length} Gram Panchayats');
    } catch (e) {
      print('❌ Error loading Gram Panchayats: $e');
      setState(() {
        _isLoading = false;
        _error = 'Failed to load Gram Panchayats: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inspection log',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _error!,
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadGramPanchayats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _gramPanchayats.isEmpty
          ? Center(
              child: Text(
                'No Gram Panchayats found',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: _gramPanchayats.length,
              itemBuilder: (context, index) {
                final gp = _gramPanchayats[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      gp.name,
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: const Color(0xFF9CA3AF),
                      size: 20.sp,
                    ),
                    onTap: () {
                      // TODO: Navigate to GP Inspection Details Screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Viewing inspection details for ${gp.name}',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
