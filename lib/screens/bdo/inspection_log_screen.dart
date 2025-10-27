import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';

class InspectionLogScreen extends StatefulWidget {
  const InspectionLogScreen({super.key});

  @override
  State<InspectionLogScreen> createState() => _InspectionLogScreenState();
}

class _InspectionLogScreenState extends State<InspectionLogScreen> {
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

      // Get district ID and block ID from auth service
      final districtId = await _authService.getDistrictId();
      final blockId = await _authService.getBlockId();

      print('🔄 Loading Gram Panchayats...');
      print('   - District ID: $districtId');
      print('   - Block ID: $blockId');

      if (districtId == null || blockId == null) {
        setState(() {
          _isLoading = false;
          _error = 'District or Block information not found';
        });
        return;
      }

      final gramPanchayats = await _apiService.getGramPanchayats(
        districtId: districtId,
        blockId: blockId,
        skip: 0,
        limit: 100,
      );

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
        title: const Text(
          'Inspection log',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
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
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
                  SizedBox(height: 16.h),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
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
          ? const Center(
              child: Text(
                'No Gram Panchayats found',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
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
                      style: const TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    onTap: () {
                     
                    },
                  ),
                );
              },
            ),
    );
  }
}
