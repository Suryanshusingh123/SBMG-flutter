import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';

class CeoGpRankingScreen extends StatefulWidget {
  final int? initialDistrictId;
  final int? initialBlockId;
  final String? initialBlockName;

  const CeoGpRankingScreen({
    super.key,
    this.initialDistrictId,
    this.initialBlockId,
    this.initialBlockName,
  });

  @override
  State<CeoGpRankingScreen> createState() => _CeoGpRankingScreenState();
}

class _CeoGpRankingScreenState extends State<CeoGpRankingScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  bool _isLoading = true;
  bool _isBlockLoading = true;
  String? _error;

  int? _districtId;
  Block? _selectedBlock;
  List<Block> _blocks = [];

  DateTime _selectedDate = DateTime.now();
  String _selectedMonthName = '';

  List<_GpRank> _ranks = [];

  @override
  void initState() {
    super.initState();
    _selectedMonthName = DateFormat('MMMM').format(_selectedDate);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final districtId =
          widget.initialDistrictId ?? await _auth.getDistrictId();
      if (districtId == null) {
        setState(() {
          _isBlockLoading = false;
          _isLoading = false;
          _error = 'District information not available.';
        });
        return;
      }

      final blocks = await _api.getBlocks(districtId: districtId, limit: 100);

      Block? selectedBlock;
      if (widget.initialBlockId != null) {
        final matches = blocks.where(
          (block) => block.id == widget.initialBlockId,
        );
        if (matches.isNotEmpty) {
          selectedBlock = matches.first;
        } else if (blocks.isNotEmpty) {
          selectedBlock = blocks.first;
        } else {
          selectedBlock = Block(
            id: widget.initialBlockId!,
            name: widget.initialBlockName ?? 'Block',
            districtId: districtId,
            description: null,
          );
        }
      }

      selectedBlock ??= blocks.isNotEmpty ? blocks.first : null;

      setState(() {
        _districtId = districtId;
        _blocks = blocks;
        _selectedBlock = selectedBlock;
        _isBlockLoading = false;
      });

      if (_selectedBlock != null) {
        await _fetchRankings();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _isBlockLoading = false;
        _isLoading = false;
        _error = 'Failed to load blocks: $e';
      });
    }
  }

  Future<void> _fetchRankings({DateTime? startDate, DateTime? endDate}) async {
    if (_selectedBlock == null || _districtId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    DateTime rangeStart;
    DateTime rangeEnd;
    if (startDate != null && endDate != null) {
      rangeStart = startDate;
      rangeEnd = endDate;
    } else {
      final now = _selectedDate;
      rangeStart = DateTime(now.year, now.month, 1);
      rangeEnd = DateTime(now.year, now.month + 1, 0);
    }
    final startStr = DateFormat('yyyy-MM-dd').format(rangeStart);
    final endStr = DateFormat('yyyy-MM-dd').format(rangeEnd);

    try {
      final gps = await _api.getGramPanchayats(
        blockId: _selectedBlock!.id,
        districtId: _districtId!,
        limit: 100,
      );

      final results = await Future.wait(
        gps.map((gp) async {
          final resp = await _api.getAttendanceViewForBDO(
            villageId: gp.id,
            blockId: _selectedBlock!.id,
            districtId: _districtId,
            startDate: startStr,
            endDate: endStr,
            skip: 0,
            limit: 500,
          );
          int presentDays = 0;
          if (resp['success'] == true) {
            final data = resp['data'] as Map<String, dynamic>;
            final list = List<Map<String, dynamic>>.from(
              data['attendances'] ?? [],
            );
            presentDays = list.where((e) => e['end_time'] != null).length;
          }
          return _GpRank(gp: gp, presentDays: presentDays);
        }),
      );

      results.sort((a, b) => b.presentDays.compareTo(a.presentDays));

      setState(() {
        _ranks = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load rankings: $e';
      });
    }
  }

  void _showDateFilter() {
    showDateFilterBottomSheet(
      context: context,
      initialFilterType: DateFilterType.month,
      initialDate: _selectedDate,
      onApply: (type, selectedDate, startDate, endDate) {
        if (startDate != null && endDate != null) {
          setState(() {
            _selectedDate = startDate;
            _selectedMonthName = DateFormat('MMMM').format(startDate);
          });
          _fetchRankings(startDate: startDate, endDate: endDate);
        } else if (selectedDate != null) {
          setState(() {
            _selectedDate = selectedDate;
            _selectedMonthName = DateFormat('MMMM').format(selectedDate);
          });
          _fetchRankings(startDate: selectedDate, endDate: selectedDate);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GP ranking',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
            onPressed: _showDateFilter,
          ),
        ],
      ),
      body: _isBlockLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            )
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Block>(
                          value: _selectedBlock,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            filled: true,
                            fillColor: _isBlockLoading
                                ? Colors.grey.shade100
                                : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            suffixIcon: _isBlockLoading
                                ? Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF009B56),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.keyboard_arrow_down),
                          ),
                          icon: _isBlockLoading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.keyboard_arrow_down),
                          items: _isBlockLoading
                              ? null
                              : _blocks
                                  .map(
                                    (block) => DropdownMenuItem<Block>(
                                      value: block,
                                      child: Text(block.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged: _isBlockLoading
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() {
                                    _selectedBlock = value;
                                  });
                                  _fetchRankings();
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    _selectedMonthName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF009B56),
                          ),
                        )
                      : _ranks.isEmpty
                      ? Center(
                          child: Text(
                            'No data available for the selected block.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          itemCount: _ranks.length,
                          itemBuilder: (context, index) {
                            final item = _ranks[index];
                            return _rankTile(
                              index + 1,
                              item.gp.name,
                              item.presentDays,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _rankTile(int rank, String gpName, int days) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$rank. $gpName',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF111827),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${days}days',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpRank {
  final GramPanchayat gp;
  final int presentDays;

  _GpRank({required this.gp, required this.presentDays});
}
