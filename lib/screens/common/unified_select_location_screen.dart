import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

class UnifiedSelectLocationScreen extends StatefulWidget {
  final String? userRole; // 'bdo', 'ceo', 'smd'
  final Function(Map<String, dynamic>)? onLocationSelected;

  const UnifiedSelectLocationScreen({
    super.key,
    this.userRole,
    this.onLocationSelected,
  });

  @override
  State<UnifiedSelectLocationScreen> createState() =>
      _UnifiedSelectLocationScreenState();
}

class _UnifiedSelectLocationScreenState
    extends State<UnifiedSelectLocationScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  int? _districtId;
  String _districtName = '';
  List<District> _districts = [];
  List<Block> _blocks = [];
  List<GramPanchayat> _gramPanchayats = [];

  District? _selectedDistrict;
  Block? _selectedBlock;
  GramPanchayat? _selectedGP;

  bool _isLoadingDistricts = false;
  bool _isLoadingBlocks = false;
  bool _isLoadingGPs = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoadingDistricts = true);

    try {
      // Load all districts first
      final districts = await _apiService.getDistricts();
      
      // Get default district based on user role
      int? defaultDistrictId;
      if (widget.userRole == 'smd') {
        defaultDistrictId = await _authService.getSmdSelectedDistrictId();
      } else {
        defaultDistrictId = await _authService.getDistrictId();
      }

      District? defaultDistrict;
      if (defaultDistrictId != null && districts.isNotEmpty) {
        defaultDistrict = districts.firstWhere(
          (d) => d.id == defaultDistrictId,
          orElse: () => districts.first,
        );
      } else if (districts.isNotEmpty) {
        defaultDistrict = districts.first;
      }

      setState(() {
        _districts = districts;
        _selectedDistrict = defaultDistrict;
        _districtId = defaultDistrict?.id;
        _districtName = defaultDistrict?.name ?? '';
        _isLoadingDistricts = false;
      });

      if (_districtId != null) {
        await _loadBlocks(_districtId!);
      }
    } catch (e) {
      debugPrint('Error initializing location screen: $e');
      setState(() => _isLoadingDistricts = false);
    }
  }

  Future<void> _loadBlocks(int districtId) async {
    setState(() {
      _isLoadingBlocks = true;
      _blocks = [];
      _selectedBlock = null;
      _gramPanchayats = [];
      _selectedGP = null;
    });

    try {
      final blocks = await _apiService.getBlocks(districtId: districtId);
      setState(() {
        _blocks = blocks;
        _isLoadingBlocks = false;
      });
    } catch (e) {
      debugPrint('Error loading blocks: $e');
      setState(() => _isLoadingBlocks = false);
    }
  }

  Future<void> _loadGramPanchayats(int districtId, int blockId) async {
    setState(() {
      _isLoadingGPs = true;
      _gramPanchayats = [];
      _selectedGP = null;
    });

    try {
      final gps = await _apiService.getGramPanchayats(
        districtId: districtId,
        blockId: blockId,
      );
      setState(() {
        _gramPanchayats = gps;
        _isLoadingGPs = false;
      });
    } catch (e) {
      debugPrint('Error loading GPs: $e');
      setState(() => _isLoadingGPs = false);
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
          'Select Location',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetSelections,
            child: const Text(
              'Reset',
              style: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.r),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search....',
                hintStyle: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.sp,
                  color: const Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Location Selection Fields
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  // District Field
                  _buildLocationField(
                    label: 'District',
                    value: _districtName.isNotEmpty ? _districtName : null,
                    onTap: _isLoadingDistricts
                        ? null
                        : () => _showDistrictBottomSheet(),
                    isLoading: _isLoadingDistricts,
                  ),
                  SizedBox(height: 16.h),
                  // Block Field
                  _buildLocationField(
                    label: 'Block',
                    value: _selectedBlock?.name,
                    onTap: (_districtId == null || _isLoadingBlocks)
                        ? null
                        : () => _showBlockBottomSheet(),
                    isLoading: _isLoadingBlocks,
                  ),
                  SizedBox(height: 16.h),
                  // Gram Panchayat Field
                  _buildLocationField(
                    label: 'Gram Panchayat',
                    value: _selectedGP?.name,
                    onTap: (_selectedBlock == null ||
                            _districtId == null ||
                            _isLoadingGPs)
                        ? null
                        : () => _showGPBottomSheet(),
                    isLoading: _isLoadingGPs,
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _canApply() ? _applyLocation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canApply()
                      ? AppColors.primaryColor
                      : Colors.grey[300],
                  foregroundColor: _canApply() ? Colors.white : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required String label,
    required String? value,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    final isDisabled = onTap == null || isLoading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: isDisabled ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Loading...',
                              style: TextStyle(
                                fontFamily: 'Noto Sans',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          value ?? 'Select option',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: value != null
                                ? const Color(0xFF111827)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                ),
                if (!isLoading)
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _canApply() {
    if (_selectedDistrict == null || _selectedBlock == null) {
      return false;
    }
    return _selectedGP != null;
  }

  void _resetSelections() {
    setState(() {
      _selectedBlock = null;
      _selectedGP = null;
      _gramPanchayats = [];
      _searchController.clear();
    });
  }

  void _applyLocation() {
    if (_canApply() && _selectedDistrict != null && _selectedBlock != null && _selectedGP != null) {
      final result = {
        'districtId': _selectedDistrict!.id,
        'districtName': _selectedDistrict!.name,
        'blockId': _selectedBlock!.id,
        'blockName': _selectedBlock!.name,
        'gpId': _selectedGP!.id,
        'gpName': _selectedGP!.name,
      };

      // Save inspection location based on user role
      _saveInspectionLocation(result);

      if (widget.onLocationSelected != null) {
        widget.onLocationSelected!(result);
      }
      Navigator.pop(context, result);
    }
  }

  Future<void> _saveInspectionLocation(Map<String, dynamic> location) async {
    // Store inspection location separately for each user role
    final role = widget.userRole ?? 'ceo';
    await _authService.saveInspectionLocation(role, location);
  }

  void _showDistrictBottomSheet() {
    if (_districts.isEmpty) return;

    BottomSheetPicker.show<District>(
      context: context,
      title: 'Select District',
      items: _districts,
      itemBuilder: (district) => district.name,
      selectedItem: _selectedDistrict,
      onSelected: (district) {
        setState(() {
          _selectedDistrict = district;
          _districtId = district.id;
          _districtName = district.name;
          _selectedBlock = null;
          _selectedGP = null;
          _gramPanchayats = [];
        });
        _loadBlocks(district.id);
      },
      isLoading: _isLoadingDistricts,
      showSearch: true,
      searchHint: 'Search district...',
    );
  }

  void _showBlockBottomSheet() {
    if (_districtId == null || _blocks.isEmpty) return;

    BottomSheetPicker.show<Block>(
      context: context,
      title: 'Select Block',
      items: _blocks,
      itemBuilder: (block) => block.name,
      selectedItem: _selectedBlock,
      onSelected: (block) {
        setState(() {
          _selectedBlock = block;
          _selectedGP = null;
        });
        if (_districtId != null) {
          _loadGramPanchayats(_districtId!, block.id);
        }
      },
      isLoading: _isLoadingBlocks,
      showSearch: true,
      searchHint: 'Search block...',
    );
  }

  void _showGPBottomSheet() {
    if (_selectedBlock == null || _districtId == null || _gramPanchayats.isEmpty) {
      return;
    }

    BottomSheetPicker.show<GramPanchayat>(
      context: context,
      title: 'Select Gram Panchayat',
      items: _gramPanchayats,
      itemBuilder: (gp) => gp.name,
      selectedItem: _selectedGP,
      onSelected: (gp) {
        setState(() {
          _selectedGP = gp;
        });
      },
      isLoading: _isLoadingGPs,
      showSearch: true,
      searchHint: 'Search gram panchayat...',
    );
  }

}
