import 'package:flutter/material.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

class SmdSelectLocationScreen extends StatefulWidget {
  final String? actionType;
  final Function(Map<String, dynamic>)? onGpSelected;

  const SmdSelectLocationScreen({
    super.key,
    this.actionType,
    this.onGpSelected,
  });

  @override
  State<SmdSelectLocationScreen> createState() =>
      _SmdSelectLocationScreenState();
}

class _SmdSelectLocationScreenState extends State<SmdSelectLocationScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  int? _districtId;
  List<Block> _blocks = [];
  List<GramPanchayat> _gramPanchayats = [];

  Block? _selectedBlock;
  GramPanchayat? _selectedGP;

  bool _isLoadingBlocks = false;
  bool _isLoadingGPs = false;

  final TextEditingController _searchController = TextEditingController();

  bool get _requiresGpSelection => widget.actionType != 'ranking';

  @override
  void initState() {
    super.initState();
    _loadDistrictAndBlocks();
  }

  Future<void> _loadDistrictAndBlocks() async {
    try {
      // Get district ID from SMD selected district
      _districtId = await _authService.getSmdSelectedDistrictId();

      if (_districtId == null) {
        print('❌ District ID not found for SMD');
        return;
      }

      // Load blocks for this district
      await _loadBlocks(_districtId!);
    } catch (e) {
      print('Error loading district and blocks: $e');
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
      print('Error loading blocks: $e');
    }
  }

  Future<void> _loadGramPanchayats(int districtId, int blockId) async {
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
      print('Error loading GPs: $e');
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
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search....',
                hintStyle: const TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  color: Color(0xFF9CA3AF),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Location Selection Fields
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Block Selection
                  _buildLocationField(
                    label: 'Block',
                    value: _selectedBlock?.name,
                    onTap: _isLoadingBlocks ? null : () => _showBlockBottomSheet(),
                    isLoading: _isLoadingBlocks,
                  ),
                  const SizedBox(height: 16),

                  // Gram Panchayat Selection
                  if (_requiresGpSelection)
                    _buildLocationField(
                      label: 'Gram Panchayat',
                      value: _selectedGP?.name,
                      onTap: (_selectedBlock == null || _isLoadingGPs)
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
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canApply() ? _applyLocation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canApply()
                      ? AppColors.primaryColor
                      : Colors.grey[300],
                  foregroundColor: _canApply()
                      ? Colors.white
                      : Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
    bool isLoading = false,
  }) {
    final isDisabled = onTap == null || isLoading;
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isDisabled ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: isLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF009B56),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Loading...',
                              style: TextStyle(
                                fontFamily: 'Noto Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          value ?? 'Select option',
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16,
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
    if (_selectedBlock == null) return false;
    if (_requiresGpSelection) {
      return _selectedGP != null;
    }
    return true;
  }

  void _resetSelections() {
    setState(() {
      _selectedBlock = null;
      _selectedGP = null;
      _gramPanchayats = [];
    });
  }

  void _applyLocation() {
    if (_canApply()) {
      if (widget.onGpSelected != null) {
        // Return selected GP to parent
        widget.onGpSelected!({
          'gpId': _selectedGP!.id,
          'gpName': _selectedGP!.name,
          'blockId': _selectedBlock!.id,
          'blockName': _selectedBlock!.name,
          'districtId': _districtId,
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context, {
          'gpId': _selectedGP?.id,
          'gpName': _selectedGP?.name,
          'blockId': _selectedBlock?.id,
          'blockName': _selectedBlock?.name,
          'districtId': _districtId,
        });
      }
    }
  }

  void _showBlockBottomSheet() {
    if (_blocks.isEmpty && _districtId != null && !_isLoadingBlocks) {
      _loadBlocks(_districtId!);
    }

    BottomSheetPicker.show<Block>(
      context: context,
      title: 'Select Block',
      items: _blocks,
      itemBuilder: (block) => block.name,
      selectedItem: _selectedBlock,
      isLoading: _isLoadingBlocks,
      showSearch: true,
      searchHint: 'Search block...',
      onSelected: (block) {
        setState(() {
          _selectedBlock = block;
          _selectedGP = null;
          _gramPanchayats = [];
        });
        if (_districtId != null) {
          _loadGramPanchayats(_districtId!, block.id);
        }
      },
    );
  }

  void _showGPBottomSheet() {
    if (!_requiresGpSelection) return;

    if (_gramPanchayats.isEmpty && _districtId != null && _selectedBlock != null && !_isLoadingGPs) {
      _loadGramPanchayats(_districtId!, _selectedBlock!.id);
    }

    BottomSheetPicker.show<GramPanchayat>(
      context: context,
      title: 'Select Gram Panchayat',
      items: _gramPanchayats,
      itemBuilder: (gp) => gp.name,
      selectedItem: _selectedGP,
      isLoading: _isLoadingGPs,
      showSearch: true,
      searchHint: 'Search GP...',
      onSelected: (gp) {
        setState(() {
          _selectedGP = gp;
        });
      },
    );
  }
}
