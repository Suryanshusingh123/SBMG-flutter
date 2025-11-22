import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

class CeoSelectLocationScreen extends StatefulWidget {
  final String actionType;
  final Map<String, dynamic>? initialSelection;

  const CeoSelectLocationScreen({
    super.key,
    required this.actionType,
    this.initialSelection,
  });

  @override
  State<CeoSelectLocationScreen> createState() =>
      _CeoSelectLocationScreenState();
}

class _CeoSelectLocationScreenState extends State<CeoSelectLocationScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  int? _districtId;
  String _districtName = '';

  List<Block> _blocks = [];
  List<GramPanchayat> _gramPanchayats = [];

  Block? _selectedBlock;
  GramPanchayat? _selectedGP;

  bool _isLoadingBlocks = false;
  bool _isLoadingGPs = false;

  bool get _requiresGpSelection => widget.actionType != 'ranking';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final districtId = await _authService.getDistrictId();
      if (districtId == null) {
        return;
      }

      final districts = await _apiService.getDistricts();
      final district = districts.firstWhere(
        (d) => d.id == districtId,
        orElse: () => District(id: districtId, name: 'District'),
      );

      setState(() {
        _districtId = districtId;
        _districtName = district.name;
      });

      await _loadBlocks(districtId);

      final initialBlockId = widget.initialSelection?['blockId'] as int?;
      final initialGpId = widget.initialSelection?['gpId'] as int?;

      if (initialBlockId != null) {
        final matches = _blocks.where((b) => b.id == initialBlockId);
        Block resolvedBlock;
        if (matches.isNotEmpty) {
          resolvedBlock = matches.first;
        } else if (_blocks.isNotEmpty) {
          resolvedBlock = _blocks.first;
        } else {
          resolvedBlock = Block(
            id: initialBlockId,
            name: widget.initialSelection?['blockName'] as String? ?? 'Block',
            districtId: districtId,
            description: null,
          );
          _blocks = [resolvedBlock, ..._blocks];
        }

        setState(() => _selectedBlock = resolvedBlock);

        if (_selectedBlock != null && _requiresGpSelection) {
          await _loadGramPanchayats(districtId, _selectedBlock!.id);

          if (initialGpId != null) {
            final gpMatches = _gramPanchayats.where((g) => g.id == initialGpId);
            if (gpMatches.isNotEmpty) {
              setState(() => _selectedGP = gpMatches.first);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing CEO location screen: $e');
    }
  }

  Future<void> _loadBlocks(int districtId) async {
    setState(() => _isLoadingBlocks = true);
    try {
      final blocks = await _apiService.getBlocks(districtId: districtId);
      setState(() {
        _blocks = blocks;
        _isLoadingBlocks = false;
      });
    } catch (e) {
      setState(() => _isLoadingBlocks = false);
      debugPrint('Error loading blocks: $e');
    }
  }

  Future<void> _loadGramPanchayats(int districtId, int blockId) async {
    if (!_requiresGpSelection) {
      return;
    }

    setState(() => _isLoadingGPs = true);
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
      setState(() => _isLoadingGPs = false);
      debugPrint('Error loading GPs: $e');
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  _buildDisabledField(
                    'District',
                    _districtName.isEmpty ? 'Loading...' : _districtName,
                  ),
                  SizedBox(height: 16.h),
                  _buildLocationField(
                    label: 'Block',
                    value: _selectedBlock?.name,
                    onTap: (_districtId == null || _isLoadingBlocks)
                        ? null
                        : () => _showBlockBottomSheet(),
                    isLoading: _isLoadingBlocks,
                  ),
                  if (_requiresGpSelection) ...[
                    SizedBox(height: 16.h),
                    _buildLocationField(
                      label: 'Gram Panchayat',
                      value: _selectedGP?.name,
                      onTap: (_selectedBlock == null || _districtId == null || _isLoadingGPs)
                          ? null
                          : () => _showGpBottomSheet(),
                      isLoading: _isLoadingGPs,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _canApply() ? _applySelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canApply()
                      ? AppColors.primaryColor
                      : Colors.grey[300],
                  foregroundColor: _canApply()
                      ? Colors.white
                      : Colors.grey[600],
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

  Widget _buildDisabledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField({
    required String label,
    required String? value,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    final isDisabled = onTap == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: isDisabled ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
    if (_selectedBlock == null) {
      return false;
    }
    if (_requiresGpSelection) {
      return _selectedGP != null;
    }
    return true;
  }

  void _applySelection() {
    if (_canApply()) {
      Navigator.pop(context, {
        'actionType': widget.actionType,
        'districtId': _districtId,
        'districtName': _districtName,
        'blockId': _selectedBlock?.id,
        'blockName': _selectedBlock?.name,
        'gpId': _selectedGP?.id,
        'gpName': _selectedGP?.name,
      });
    }
  }

  void _showBlockBottomSheet() {
    if (_districtId == null) return;

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
        if (_requiresGpSelection) {
          _loadGramPanchayats(_districtId!, block.id);
        }
      },
      isLoading: _isLoadingBlocks,
      showSearch: true,
      searchHint: 'Search Block...',
    );
  }

  void _showGpBottomSheet() {
    if (!_requiresGpSelection ||
        _districtId == null ||
        _selectedBlock == null) {
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
      searchHint: 'Search Gram Panchayat...',
    );
  }
}
