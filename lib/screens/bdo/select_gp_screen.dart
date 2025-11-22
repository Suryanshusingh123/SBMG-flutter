import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/contractor_model.dart';
import 'package:intl/intl.dart';
import 'gp_attendance_screen.dart';
import '../../l10n/app_localizations.dart';

class SelectGpScreen extends StatefulWidget {
  final bool forAttendance;
  // When true, tapping a GP returns selection via Navigator.pop
  final bool returnOnTap;
  const SelectGpScreen({super.key, this.forAttendance = false, this.returnOnTap = false});
  @override
  State<SelectGpScreen> createState() => _SelectGpScreenState();
}

class _SelectGpScreenState extends State<SelectGpScreen> {
  late Future<List<GramPanchayat>> _gpFuture;

  @override
  void initState() {
    super.initState();
    _loadIdsAndGps();
  }

  void _loadIdsAndGps() async {
    final blockId = await AuthService().getBlockId();
    final districtId = await AuthService().getDistrictId();
    setState(() {
      if (blockId != null && districtId != null) {
        _gpFuture = ApiService().getGramPanchayats(
          blockId: blockId,
          districtId: districtId,
        );
      } else {
        _gpFuture = Future.value([]);
      }
    });
  }

  void _showContractorDetails(int gpId, String gpName) async {
    if (widget.returnOnTap) {
      if (!mounted) return;
      Navigator.pop(context, {'gpId': gpId, 'gpName': gpName});
      return;
    }
    if (widget.forAttendance) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GpAttendanceScreen(gpId: gpId, gpName: gpName),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final ContractorDetails contractor = await ApiService()
          .getContractorByGpId(gpId);
      if (context.mounted) {
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) =>
              BdoContractorDetailsBottomSheet(contractorDetails: contractor),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load contractor details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select GP'), centerTitle: false),
      body: FutureBuilder<List<GramPanchayat>>(
        future: _gpFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading GPs: ${snapshot.error}'));
          }
          final gps = snapshot.data ?? [];
          if (gps.isEmpty) {
            return const Center(child: Text('No Gram Panchayat found.'));
          }
          return ListView.builder(
            itemCount: gps.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            itemBuilder: (context, idx) {
              final gp = gps[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showContractorDetails(gp.id, gp.name),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            gp.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BdoContractorDetailsBottomSheet extends StatelessWidget {
  final ContractorDetails contractorDetails;
  const BdoContractorDetailsBottomSheet({
    required this.contractorDetails,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final details = contractorDetails;
    String formatDate(String dateStr) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
      } catch (_) {
        return dateStr;
      }
    }

    String duration(String? start, String? end) {
      if (start == null || end == null) return 'N/A';
      try {
        final s = DateTime.parse(start);
        final e = DateTime.parse(end);
        final m = (e.difference(s).inDays / 30).round();
        return '$m months';
      } catch (_) {
        return 'N/A';
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20.r),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n?.vendorDetails ?? 'Contractor Details',
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF111827)),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildDetailRow(l10n?.name ?? 'Name', details.personName),
            SizedBox(height: 16.h),
            _buildDetailRow(
              l10n?.workOrderDate ?? 'Work Order Date',
              formatDate(details.contractStartDate),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              l10n?.annualContractAmount ?? 'Annual Contract Amount',
              '₹ 12 Crore',
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              l10n?.durationOfWork ?? 'Duration of Work',
              duration(details.contractStartDate, details.contractEndDate),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(
              l10n?.frequencyOfWork ?? 'Frequency of Work',
              details.workFrequency,
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n?.close ?? 'Close',
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
