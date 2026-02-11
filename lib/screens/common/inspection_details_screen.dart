import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../config/connstants.dart';
import '../../models/inspection_model.dart';
import '../../services/api_services.dart';
import '../../utils/date_time_utils.dart';

/// Screen to display full details of a single inspection.
/// Used by SMD, CEO, BDO, and VDO when an inspection list item is tapped.
class InspectionDetailsScreen extends StatefulWidget {
  const InspectionDetailsScreen({
    super.key,
    required this.inspectionId,
  });

  final int inspectionId;

  @override
  State<InspectionDetailsScreen> createState() =>
      _InspectionDetailsScreenState();
}

class _InspectionDetailsScreenState extends State<InspectionDetailsScreen> {
  final ApiService _apiService = ApiService();
  Inspection? _inspection;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInspection();
  }

  Future<void> _loadInspection() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final inspection = await _apiService.getInspection(widget.inspectionId);
      if (!mounted) return;
      setState(() {
        _inspection = inspection;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Backend sends date/time in UTC; convert to IST for display.
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '—';
    try {
      final ist = DateTimeUtils.parseToIST(dateString);
      return DateFormat('d MMM yyyy').format(ist);
    } catch (_) {
      return dateString;
    }
  }

  /// Backend sends date/time in UTC; convert to IST for display.
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '—';
    try {
      final ist = DateTimeUtils.parseToIST(dateTimeString);
      return DateFormat('d MMM yyyy, hh:mm a').format(ist);
    } catch (_) {
      return dateTimeString;
    }
  }

  String _display(String? value) => (value == null || value.isEmpty) ? '—' : value;

  String _yesNo(bool value) => value ? 'Yes' : 'No';

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
        title: Text(
          'Inspection Details',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 14.sp,
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: _loadInspection,
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
                  ),
                )
              : _inspection == null
                  ? const Center(child: Text('Inspection not found'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Basic information'),
                          _buildDetailCard([
                            _buildRow('Date', _formatDate(_inspection!.date)),
                            _buildRow('Start time', _formatDateTime(_inspection!.startTime)),
                            _buildRow('Village', _inspection!.villageName),
                            _buildRow('Block', _inspection!.blockName),
                            _buildRow('District', _inspection!.districtName),
                            _buildRow('Officer', _inspection!.officerName),
                            _buildRow('Role', _inspection!.officerRole),
                            if (_inspection!.positionHolderId != null)
                              _buildRow('Position holder ID', _inspection!.positionHolderId.toString()),
                            _buildRow('Register maintenance', _yesNo(_inspection!.registerMaintenance ?? _inspection!.visiblyClean)),
                            if (_inspection!.lat != null && _inspection!.lat != 'string')
                              _buildRow('Latitude', _display(_inspection!.lat)),
                            if (_inspection!.long != null && _inspection!.long != 'string')
                              _buildRow('Longitude', _display(_inspection!.long)),
                            if (_inspection!.overallScore > 0)
                              _buildRow('Overall score', _inspection!.overallScore.toStringAsFixed(1)),
                          ]),
                          if (_inspection!.remarks.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Remarks'),
                            _buildDetailCard([
                              _buildRow('Remarks', _inspection!.remarks),
                            ]),
                          ],
                          if (_inspection!.householdWaste != null) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Household waste'),
                            _buildDetailCard(_householdWasteRows(_inspection!.householdWaste!)),
                          ],
                          if (_inspection!.roadAndDrain != null) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Road and drain'),
                            _buildDetailCard(_roadAndDrainRows(_inspection!.roadAndDrain!)),
                          ],
                          if (_inspection!.communitySanitation != null) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Community sanitation'),
                            _buildDetailCard(_communitySanitationRows(_inspection!.communitySanitation!)),
                          ],
                          if (_inspection!.otherItems != null) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Other items'),
                            _buildDetailCard(_otherItemsRows(_inspection!.otherItems!)),
                          ],
                          if ((_inspection!.mediaUrls ?? []).isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            _buildSectionTitle('Photos'),
                            _buildImagesSection(),
                          ],
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Noto Sans',
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _householdWasteRows(HouseholdWaste h) {
    return [
      _buildRow('Waste collection frequency', _display(h.wasteCollectionFrequency)),
      _buildRow('Dry/wet vehicle segregation', _yesNo(h.dryWetVehicleSegregation)),
      _buildRow('Covered collection in vehicles', _yesNo(h.coveredCollectionInVehicles)),
      _buildRow('Waste disposed at RRC', _yesNo(h.wasteDisposedAtRrc)),
      _buildRow('RRC waste collection and disposal arrangement', _yesNo(h.rrcWasteCollectionAndDisposalArrangement)),
      _buildRow('Waste collection vehicle functional', _yesNo(h.wasteCollectionVehicleFunctional)),
    ];
  }

  List<Widget> _roadAndDrainRows(RoadAndDrain r) {
    return [
      _buildRow('Road cleaning frequency', _display(r.roadCleaningFrequency)),
      _buildRow('Drain cleaning frequency', _display(r.drainCleaningFrequency)),
      _buildRow('Disposal of sludge from drains', _yesNo(r.disposalOfSludgeFromDrains)),
      _buildRow('Drain waste collected on roadside', _yesNo(r.drainWasteCollectedOnRoadside)),
    ];
  }

  List<Widget> _communitySanitationRows(CommunitySanitation c) {
    return [
      _buildRow('CSC cleaning frequency', _display(c.cscCleaningFrequency)),
      _buildRow('Electricity and water', _yesNo(c.electricityAndWater)),
      _buildRow('CSC used by community', _yesNo(c.cscUsedByCommunity)),
      _buildRow('Pink toilets cleaning', _yesNo(c.pinkToiletsCleaning)),
      _buildRow('Pink toilets used', _yesNo(c.pinkToiletsUsed)),
    ];
  }

  List<Widget> _otherItemsRows(InspectionOtherItems o) {
    return [
      _buildRow('Firm paid regularly', _yesNo(o.firmPaidRegularly)),
      _buildRow('Cleaning staff paid regularly', _yesNo(o.cleaningStaffPaidRegularly)),
      _buildRow('Firm provided safety equipment', _yesNo(o.firmProvidedSafetyEquipment)),
      _buildRow('Regular feedback register entry', _yesNo(o.regularFeedbackRegisterEntry)),
      _buildRow('Chart prepared for cleaning work', _yesNo(o.chartPreparedForCleaningWork)),
      _buildRow('Village visibly clean', _yesNo(o.villageVisiblyClean)),
      _buildRow('Rate chart displayed', _yesNo(o.rateChartDisplayed)),
    ];
  }

  Widget _buildImagesSection() {
    final urls = _inspection!.mediaUrls ?? [];
    return _buildDetailCard([
      SizedBox(
        height: 120.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: urls.length,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final url = ApiConstants.getMediaUrl(urls[index]);
            return ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 120.w,
                height: 120.h,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 32.sp,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
