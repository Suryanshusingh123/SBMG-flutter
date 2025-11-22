import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

class CeoSelectGpScreen extends StatefulWidget {
  final bool returnOnTap;
  const CeoSelectGpScreen({super.key, this.returnOnTap = false});

  @override
  State<CeoSelectGpScreen> createState() => _CeoSelectGpScreenState();
}

class _CeoSelectGpScreenState extends State<CeoSelectGpScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  int? _districtId;
  List<Block> _blocks = [];
  Block? _selectedBlock;
  List<GramPanchayat> _gramPanchayats = [];

  bool _isLoadingBlocks = false;
  bool _isLoadingGps = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final districtId = await _authService.getDistrictId();
    if (districtId == null) {
      setState(() {
        _error = 'District information not available.';
      });
      return;
    }

    setState(() {
      _districtId = districtId;
    });

    // Check if blockId is stored
    final blockId = await _authService.getBlockId();
    if (blockId != null) {
      // If blockId exists, load GPs directly
      await _loadGpsForBlock(districtId, blockId);
    } else {
      // If blockId is null, load blocks first
      await _loadBlocks(districtId);
    }
  }

  Future<void> _loadBlocks(int districtId) async {
    setState(() {
      _isLoadingBlocks = true;
      _error = null;
    });

    try {
      final blocks = await _apiService.getBlocks(districtId: districtId, limit: 200);
      setState(() {
        _blocks = blocks;
        _isLoadingBlocks = false;
        // Auto-select first block if available
        if (blocks.isNotEmpty && _selectedBlock == null) {
          _selectedBlock = blocks.first;
          _loadGpsForBlock(districtId, blocks.first.id);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingBlocks = false;
        _error = 'Failed to load blocks: $e';
      });
      debugPrint('❌ [CeoSelectGpScreen] Error loading blocks: $e');
    }
  }

  Future<void> _loadGpsForBlock(int districtId, int blockId) async {
    setState(() {
      _isLoadingGps = true;
      _error = null;
    });

    try {
      final gps = await _apiService.getGramPanchayats(
        districtId: districtId,
        blockId: blockId,
        limit: 200,
      );
      debugPrint(
          '✅ [CeoSelectGpScreen] Loaded ${gps.length} GPs for blockId=$blockId');
      setState(() {
        _gramPanchayats = gps;
        _isLoadingGps = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGps = false;
        _error = 'Failed to load Gram Panchayats: $e';
      });
      debugPrint('❌ [CeoSelectGpScreen] Error loading GPs: $e');
    }
  }

  void _onBlockSelected(Block block) {
    setState(() {
      _selectedBlock = block;
      _gramPanchayats = []; // Clear previous GPs
    });
    if (_districtId != null) {
      _loadGpsForBlock(_districtId!, block.id);
    }
  }

  void _handleGpTap(GramPanchayat gp) {
    if (widget.returnOnTap) {
      Navigator.pop(context, {'gpId': gp.id, 'gpName': gp.name});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Gram Panchayat'),
      ),
      body: _districtId == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  _error ?? 'District information not available.',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _blocks.isEmpty && _selectedBlock == null
              ? _isLoadingBlocks
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          _error ?? 'No blocks available.',
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF6B7280)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
              : Column(
                  children: [
                    // Block selector (if blocks are available and no block is pre-selected)
                    if (_blocks.isNotEmpty && _selectedBlock == null)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: GestureDetector(
                          onTap: () => _showBlockBottomSheet(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Select Block',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (_selectedBlock != null)
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: GestureDetector(
                          onTap: () => _showBlockBottomSheet(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedBlock!.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Color(0xFF9CA3AF)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // GP List
                    Expanded(
                      child: _isLoadingGps
                          ? const Center(child: CircularProgressIndicator())
                          : _gramPanchayats.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Text(
                                      _error ??
                                          (_selectedBlock == null
                                              ? 'Please select a block first.'
                                              : 'No Gram Panchayats found for this block.'),
                                      style: const TextStyle(
                                          fontSize: 16, color: Color(0xFF6B7280)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  itemCount: _gramPanchayats.length,
                                  itemBuilder: (context, index) {
                                    final gp = _gramPanchayats[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          gp.name,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        trailing: const Icon(Icons.chevron_right,
                                            color: Color(0xFF9CA3AF)),
                                        onTap: () => _handleGpTap(gp),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
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
        _onBlockSelected(block);
      },
      isLoading: _isLoadingBlocks,
      showSearch: true,
      searchHint: 'Search Block...',
    );
  }
}
