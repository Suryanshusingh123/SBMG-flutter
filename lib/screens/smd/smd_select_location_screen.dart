import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';

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
                    onTap: () => _showBlockBottomSheet(),
                  ),
                  const SizedBox(height: 16),

                  // Gram Panchayat Selection
                  _buildLocationField(
                    label: 'Gram Panchayat',
                    value: _selectedGP?.name,
                    onTap: () => _showGPBottomSheet(),
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
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
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
    return _selectedBlock != null && _selectedGP != null;
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
        // Navigate to inspection form with selected location
      }
    }
  }

  void _showBlockBottomSheet() {
    if (_blocks.isEmpty && _districtId != null) {
      _loadBlocks(_districtId!);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Top handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Text(
                  'Select Block',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search block',
                    hintStyle: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
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
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              // Block List
              Expanded(
                child: _isLoadingBlocks
                    ? const Center(child: CircularProgressIndicator())
                    : _blocks.isEmpty
                    ? const Center(child: Text('No blocks found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _blocks.length,
                        itemBuilder: (context, index) {
                          final block = _blocks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
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
                                block.name,
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
                                Navigator.pop(context);
                                if (mounted) {
                                  setState(() {
                                    _selectedBlock = block;
                                    _selectedGP = null;
                                    _gramPanchayats = [];
                                  });
                                  _loadGramPanchayats(_districtId!, block.id);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGPBottomSheet() {
    if (_selectedBlock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Block first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_gramPanchayats.isEmpty) {
      _loadGramPanchayats(_districtId!, _selectedBlock!.id);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Top handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: const Text(
                  'Select Gram Panchayat',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              // GP List
              Expanded(
                child: _isLoadingGPs
                    ? const Center(child: CircularProgressIndicator())
                    : _gramPanchayats.isEmpty
                    ? const Center(child: Text('No Gram Panchayats found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _gramPanchayats.length,
                        itemBuilder: (context, index) {
                          final gp = _gramPanchayats[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
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
                                Navigator.pop(context);
                                if (mounted) {
                                  setState(() {
                                    _selectedGP = gp;
                                  });
                                  // Auto-apply after GP selection
                                  _applyLocation();
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
