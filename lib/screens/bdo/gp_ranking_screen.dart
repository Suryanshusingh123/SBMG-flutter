import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../widgets/common/date_filter_bottom_sheet.dart';

class GpRankingScreen extends StatefulWidget {
  const GpRankingScreen({super.key});

  @override
  State<GpRankingScreen> createState() => _GpRankingScreenState();
}

class _GpRankingScreenState extends State<GpRankingScreen> {
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  bool _isLoading = true;
  int? _blockId;
  int? _districtId;
  DateTime _selectedDate = DateTime.now();
  String _selectedMonthName = '';

  // Ranking data: list of {gp, presentDays}
  List<_GpRank> _ranks = [];

  @override
  void initState() {
    super.initState();
    _selectedMonthName = DateFormat('MMMM').format(_selectedDate);
    _initialize();
  }

  Future<void> _initialize() async {
    final blockId = await _auth.getBlockId();
    final districtId = await _auth.getDistrictId();
    setState(() {
      _blockId = blockId;
      _districtId = districtId;
    });
    await _fetchRankings();
  }

  Future<void> _fetchRankings({DateTime? startDate, DateTime? endDate}) async {
    if (_blockId == null || _districtId == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);

    // Determine date range: default to current month
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
      // 1) Fetch all GPs for the block
      final gps = await _api.getGramPanchayats(blockId: _blockId!, districtId: _districtId!);

      // 2) For each GP, fetch attendance and count present days
      final results = await Future.wait(gps.map((gp) async {
        final resp = await _api.getAttendanceViewForBDO(
          villageId: gp.id,
          blockId: _blockId,
          districtId: _districtId,
          startDate: startStr,
          endDate: endStr,
          skip: 0,
          limit: 500,
        );
        int presentDays = 0;
        if (resp['success'] == true) {
          final data = resp['data'] as Map<String, dynamic>;
          final list = List<Map<String, dynamic>>.from(data['attendances'] ?? []);
          presentDays = list.where((e) => e['end_time'] != null).length;
        }
        return _GpRank(gp: gp, presentDays: presentDays);
      }));

      results.sort((a, b) => b.presentDays.compareTo(a.presentDays));

      setState(() {
        _ranks = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rankings: $e'), backgroundColor: Colors.red),
        );
      }
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
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.grey.shade700),
            onPressed: _showDateFilter,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF009B56)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text(_selectedMonthName,
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: _ranks.length,
                    itemBuilder: (context, index) {
                      final item = _ranks[index];
                      return _rankTile(index + 1, item.gp.name, item.presentDays);
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$rank. $gpName',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF111827)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${days}days',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xFF6B7280)),
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


