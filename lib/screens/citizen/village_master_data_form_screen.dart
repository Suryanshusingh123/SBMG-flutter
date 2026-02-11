import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/api_services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/citizen_colors.dart';

class VillageMasterDataFormScreen extends StatefulWidget {
  /// Gram Panchayat ID used for GET /api/v1/annual-surveys/latest-for-gp/{gp_id}.
  final int gpId;

  /// When set (e.g. from VDO View), a pencil icon is shown in the app bar to edit.
  /// Called with current survey id and full survey data when user taps edit.
  /// Should return true if the user saved changes so this screen can refresh.
  final Future<bool>? Function(int surveyId, Map<String, dynamic> data)? onEditTapped;

  const VillageMasterDataFormScreen({
    super.key,
    required this.gpId,
    this.onEditTapped,
  });

  @override
  State<VillageMasterDataFormScreen> createState() =>
      _VillageMasterDataFormScreenState();
}

class _VillageMasterDataFormScreenState
    extends State<VillageMasterDataFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers (only fields from GET /api/v1/annual-surveys/latest-for-gp/{gp_id})
  final _surveyDateController = TextEditingController();
  final _gpNameController = TextEditingController();
  final _blockNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _numWardPanchsController = TextEditingController();
  final _agencyIdController = TextEditingController();
  final _vdoNameController = TextEditingController();
  final _sarpanchNameController = TextEditingController();
  final _sarpanchContactController = TextEditingController();
  final _workOrderNoController = TextEditingController();
  final _workOrderDateController = TextEditingController();
  final _workOrderAmountController = TextEditingController();
  final _fundAmountController = TextEditingController();
  final _fundHeadController = TextEditingController();
  final _householdsController = TextEditingController();
  final _shopsController = TextEditingController();
  final _collectionFrequencyController = TextEditingController();

  // Road Sweeping controllers
  final _roadWidthController = TextEditingController();
  final _roadLengthController = TextEditingController();
  final _roadCleaningFrequencyController = TextEditingController();

  // Drain Cleaning controllers
  final _drainLengthController = TextEditingController();
  final _drainCleaningFrequencyController = TextEditingController();

  // CSC Details controllers
  final _cscNumbersController = TextEditingController();
  final _cscCleaningFrequencyController = TextEditingController();

  // SWM Assets controllers
  final _rrcController = TextEditingController();
  final _pwmuController = TextEditingController();
  final _compostPitController = TextEditingController();
  final _collectionVehicleController = TextEditingController();

  // SBMG Targets controllers
  final _sbmgIhhlController = TextEditingController();
  final _sbmgCscController = TextEditingController();
  final _sbmgRrcController = TextEditingController();
  final _sbmgPwmuController = TextEditingController();
  final _soakPitController = TextEditingController();
  final _magicPitController = TextEditingController();
  final _leachPitController = TextEditingController();
  final _wspController = TextEditingController();
  final _dewatsController = TextEditingController();

  final _createdAtController = TextEditingController();
  final _updatedAtController = TextEditingController();

  // Expansion states
  bool _sarpanchExpanded = false;
  bool _workOrderExpanded = false;
  bool _fundExpanded = false;
  bool _collectionExpanded = false;
  bool _roadSweepingExpanded = false;
  bool _drainCleaningExpanded = false;
  bool _cscDetailsExpanded = false;
  bool _swmAssetsExpanded = false;
  bool _sbmgTargetsExpanded = false;
  bool _villageDataExpanded = false;

  // Survey data and village_data from API
  Map<String, dynamic>? surveyData;
  List<Map<String, dynamic>> _villageData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveyData();
  }

  /// Fetches survey via GET /api/v1/annual-surveys/latest-for-gp/{gp_id}.
  /// Response is the full survey (same shape as before); no second call needed.
  Future<void> _loadSurveyData() async {
    try {
      setState(() => isLoading = true);
      final data = await ApiService().getLatestAnnualSurveyForGp(widget.gpId);
      if (!mounted) return;
      setState(() {
        surveyData = data;
        isLoading = false;
      });
      _populateFieldsFromData(data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        surveyData = null;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noSurveyDataAvailable),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _populateFieldsFromData(Map<String, dynamic> data) {
    setState(() {
      _sarpanchExpanded = true;
      _workOrderExpanded = true;
      _fundExpanded = true;
      _collectionExpanded = true;
      _roadSweepingExpanded = true;
      _drainCleaningExpanded = true;
      _cscDetailsExpanded = true;
      _swmAssetsExpanded = true;
      _sbmgTargetsExpanded = true;
      _villageDataExpanded = true;
    });

    // Basic info (id, fy_id, gp_id, survey_date, gp_name, block_name, district_name, vdo_id, agency_id)
    _surveyDateController.text = data['survey_date'] != null
        ? _formatDate(data['survey_date'].toString())
        : '';
    _gpNameController.text = data['gp_name']?.toString() ?? '';
    _blockNameController.text = data['block_name']?.toString() ?? '';
    _districtNameController.text = data['district_name']?.toString() ?? '';
    _numWardPanchsController.text =
        data['num_ward_panchs']?.toString() ?? '';
    _agencyIdController.text = data['agency_id']?.toString() ?? '';
    if (data['created_at'] != null) {
      _createdAtController.text =
          _formatDateTime(data['created_at'].toString());
    }
    if (data['updated_at'] != null) {
      _updatedAtController.text =
          _formatDateTime(data['updated_at'].toString());
    }

    _vdoNameController.text =
        (data['vdo_name']?.toString() ?? '').trim();
    if (_vdoNameController.text.isEmpty &&
        data.containsKey('vdo') &&
        data['vdo'] != null) {
      final vdo = data['vdo'] as Map<String, dynamic>;
      _vdoNameController.text =
          '${vdo['first_name'] ?? ''} ${vdo['last_name'] ?? ''}'.trim();
    }

    _sarpanchNameController.text =
        data['sarpanch_name']?.toString() ?? '';
    _sarpanchContactController.text =
        data['sarpanch_contact']?.toString() ?? '';

    if (data.containsKey('work_order') && data['work_order'] != null) {
      final wo = data['work_order'] as Map<String, dynamic>;
      _workOrderNoController.text = wo['work_order_no']?.toString() ?? '';
      if (wo['work_order_date'] != null) {
        _workOrderDateController.text =
            _formatDate(wo['work_order_date'].toString());
      }
      _workOrderAmountController.text =
          wo['work_order_amount']?.toString() ?? '';
    }

    if (data.containsKey('fund_sanctioned') &&
        data['fund_sanctioned'] != null) {
      final fund = data['fund_sanctioned'] as Map<String, dynamic>;
      _fundAmountController.text = fund['amount']?.toString() ?? '';
      _fundHeadController.text = fund['head']?.toString() ?? '';
    }

    if (data.containsKey('door_to_door_collection') &&
        data['door_to_door_collection'] != null) {
      final dtd =
          data['door_to_door_collection'] as Map<String, dynamic>;
      _householdsController.text = dtd['num_households']?.toString() ?? '';
      _shopsController.text = dtd['num_shops']?.toString() ?? '';
      _collectionFrequencyController.text =
          dtd['collection_frequency']?.toString() ?? '';
    }

    if (data.containsKey('road_sweeping') && data['road_sweeping'] != null) {
      final rs = data['road_sweeping'] as Map<String, dynamic>;
      _roadWidthController.text = rs['width']?.toString() ?? '';
      _roadLengthController.text = rs['length']?.toString() ?? '';
      _roadCleaningFrequencyController.text =
          rs['cleaning_frequency']?.toString() ?? '';
    }

    if (data.containsKey('drain_cleaning') &&
        data['drain_cleaning'] != null) {
      final dc = data['drain_cleaning'] as Map<String, dynamic>;
      _drainLengthController.text = dc['length']?.toString() ?? '';
      _drainCleaningFrequencyController.text =
          dc['cleaning_frequency']?.toString() ?? '';
    }

    if (data.containsKey('csc_details') && data['csc_details'] != null) {
      final csc = data['csc_details'] as Map<String, dynamic>;
      _cscNumbersController.text = csc['numbers']?.toString() ?? '';
      _cscCleaningFrequencyController.text =
          csc['cleaning_frequency']?.toString() ?? '';
    }

    if (data.containsKey('swm_assets') && data['swm_assets'] != null) {
      final swm = data['swm_assets'] as Map<String, dynamic>;
      _rrcController.text = swm['rrc']?.toString() ?? '';
      _pwmuController.text = swm['pwmu']?.toString() ?? '';
      _compostPitController.text = swm['compost_pit']?.toString() ?? '';
      _collectionVehicleController.text =
          swm['collection_vehicle']?.toString() ?? '';
    }

    if (data.containsKey('sbmg_targets') && data['sbmg_targets'] != null) {
      final sbmg = data['sbmg_targets'] as Map<String, dynamic>;
      _sbmgIhhlController.text = sbmg['ihhl']?.toString() ?? '';
      _sbmgCscController.text = sbmg['csc']?.toString() ?? '';
      _sbmgRrcController.text = sbmg['rrc']?.toString() ?? '';
      _sbmgPwmuController.text = sbmg['pwmu']?.toString() ?? '';
      _soakPitController.text = sbmg['soak_pit']?.toString() ?? '';
      _magicPitController.text = sbmg['magic_pit']?.toString() ?? '';
      _leachPitController.text = sbmg['leach_pit']?.toString() ?? '';
      _wspController.text = sbmg['wsp']?.toString() ?? '';
      _dewatsController.text = sbmg['dewats']?.toString() ?? '';
    }

    if (data.containsKey('village_data') && data['village_data'] is List) {
      _villageData = (data['village_data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else {
      _villageData = [];
    }
  }

  String _formatDateTime(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return dateString;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  void dispose() {
    _surveyDateController.dispose();
    _gpNameController.dispose();
    _blockNameController.dispose();
    _districtNameController.dispose();
    _numWardPanchsController.dispose();
    _agencyIdController.dispose();
    _vdoNameController.dispose();
    _sarpanchNameController.dispose();
    _sarpanchContactController.dispose();
    _workOrderNoController.dispose();
    _workOrderDateController.dispose();
    _workOrderAmountController.dispose();
    _fundAmountController.dispose();
    _fundHeadController.dispose();
    _householdsController.dispose();
    _shopsController.dispose();
    _collectionFrequencyController.dispose();
    _roadWidthController.dispose();
    _roadLengthController.dispose();
    _roadCleaningFrequencyController.dispose();
    _drainLengthController.dispose();
    _drainCleaningFrequencyController.dispose();
    _cscNumbersController.dispose();
    _cscCleaningFrequencyController.dispose();
    _rrcController.dispose();
    _pwmuController.dispose();
    _compostPitController.dispose();
    _collectionVehicleController.dispose();
    _sbmgIhhlController.dispose();
    _sbmgCscController.dispose();
    _sbmgRrcController.dispose();
    _sbmgPwmuController.dispose();
    _soakPitController.dispose();
    _magicPitController.dispose();
    _leachPitController.dispose();
    _wspController.dispose();
    _dewatsController.dispose();
    _createdAtController.dispose();
    _updatedAtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    final hasSurveyData = surveyData != null && surveyData!.isNotEmpty;
    return Scaffold(
      backgroundColor: CitizenColors.background(context),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.villageMasterDataForm,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.onEditTapped != null && hasSurveyData && surveyData != null) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: primaryTextColor),
              onPressed: () async {
                final id = surveyData!['id'];
                final surveyId = id is int
                    ? id
                    : int.tryParse(id?.toString() ?? '');
                if (surveyId != null) {
                  final updated = await widget.onEditTapped!(surveyId, surveyData!);
                  if (updated == true && mounted) {
                    _loadSurveyData();
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF009B56)),
            )
          : hasSurveyData
          ? Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // VDO (from API vdo object)
                          _buildFormField(
                            label: 'VDO Name',
                            controller: _vdoNameController,
                            placeholder: 'VDO Name',
                            readOnly: true,
                          ),

                          SizedBox(height: 20.h),

                          // Sarpanch details (API: sarpanch_name, sarpanch_contact)
                          _buildExpandableSection(
                            title: 'Sarpanch details',
                            isExpanded: _sarpanchExpanded,
                            onToggle: () => setState(
                              () => _sarpanchExpanded = !_sarpanchExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'Name',
                                controller: _sarpanchNameController,
                                placeholder: 'Name',
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Contact Number',
                                controller: _sarpanchContactController,
                                placeholder: 'Number',
                                keyboardType: TextInputType.phone,
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Work order details (API: work_order)
                          _buildExpandableSection(
                            title: 'Work order details',
                            isExpanded: _workOrderExpanded,
                            onToggle: () => setState(
                              () => _workOrderExpanded = !_workOrderExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'Work order no',
                                controller: _workOrderNoController,
                                placeholder: 'No.',
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Date',
                                controller: _workOrderDateController,
                                placeholder: 'Date',
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Amount',
                                controller: _workOrderAmountController,
                                placeholder: 'amount',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Fund Sanctioned (Expandable)
                          _buildExpandableSection(
                            title: 'Fund Sanctioned',
                            isExpanded: _fundExpanded,
                            onToggle: () =>
                                setState(() => _fundExpanded = !_fundExpanded),
                            children: [
                              _buildFormField(
                                label: 'Amount',
                                controller: _fundAmountController,
                                placeholder: 'amount',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Head',
                                controller: _fundHeadController,
                                placeholder: 'Head',
                                suffixIcon: Icons.keyboard_arrow_down,
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Door to door collection (API: door_to_door_collection)
                          _buildExpandableSection(
                            title: 'Door to door collection details',
                            isExpanded: _collectionExpanded,
                            onToggle: () => setState(
                              () => _collectionExpanded = !_collectionExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'No. of households',
                                controller: _householdsController,
                                placeholder: 'No',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'No. of shops',
                                controller: _shopsController,
                                placeholder: 'No',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Collection frequency',
                                controller: _collectionFrequencyController,
                                placeholder: 'Collection frequency',
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Road sweeping (API: road_sweeping)
                          _buildExpandableSection(
                            title: 'Road sweeping details',
                            isExpanded: _roadSweepingExpanded,
                            onToggle: () => setState(
                              () => _roadSweepingExpanded =
                                  !_roadSweepingExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'Width (m)',
                                controller: _roadWidthController,
                                placeholder: 'Width in metres',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Length (m)',
                                controller: _roadLengthController,
                                placeholder: 'Length in metres',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Cleaning frequency',
                                controller: _roadCleaningFrequencyController,
                                placeholder: 'Cleaning frequency',
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Drain cleaning details (Expandable)
                          _buildExpandableSection(
                            title: 'Drain cleaning details',
                            isExpanded: _drainCleaningExpanded,
                            onToggle: () => setState(
                              () => _drainCleaningExpanded =
                                  !_drainCleaningExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'Length (m)',
                                controller: _drainLengthController,
                                placeholder: 'Length in metres',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Cleaning frequency',
                                controller: _drainCleaningFrequencyController,
                                placeholder: 'Cleaning frequency',
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // CSC Details (Expandable)
                          _buildExpandableSection(
                            title: 'CSC (Community Sanitary Complex)',
                            isExpanded: _cscDetailsExpanded,
                            onToggle: () => setState(
                              () => _cscDetailsExpanded = !_cscDetailsExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'Numbers',
                                controller: _cscNumbersController,
                                placeholder: 'Numbers',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Cleaning frequency',
                                controller: _cscCleaningFrequencyController,
                                placeholder: 'Cleaning frequency',
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // SWM Assets (Expandable)
                          _buildExpandableSection(
                            title: 'SWM Assets (Solid Waste Management)',
                            isExpanded: _swmAssetsExpanded,
                            onToggle: () => setState(
                              () => _swmAssetsExpanded = !_swmAssetsExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'RRC',
                                controller: _rrcController,
                                placeholder: 'Rural Resource Centres',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'PWMU',
                                controller: _pwmuController,
                                placeholder: 'Plastic Waste Management Units',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Compost pit',
                                controller: _compostPitController,
                                placeholder: 'Compost pits',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Collection vehicle',
                                controller: _collectionVehicleController,
                                placeholder: 'Collection vehicles',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // SBMG Targets (Expandable)
                          _buildExpandableSection(
                            title: 'SBMG Year Targets',
                            isExpanded: _sbmgTargetsExpanded,
                            onToggle: () => setState(
                              () =>
                                  _sbmgTargetsExpanded = !_sbmgTargetsExpanded,
                            ),
                            children: [
                              _buildFormField(
                                label: 'IHHL',
                                controller: _sbmgIhhlController,
                                placeholder: 'Individual Household Latrines',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'CSC',
                                controller: _sbmgCscController,
                                placeholder: 'Community Sanitary Complexes',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'RRC',
                                controller: _sbmgRrcController,
                                placeholder: 'Rural Resource Centres',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'PWMU',
                                controller: _sbmgPwmuController,
                                placeholder: 'Plastic Waste Management Units',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Soak pit',
                                controller: _soakPitController,
                                placeholder: 'Soak pits',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Magic pit',
                                controller: _magicPitController,
                                placeholder: 'Magic pits',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'Leach pit',
                                controller: _leachPitController,
                                placeholder: 'Leach pits',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'WSP',
                                controller: _wspController,
                                placeholder: 'Waste Stabilization Ponds',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                              SizedBox(height: 16.h),
                              _buildFormField(
                                label: 'DEWATS',
                                controller: _dewatsController,
                                placeholder:
                                    'Decentralized Wastewater Treatment Systems',
                                keyboardType: TextInputType.number,
                                readOnly: true,
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Village data (API: village_data[])
                          _buildExpandableSection(
                            title: 'Village data',
                            isExpanded: _villageDataExpanded,
                            onToggle: () => setState(
                              () =>
                                  _villageDataExpanded = !_villageDataExpanded,
                            ),
                            children: _villageData.isEmpty
                                ? [
                                    Padding(
                                      padding: EdgeInsets.all(16.r),
                                      child: Text(
                                        'No village data',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ]
                                : _villageData
                                    .map((v) => _buildVillageDataCard(v))
                                    .toList(),
                          ),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _buildNoDataContent(
              context: context,
              message: l10n.gpMasterDataNotFilled,
            ),
    );
  }

  Widget _buildNoDataContent({
    required BuildContext context,
    required String message,
  }) {
    final primaryTextColor = CitizenColors.textPrimary(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/nodata.png',
              width: 140.w,
              height: 140.w,
            ),
            SizedBox(height: 24.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: primaryTextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    IconData? suffixIcon,
    bool? readOnly,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: readOnly ?? false || onTap != null,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey.shade600, size: 20.sp)
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVillageDataCard(Map<String, dynamic> v) {
    final sbmg = v['sbmg_assets'] as Map<String, dynamic>? ?? {};
    final gwm = v['gwm_assets'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            v['village_name']?.toString() ?? 'Village',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: CitizenColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 8.h),
          _buildReadOnlyRow('Village ID', v['village_id']?.toString() ?? ''),
          _buildReadOnlyRow('Population', v['population']?.toString() ?? ''),
          _buildReadOnlyRow(
            'No. of households',
            v['num_households']?.toString() ?? '',
          ),
          SizedBox(height: 8.h),
          Text(
            'SBMG Assets',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          _buildReadOnlyRow('IHHL', sbmg['ihhl']?.toString() ?? ''),
          _buildReadOnlyRow('CSC', sbmg['csc']?.toString() ?? ''),
          SizedBox(height: 6.h),
          Text(
            'GWM Assets',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          _buildReadOnlyRow('Soak pit', gwm['soak_pit']?.toString() ?? ''),
          _buildReadOnlyRow('Magic pit', gwm['magic_pit']?.toString() ?? ''),
          _buildReadOnlyRow('Leach pit', gwm['leach_pit']?.toString() ?? ''),
          _buildReadOnlyRow('WSP', gwm['wsp']?.toString() ?? ''),
          _buildReadOnlyRow('DEWATS', gwm['dewats']?.toString() ?? ''),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '–' : value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
