import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';

class SmdSelectGpScreen extends StatefulWidget {
  final bool returnOnTap;
  const SmdSelectGpScreen({super.key, this.returnOnTap = false});

  @override
  State<SmdSelectGpScreen> createState() => _SmdSelectGpScreenState();
}

class _SmdSelectGpScreenState extends State<SmdSelectGpScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  bool _isGpLoading = false;
  String? _error;
  List<Block> _blocks = [];
  List<GramPanchayat> _gramPanchayats = [];
  Block? _selectedBlock;
  int? _districtId;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  Future<void> _loadBlocks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _blocks = [];
        _selectedBlock = null;
      });

      final districtId = await _authService.getSmdSelectedDistrictId();
      if (districtId == null) {
        setState(() {
          _isLoading = false;
          _error =
              'Please select a district first to view Gram Panchayats.';
        });
        return;
      }

      _districtId = districtId;
      final blocks = await _apiService.getBlocks(
        districtId: districtId,
        limit: 100,
      );

      setState(() {
        _blocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load blocks: $e';
      });
    }
  }

  Future<void> _loadGramPanchayats(Block block) async {
    if (_districtId == null) return;

    try {
      setState(() {
        _isGpLoading = true;
        _error = null;
        _selectedBlock = block;
        _gramPanchayats = [];
      });

      final gps = await _apiService.getGramPanchayats(
        blockId: block.id,
        districtId: _districtId!,
        limit: 100,
      );

      setState(() {
        _gramPanchayats = gps;
        _isGpLoading = false;
      });
    } catch (e) {
      setState(() {
        _isGpLoading = false;
        _error = 'Failed to load Gram Panchayats: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedBlock == null ? 'Select Block' : 'Select GP',
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {
            if (_selectedBlock != null) {
              setState(() {
                _selectedBlock = null;
                _gramPanchayats = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _selectedBlock == null
                  ? _buildBlocksList()
                  : _buildGpList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            _error ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadBlocks,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlocksList() {
    if (_blocks.isEmpty) {
      return const Center(
        child: Text('No blocks found'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];
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
          ),
          child: ListTile(
            title: Text(
              block.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
            onTap: () => _loadGramPanchayats(block),
          ),
        );
      },
    );
  }

  Widget _buildGpList() {
    if (_isGpLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gramPanchayats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No Gram Panchayats found for ${_selectedBlock?.name ?? ''}',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedBlock = null;
                  _gramPanchayats = [];
                });
              },
              child: const Text('Choose another block'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
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
            subtitle: _selectedBlock != null
                ? Text(
                    _selectedBlock!.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  )
                : null,
            trailing: const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
            ),
            onTap: () {
              if (widget.returnOnTap) {
                Navigator.pop(context, {
                  'gpId': gp.id,
                  'gpName': gp.name,
                  'blockId': _selectedBlock?.id,
                });
              }
            },
          ),
        );
      },
    );
  }
}

