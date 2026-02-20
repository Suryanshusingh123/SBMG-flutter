import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../models/contractor_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../utils/api_error_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

class VillageMasterDataFormScreen extends StatefulWidget {
  /// When non-null, opens in edit mode: form is pre-filled from [initialData]
  /// and submit performs PUT to update the survey with id [surveyId].
  final int? surveyId;
  final Map<String, dynamic>? initialData;

  const VillageMasterDataFormScreen({
    super.key,
    this.surveyId,
    this.initialData,
  });

  @override
  State<VillageMasterDataFormScreen> createState() =>
      _VillageMasterDataFormScreenState();
}

class _VillageMasterDataFormScreenState
    extends State<VillageMasterDataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers (only fields required by /api/v1/annual-surveys/fill)
  final _vdoNameController = TextEditingController();
  final _sarpanchNameController = TextEditingController();
  final _sarpanchContactController = TextEditingController();
  final _numWardPanchsController = TextEditingController();
  Agency? _selectedAgency;
  List<Agency> _agencies = [];
  bool _isLoadingAgencies = false;
  final _workOrderNoController = TextEditingController();
  final _workOrderDateController = TextEditingController();
  final _workOrderAmountController = TextEditingController();
  final _fundAmountController = TextEditingController();
  String? _selectedFundHead; // Radio button selection for Fund Head (FFC, SFC, CSR, OWN_INCOME, OTHER)
  final _fundHeadOtherController = TextEditingController(); // Shown when Head is "Other"
  final _householdsController = TextEditingController();
  final _shopsController = TextEditingController();
  String? _selectedCollectionFrequency; // Dropdown for collection frequency

  // Road sweeping controllers
  final _roadWidthController = TextEditingController();
  final _roadLengthController = TextEditingController();
  String?
  _selectedRoadCleaningFrequency; // Dropdown for road cleaning frequency

  // Drain cleaning controllers
  final _drainLengthController = TextEditingController();
  String?
  _selectedDrainCleaningFrequency; // Dropdown for drain cleaning frequency

  // CSC controllers
  final _cscNumbersController = TextEditingController();
  String? _selectedCscCleaningFrequency; // Dropdown for CSC cleaning frequency

  // SWM Assets controllers
  final _rrcController = TextEditingController();
  final _pwmuController = TextEditingController();
  final _compositPitController = TextEditingController();
  final _collectionVehicleController = TextEditingController();

  // SBMG year Targets controllers
  final _ihhlController = TextEditingController();
  final _sbmgCscController = TextEditingController();
  final _sbmgRrcController = TextEditingController();
  final _sbmgPwmuController = TextEditingController();
  final _soakPitController = TextEditingController();
  final _magicPitController = TextEditingController();
  final _leachPitController = TextEditingController();
  final _wspController = TextEditingController();
  final _dewatsController = TextEditingController();

  // Expansion states
  bool _sarpanchExpanded = false;
  bool _workOrderExpanded = false;
  bool _fundExpanded = false;
  bool _collectionExpanded = false;
  bool _roadSweepingExpanded = false;
  bool _drainCleaningExpanded = false;
  bool _cscExpanded = false;
  bool _swmAssetsExpanded = false;
  bool _sbmgTargetsExpanded = false;
  bool _villagesExpanded = false;

  // Village data
  final List<Map<String, dynamic>> _villages = [];
  /// Next ID for newly added villages (incremented so API never receives 0).
  int _nextNewVillageId = 1;

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAgencies();
    if (widget.initialData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _populateFromData(widget.initialData!);
      });
    }
  }

  Future<void> _loadAgencies() async {
    setState(() => _isLoadingAgencies = true);
    try {
      final agencies = await ApiService().getAgencies(limit: 1000);
      agencies.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() {
        _agencies = agencies;
        _isLoadingAgencies = false;
        final agencyId = widget.initialData?['agency_id'];
        if (agencyId != null) {
          try {
            final id = agencyId is int ? agencyId : int.tryParse(agencyId.toString());
            if (id != null) {
              _selectedAgency = _agencies.firstWhere((a) => a.id == id);
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      setState(() => _isLoadingAgencies = false);
    }
  }

  void _showFullAgencyPicker() {
    BottomSheetPicker.show<Agency>(
      context: context,
      title: AppLocalizations.of(context)!.selectAgency,
      items: _agencies,
      itemBuilder: (agency) => agency.name,
      selectedItem: _selectedAgency,
      showSearch: true,
      onAdd: () async {
        await _showAddAgencyDialog();
        if (mounted && _selectedAgency != null) {
          Navigator.pop(context);
        }
      },
      onSelected: (agency) {
        setState(() => _selectedAgency = agency);
      },
    );
  }

  Future<void> _showAddAgencyDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.addNewAgency, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.agencyNameRequired,
                    hintText: AppLocalizations.of(context)!.enterAgencyName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.required : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.phoneNumberLabel,
                    hintText: AppLocalizations.of(context)!.enterMobileNumberPlaceholder,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 10) return AppLocalizations.of(context)!.enter10Digits;
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.agencyEmail,
                    hintText: AppLocalizations.of(context)!.enterEmailAddress,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.agencyAddress,
                    hintText: AppLocalizations.of(context)!.enterAddress,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': emailController.text.trim(),
                  'address': addressController.text.trim(),
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009B56), foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );

    if (result != null && result['name']!.isNotEmpty && mounted) {
      setState(() => _isLoadingAgencies = true);
      try {
        final newAgency = await ApiService().createAgency(
          name: result['name']!,
          phone: result['phone']!.isNotEmpty ? result['phone'] : null,
          email: result['email']!.isNotEmpty ? result['email'] : null,
          address: result['address']!.isNotEmpty ? result['address'] : null,
        );
        await _loadAgencies();
        if (mounted) {
          setState(() {
            try {
              _selectedAgency = _agencies.firstWhere((a) => a.id == newAgency.id);
            } catch (_) {
              _selectedAgency = newAgency;
              if (!_agencies.any((a) => a.id == newAgency.id)) {
                _agencies.add(newAgency);
                _agencies.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
              }
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingAgencies = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.failedToAddAgency(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _populateFromData(Map<String, dynamic> data) {
    setState(() {
      _sarpanchExpanded = true;
      _workOrderExpanded = true;
      _fundExpanded = true;
      _collectionExpanded = true;
      _roadSweepingExpanded = true;
      _drainCleaningExpanded = true;
      _cscExpanded = true;
      _swmAssetsExpanded = true;
      _sbmgTargetsExpanded = true;
      _villagesExpanded = true;
    });

    _vdoNameController.text = data['vdo_name']?.toString() ?? '';
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
    _numWardPanchsController.text =
        data['num_ward_panchs']?.toString() ?? '';
    // agency_id → _selectedAgency is set in _loadAgencies when initialData has agency_id

    if (data.containsKey('work_order') && data['work_order'] != null) {
      final wo = data['work_order'] as Map<String, dynamic>;
      _workOrderNoController.text = wo['work_order_no']?.toString() ?? '';
      if (wo['work_order_date'] != null) {
        try {
          _workOrderDateController.text = DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(wo['work_order_date'].toString()));
        } catch (_) {
          _workOrderDateController.text = wo['work_order_date'].toString();
        }
      }
      _workOrderAmountController.text =
          _numToDisplay(wo['work_order_amount']);
    }

    if (data.containsKey('fund_sanctioned') &&
        data['fund_sanctioned'] != null) {
      final fund = data['fund_sanctioned'] as Map<String, dynamic>;
      _fundAmountController.text = _numToDisplay(fund['amount']);
      final head = fund['head']?.toString();
      final uiHead = _fundHeadFromApi(head);
      if (uiHead != null) _selectedFundHead = uiHead;
      _fundHeadOtherController.text = fund['head_other']?.toString() ?? '';
    }

    if (data.containsKey('door_to_door_collection') &&
        data['door_to_door_collection'] != null) {
      final dtd = data['door_to_door_collection'] as Map<String, dynamic>;
      _householdsController.text = dtd['num_households']?.toString() ?? '';
      _shopsController.text = dtd['num_shops']?.toString() ?? '';
      _selectedCollectionFrequency =
          dtd['collection_frequency']?.toString();
    }

    if (data.containsKey('road_sweeping') && data['road_sweeping'] != null) {
      final rs = data['road_sweeping'] as Map<String, dynamic>;
      _roadWidthController.text = _numToDisplay(rs['width']);
      _roadLengthController.text = _numToDisplay(rs['length']);
      _selectedRoadCleaningFrequency =
          rs['cleaning_frequency']?.toString();
    }

    if (data.containsKey('drain_cleaning') &&
        data['drain_cleaning'] != null) {
      final dc = data['drain_cleaning'] as Map<String, dynamic>;
      _drainLengthController.text = _numToDisplay(dc['length']);
      _selectedDrainCleaningFrequency =
          dc['cleaning_frequency']?.toString();
    }

    if (data.containsKey('csc_details') && data['csc_details'] != null) {
      final csc = data['csc_details'] as Map<String, dynamic>;
      _cscNumbersController.text = csc['numbers']?.toString() ?? '';
      _selectedCscCleaningFrequency =
          csc['cleaning_frequency']?.toString();
    }

    if (data.containsKey('swm_assets') && data['swm_assets'] != null) {
      final swm = data['swm_assets'] as Map<String, dynamic>;
      _rrcController.text = swm['rrc']?.toString() ?? '';
      _pwmuController.text = swm['pwmu']?.toString() ?? '';
      _compositPitController.text = swm['compost_pit']?.toString() ?? '';
      _collectionVehicleController.text =
          swm['collection_vehicle']?.toString() ?? '';
    }

    if (data.containsKey('sbmg_targets') && data['sbmg_targets'] != null) {
      final sbmg = data['sbmg_targets'] as Map<String, dynamic>;
      _ihhlController.text = sbmg['ihhl']?.toString() ?? '';
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
      final list = data['village_data'] as List;
      int maxLoadedId = 0;
      for (var i = 0; i < list.length; i++) {
        final v = list[i] as Map<String, dynamic>? ?? {};
        final sbmg = v['sbmg_assets'] as Map<String, dynamic>? ?? {};
        final gwm = v['gwm_assets'] as Map<String, dynamic>? ?? {};
        final vid = v['village_id'] is int
            ? v['village_id'] as int
            : (int.tryParse(v['village_id']?.toString() ?? '0') ?? 0);
        if (vid > maxLoadedId) maxLoadedId = vid;
        _villages.add({
          'villageId': vid,
          'villageName': TextEditingController(
            text: v['village_name']?.toString() ?? '',
          ),
          'population': TextEditingController(
            text: v['population']?.toString() ?? '',
          ),
          'households': TextEditingController(
            text: v['num_households']?.toString() ?? '',
          ),
          'ihhl': TextEditingController(
            text: sbmg['ihhl']?.toString() ?? '',
          ),
          'csc': TextEditingController(
            text: sbmg['csc']?.toString() ?? '',
          ),
          'soakPit': TextEditingController(
            text: gwm['soak_pit']?.toString() ?? '',
          ),
          'magicPit': TextEditingController(
            text: gwm['magic_pit']?.toString() ?? '',
          ),
          'leachPit': TextEditingController(
            text: gwm['leach_pit']?.toString() ?? '',
          ),
          'wsp': TextEditingController(
            text: gwm['wsp']?.toString() ?? '',
          ),
          'dewats': TextEditingController(
            text: gwm['dewats']?.toString() ?? '',
          ),
        });
      }
      _nextNewVillageId = maxLoadedId + 1;
    }
  }

  /// For API numeric values (int/double). Shows "20" not "20.0" in fields.
  static String _numToDisplay(dynamic value) {
    if (value == null) return '';
    if (value is int) return value.toString();
    if (value is double) {
      return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
    }
    return value.toString();
  }

  /// Maps UI display value to API enum for fund_sanctioned.head.
  /// API expects: 'FFC', 'SFC', 'CSR', 'OWN_INCOME', 'OTHER'.
  static String _fundHeadToApi(String? uiValue) {
    if (uiValue == null || uiValue.isEmpty) return 'FFC';
    final v = uiValue.trim();
    switch (v) {
      case 'Own income':
        return 'OWN_INCOME';
      case 'Other':
        return 'OTHER';
      case 'FFC':
      case 'SFC':
      case 'CSR':
        return v;
      default:
        // Normalize display-like values (handles case, extra/multi-space)
        final n = v.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
        if (n == 'own income') return 'OWN_INCOME';
        if (n == 'other') return 'OTHER';
        // Never send invalid enum; default to FFC
        return 'FFC';
    }
  }

  /// Maps API enum to UI display value for fund_sanctioned.head.
  static String? _fundHeadFromApi(String? apiValue) {
    if (apiValue == null || apiValue.isEmpty) return null;
    switch (apiValue) {
      case 'OWN_INCOME': return 'Own income';
      case 'OTHER': return 'Other';
      case 'FFC': case 'SFC': case 'CSR': return apiValue;
      case 'Own income': return 'Own income';
      case 'Other': return 'Other';
      default: return null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _vdoNameController.dispose();
    _sarpanchNameController.dispose();
    _sarpanchContactController.dispose();
    _numWardPanchsController.dispose();
    _workOrderNoController.dispose();
    _workOrderDateController.dispose();
    _workOrderAmountController.dispose();
    _fundAmountController.dispose();
    _fundHeadOtherController.dispose();
    _householdsController.dispose();
    _shopsController.dispose();
    _roadWidthController.dispose();
    _roadLengthController.dispose();
    _drainLengthController.dispose();
    _cscNumbersController.dispose();
    _rrcController.dispose();
    _pwmuController.dispose();
    _compositPitController.dispose();
    _collectionVehicleController.dispose();
    _ihhlController.dispose();
    _sbmgCscController.dispose();
    _sbmgRrcController.dispose();
    _sbmgPwmuController.dispose();
    _soakPitController.dispose();
    _magicPitController.dispose();
    _leachPitController.dispose();
    _wspController.dispose();
    _dewatsController.dispose();
    // Dispose village controllers
    for (var village in _villages) {
      village['villageName']?.dispose();
      village['population']?.dispose();
      village['households']?.dispose();
      village['ihhl']?.dispose();
      village['csc']?.dispose();
      village['soakPit']?.dispose();
      village['magicPit']?.dispose();
      village['leachPit']?.dispose();
      village['wsp']?.dispose();
      village['dewats']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.surveyId != null
              ? AppLocalizations.of(context)!.editGpMasterData
              : AppLocalizations.of(context)!.villageMasterDataForm,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VDO Name (API: vdo_name) – editable in edit mode
                    _buildFormField(
                      label: AppLocalizations.of(context)!.vdoName,
                      controller: _vdoNameController,
                      placeholder: AppLocalizations.of(context)!.vdoName,
                    ),
                    SizedBox(height: 20.h),
                    // Sarpanch details (API: sarpanch_name, sarpanch_contact, num_ward_panchs)
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.sarpanchDetails,
                      isExpanded: _sarpanchExpanded,
                      onToggle: () => setState(
                        () => _sarpanchExpanded = !_sarpanchExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: AppLocalizations.of(context)!.name,
                          controller: _sarpanchNameController,
                          placeholder: AppLocalizations.of(context)!.name,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: AppLocalizations.of(context)!.contactNumber,
                          controller: _sarpanchContactController,
                          placeholder: AppLocalizations.of(context)!.numberPlaceholder10Digits,
                          keyboardType: TextInputType.phone,
                          isContactField: true,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: AppLocalizations.of(context)!.numberOfWardPanchs,
                          controller: _numWardPanchsController,
                          placeholder: AppLocalizations.of(context)!.noShort,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Agency dropdown + search (Add mode only; edit API does not accept agency_id)
                    if (widget.surveyId == null) ...[
                      _buildAgencySelector(),
                      SizedBox(height: 20.h),
                    ],

                    // Work order details (API: work_order)
                    _buildExpandableSection(
                      title: AppLocalizations.of(context)!.workOrderDetails,
                      isExpanded: _workOrderExpanded,
                      onToggle: () => setState(
                        () => _workOrderExpanded = !_workOrderExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: AppLocalizations.of(context)!.workOrderNo,
                          controller: _workOrderNoController,
                          placeholder: AppLocalizations.of(context)!.noDot,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: AppLocalizations.of(context)!.date,
                          controller: _workOrderDateController,
                          placeholder: AppLocalizations.of(context)!.date,
                          onTap: () =>
                              _selectDate(context, _workOrderDateController),
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: AppLocalizations.of(context)!.amount,
                          controller: _workOrderAmountController,
                          placeholder: AppLocalizations.of(context)!.amount,
                          keyboardType: TextInputType.number,
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
                        KeyedSubtree(
                          key: const ValueKey('fund_amount'),
                          child: _buildFormField(
                            label: 'Amount',
                            controller: _fundAmountController,
                            placeholder: 'amount',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildFundHeadRadioGroup(),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Door to door collection details (Expandable)
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
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'No. of shops',
                          controller: _shopsController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFrequencyDropdown(
                          label: 'Collection frequency',
                          selectedValue: _selectedCollectionFrequency,
                          onChanged: (String? value) {
                            setState(
                              () => _selectedCollectionFrequency = value,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Road sweeping details (Expandable)
                    _buildExpandableSection(
                      title: 'Road sweeping details',
                      isExpanded: _roadSweepingExpanded,
                      onToggle: () => setState(
                        () => _roadSweepingExpanded = !_roadSweepingExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Width (m)',
                          controller: _roadWidthController,
                          placeholder: 'Width in metres',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Length (m)',
                          controller: _roadLengthController,
                          placeholder: 'Length in metres',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFrequencyDropdown(
                          label: 'Cleaning Frequency',
                          selectedValue: _selectedRoadCleaningFrequency,
                          onChanged: (String? value) {
                            setState(
                              () => _selectedRoadCleaningFrequency = value,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Drain cleaning details (Expandable)
                    _buildExpandableSection(
                      title: 'Drain cleaning details',
                      isExpanded: _drainCleaningExpanded,
                      onToggle: () => setState(
                        () => _drainCleaningExpanded = !_drainCleaningExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Length',
                          controller: _drainLengthController,
                          placeholder: 'Length',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFrequencyDropdown(
                          label: 'Cleaning frequency',
                          selectedValue: _selectedDrainCleaningFrequency,
                          onChanged: (String? value) {
                            setState(
                              () => _selectedDrainCleaningFrequency = value,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // CSC (Expandable)
                    _buildExpandableSection(
                      title: 'CSC',
                      isExpanded: _cscExpanded,
                      onToggle: () =>
                          setState(() => _cscExpanded = !_cscExpanded),
                      children: [
                        _buildFormField(
                          label: 'Numbers',
                          controller: _cscNumbersController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFrequencyDropdown(
                          label: 'Cleaning frequency',
                          selectedValue: _selectedCscCleaningFrequency,
                          onChanged: (String? value) {
                            setState(
                              () => _selectedCscCleaningFrequency = value,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // SWM Assets (Expandable)
                    _buildExpandableSection(
                      title: 'SWM Assets (Solid Waste Management Assets)',
                      isExpanded: _swmAssetsExpanded,
                      onToggle: () => setState(
                        () => _swmAssetsExpanded = !_swmAssetsExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'RRC (Resource Recovery Centre)',
                          controller: _rrcController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'PWMU (Plastic Waste Management Unit)',
                          controller: _pwmuController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Composit pit',
                          controller: _compositPitController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Collection vehicle',
                          controller: _collectionVehicleController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // SBMG year Targets (Expandable)
                    _buildExpandableSection(
                      title: 'SBMG Year Targets (Swachh Bharat Mission - Gramin Year Targets)',
                      isExpanded: _sbmgTargetsExpanded,
                      onToggle: () => setState(
                        () => _sbmgTargetsExpanded = !_sbmgTargetsExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'IHHL (Individual Household Latrine)',
                          controller: _ihhlController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'CSC (Community Sanitation Complex)',
                          controller: _sbmgCscController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'RRC (Resource Recovery Centre)',
                          controller: _sbmgRrcController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'PWMU (Plastic Waste Management Unit)',
                          controller: _sbmgPwmuController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Soak pit',
                          controller: _soakPitController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Magic pit',
                          controller: _magicPitController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Leach pit',
                          controller: _leachPitController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'WSP (Waste Stabilisation Pond)',
                          controller: _wspController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'DEWATS (Decentralised Wastewater Treatment System)',
                          controller: _dewatsController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Add Village section (Expandable)
                    _buildVillageSection(),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),

            // Submit Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.submit,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencySelector() {
    if (_isLoadingAgencies) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agency',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF009B56)),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final List<Agency> quickAgencies = _agencies.take(6).toList();
    final List<DropdownMenuItem<String>> menuItems = [];

    for (final agency in quickAgencies) {
      menuItems.add(DropdownMenuItem(
        value: agency.id.toString(),
        child: Text(
          agency.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp),
        ),
      ));
    }

    if (_selectedAgency != null && !quickAgencies.any((a) => a.id == _selectedAgency!.id)) {
      menuItems.add(DropdownMenuItem(
        value: _selectedAgency!.id.toString(),
        child: Text(
          _selectedAgency!.name,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp),
        ),
      ));
    }

    menuItems.add(DropdownMenuItem(
      value: 'OTHER',
      child: Text(
        'View all / Search…',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF009B56),
          fontWeight: FontWeight.w600,
        ),
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agency',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
            GestureDetector(
              onTap: _showAddAgencyDialog,
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, size: 16.sp, color: const Color(0xFF009B56)),
                  SizedBox(width: 4.w),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF009B56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedAgency?.id.toString(),
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.selectAgency,
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
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          items: menuItems,
          onChanged: (value) {
            if (value == 'OTHER') {
              _showFullAgencyPicker();
            } else if (value != null) {
              setState(() {
                _selectedAgency = _agencies.firstWhere((a) => a.id.toString() == value);
              });
            }
          },
          validator: (value) {
            if (_selectedAgency == null) {
              return 'Please select an agency';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    IconData? suffixIcon,
    bool isContactField = false,
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
          keyboardType:
              keyboardType ??
              (isContactField ? TextInputType.phone : TextInputType.text),
          onTap: onTap,
          readOnly: onTap != null,
          maxLength: isContactField ? 10 : null,
          inputFormatters: isContactField
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
              : null,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
                ? Icon(suffixIcon, color: Colors.grey.shade600, size: 20)
                : null,
            counterText: isContactField
                ? ''
                : null, // Hide counter for contact fields
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (isContactField) {
              if (value.length != 10) {
                return 'Contact number must be exactly 10 digits';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown({
    required String label,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    // Valid enum values as per API
    const List<String> frequencyOptions = [
      'DAILY',
      'ALTERNATE_DAYS',
      'TWICE_A_WEEK',
      'WEEKLY',
      'FORTNIGHTLY',
      'NONE',
    ];

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
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedValue,
            decoration: InputDecoration(
              hintText: 'Select frequency',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF009B56)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select ${label.toLowerCase()}';
              }
              return null;
            },
            items: frequencyOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value
                      .replaceAll('_', ' ')
                      .toLowerCase()
                      .split(' ')
                      .map((word) {
                        return word.isEmpty
                            ? ''
                            : word[0].toUpperCase() + word.substring(1);
                      })
                      .join(' '),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 20,
            ),
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFundHeadRadioGroup() {
    // Plain Column (no FormField). FormField's didChange triggered setState
    // and rebuilds that caused Amount to accept only one character after
    // selecting a radio. Validation is handled by checkSelection in
    // _validateAllFieldsFilled.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Head',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: [
            _buildFundHeadRadioOption('FFC'),
            SizedBox(height: 12.h),
            _buildFundHeadRadioOption('SFC'),
            SizedBox(height: 12.h),
            _buildFundHeadRadioOption('CSR'),
            SizedBox(height: 12.h),
            _buildFundHeadRadioOption('Own income'),
            SizedBox(height: 12.h),
            _buildFundHeadRadioOption('Other'),
            if (_selectedFundHead == 'Other') ...[
              SizedBox(height: 12.h),
              _buildFormField(
                label: 'Head name',
                controller: _fundHeadOtherController,
                placeholder: 'Enter head name',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFundHeadRadioOption(String value) {
    return InkWell(
      onTap: () => setState(() => _selectedFundHead = value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedFundHead,
            onChanged: (String? v) =>
                setState(() => _selectedFundHead = v ?? value),
            activeColor: const Color(0xFF009B56),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
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

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Widget _buildVillageSection() {
    return Column(
      children: [
        // Add Village Button - Always visible
        Container(
          padding: EdgeInsets.all(15.r),
          child: SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: _addVillage,
              icon: const Icon(Icons.add, color: Colors.white, size: 24),
              label: const Text(
                'Add Village',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 1.h),
              ),
            ),
          ),
        ),

        // Village List Section (Expandable if there are villages)
        if (_villages.isNotEmpty) ...[
          Divider(height: 1, color: Colors.grey.shade300),
          // Header
          InkWell(
            onTap: () => setState(() => _villagesExpanded = !_villagesExpanded),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Villages (${_villages.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(
                    _villagesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Village List Content
          if (_villagesExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Village List
                  ...List.generate(_villages.length, (index) {
                    return _buildVillageEntry(index);
                  }),
                ],
              ),
            ),
        ],
      ],
    );
  }

  void _addVillage() {
    setState(() {
      _villages.add({
        'villageId': _nextNewVillageId++,
        'villageName': TextEditingController(),
        'population': TextEditingController(),
        'households': TextEditingController(),
        'ihhl': TextEditingController(),
        'csc': TextEditingController(),
        'soakPit': TextEditingController(),
        'magicPit': TextEditingController(),
        'leachPit': TextEditingController(),
        'wsp': TextEditingController(),
        'dewats': TextEditingController(),
      });
    });
  }

  void _removeVillage(int index) {
    setState(() {
      // Dispose controllers before removing
      _villages[index]['villageName']?.dispose();
      _villages[index]['population']?.dispose();
      _villages[index]['households']?.dispose();
      _villages[index]['ihhl']?.dispose();
      _villages[index]['csc']?.dispose();
      _villages[index]['soakPit']?.dispose();
      _villages[index]['magicPit']?.dispose();
      _villages[index]['leachPit']?.dispose();
      _villages[index]['wsp']?.dispose();
      _villages[index]['dewats']?.dispose();
      _villages.removeAt(index);
    });
  }

  Widget _buildVillageEntry(int index) {
    final village = _villages[index];
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Village Header with Delete Button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Village ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeVillage(index),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Village Name
          _buildFormField(
            label: 'Village name',
            controller: village['villageName'] as TextEditingController,
            placeholder: 'Village name',
          ),
          SizedBox(height: 16.h),

          // Population
          _buildFormField(
            label: 'Population',
            controller: village['population'] as TextEditingController,
            placeholder: 'Population',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),

          // No. of households
          _buildFormField(
            label: 'No. of households',
            controller: village['households'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20.h),

          // SBMG Assets Section
          Text(
            'SBMG Assets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 12.h),
          _buildFormField(
            label: 'IHHL',
            controller: village['ihhl'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildFormField(
            label: 'CSC',
            controller: village['csc'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20.h),

          // GWM Assets Section
          Text(
            'GWM Assets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 12.h),
          _buildFormField(
            label: 'Soak pit',
            controller: village['soakPit'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildFormField(
            label: 'Magic pit',
            controller: village['magicPit'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildFormField(
            label: 'Leach pit',
            controller: village['leachPit'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildFormField(
            label: 'WSP',
            controller: village['wsp'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _buildFormField(
            label: 'DEWATS',
            controller: village['dewats'] as TextEditingController,
            placeholder: 'No',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  bool _validateAllFieldsFilled() {
    final missingFields = <String>[];

    bool expandSarpanch = false;
    bool expandWorkOrder = false;
    bool expandFund = false;
    bool expandCollection = false;
    bool expandRoad = false;
    bool expandDrain = false;
    bool expandCsc = false;
    bool expandSwm = false;
    bool expandTargets = false;
    bool expandVillages = false;

    void checkController(
      TextEditingController? controller,
      String label, {
      VoidCallback? markSection,
    }) {
      if (controller == null || controller.text.trim().isEmpty) {
        missingFields.add(label);
        markSection?.call();
      }
    }

    void checkSelection(
      String? value,
      String label, {
      VoidCallback? markSection,
    }) {
      if (value == null || value.trim().isEmpty) {
        missingFields.add(label);
        markSection?.call();
      }
    }

    if (widget.surveyId == null && _selectedAgency == null) {
      missingFields.add('Agency');
    }

    checkController(
      _sarpanchNameController,
      'Sarpanch name',
      markSection: () => expandSarpanch = true,
    );
    if (_sarpanchContactController.text.trim().isEmpty) {
      missingFields.add('Sarpanch contact number');
      expandSarpanch = true;
    } else if (_sarpanchContactController.text.trim().length != 10) {
      missingFields.add('Sarpanch contact number must be exactly 10 digits');
      expandSarpanch = true;
    }

    checkController(
      _workOrderNoController,
      'Work order number',
      markSection: () => expandWorkOrder = true,
    );
    checkController(
      _workOrderDateController,
      'Work order date',
      markSection: () => expandWorkOrder = true,
    );
    checkController(
      _workOrderAmountController,
      'Work order amount',
      markSection: () => expandWorkOrder = true,
    );

    checkController(
      _fundAmountController,
      'Fund amount',
      markSection: () => expandFund = true,
    );
    checkSelection(
      _selectedFundHead,
      'Fund head',
      markSection: () => expandFund = true,
    );

    checkController(
      _householdsController,
      'Number of households',
      markSection: () => expandCollection = true,
    );
    checkController(
      _shopsController,
      'Number of shops',
      markSection: () => expandCollection = true,
    );
    checkSelection(
      _selectedCollectionFrequency,
      'Collection frequency',
      markSection: () => expandCollection = true,
    );

    checkController(
      _roadWidthController,
      'Road width',
      markSection: () => expandRoad = true,
    );
    checkController(
      _roadLengthController,
      'Road length',
      markSection: () => expandRoad = true,
    );
    checkSelection(
      _selectedRoadCleaningFrequency,
      'Road cleaning frequency',
      markSection: () => expandRoad = true,
    );

    checkController(
      _drainLengthController,
      'Drain length',
      markSection: () => expandDrain = true,
    );
    checkSelection(
      _selectedDrainCleaningFrequency,
      'Drain cleaning frequency',
      markSection: () => expandDrain = true,
    );

    checkController(
      _cscNumbersController,
      'CSC numbers',
      markSection: () => expandCsc = true,
    );
    checkSelection(
      _selectedCscCleaningFrequency,
      'CSC cleaning frequency',
      markSection: () => expandCsc = true,
    );

    checkController(
      _rrcController,
      'SWM RRC count',
      markSection: () => expandSwm = true,
    );
    checkController(
      _pwmuController,
      'SWM PWMU count',
      markSection: () => expandSwm = true,
    );
    checkController(
      _compositPitController,
      'SWM composite pit count',
      markSection: () => expandSwm = true,
    );
    checkController(
      _collectionVehicleController,
      'Collection vehicle count',
      markSection: () => expandSwm = true,
    );

    checkController(
      _ihhlController,
      'SBMG IHHL target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _sbmgCscController,
      'SBMG CSC target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _sbmgRrcController,
      'SBMG RRC target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _sbmgPwmuController,
      'SBMG PWMU target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _soakPitController,
      'SBMG soak pit target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _magicPitController,
      'SBMG magic pit target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _leachPitController,
      'SBMG leach pit target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _wspController,
      'SBMG WSP target',
      markSection: () => expandTargets = true,
    );
    checkController(
      _dewatsController,
      'SBMG DEWATS target',
      markSection: () => expandTargets = true,
    );

    if (_villages.isEmpty) {
      missingFields.add('Village details');
      expandVillages = true;
    } else {
      for (int i = 0; i < _villages.length; i++) {
        final village = _villages[i];
        String fieldLabel(String name) => 'Village ${i + 1} $name';
        TextEditingController? controllerFor(String key) =>
            village[key] as TextEditingController?;

        checkController(
          controllerFor('villageName'),
          fieldLabel('name'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('population'),
          fieldLabel('population'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('households'),
          fieldLabel('households'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('ihhl'),
          fieldLabel('IHHL'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('csc'),
          fieldLabel('CSC'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('soakPit'),
          fieldLabel('soak pit'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('magicPit'),
          fieldLabel('magic pit'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('leachPit'),
          fieldLabel('leach pit'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('wsp'),
          fieldLabel('WSP'),
          markSection: () => expandVillages = true,
        );
        checkController(
          controllerFor('dewats'),
          fieldLabel('DEWATS'),
          markSection: () => expandVillages = true,
        );
      }
    }

    if (missingFields.isNotEmpty) {
      // Save scroll position before setState
      final scrollPosition = _scrollController.hasClients 
          ? _scrollController.offset 
          : 0.0;
      
      setState(() {
        if (expandSarpanch) _sarpanchExpanded = true;
        if (expandWorkOrder) _workOrderExpanded = true;
        if (expandFund) _fundExpanded = true;
        if (expandCollection) _collectionExpanded = true;
        if (expandRoad) _roadSweepingExpanded = true;
        if (expandDrain) _drainCleaningExpanded = true;
        if (expandCsc) _cscExpanded = true;
        if (expandSwm) _swmAssetsExpanded = true;
        if (expandTargets) _sbmgTargetsExpanded = true;
        if (expandVillages) _villagesExpanded = true;
      });

      // Restore scroll position after setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(scrollPosition);
          _formKey.currentState!.validate();
        }
      });

      if (mounted) {
        final preview = missingFields.take(3).join(', ');
        final suffix = missingFields.length > 3 ? '…' : '';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                missingFields.length == 1
                    ? 'Please fill ${missingFields.first} before submitting.'
                    : 'Please fill all required fields (e.g. $preview$suffix).',
              ),
              backgroundColor: Colors.red,
            ),
          );
      }
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔵 FORM SUBMISSION STARTED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('⏰ Timestamp: ${DateTime.now()}');

    if (!_validateAllFieldsFilled()) {
      print('❌ Form validation failed - missing required fields');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    print('✅ Form validation passed');

    // Save scroll position before setState
    final scrollPosition = _scrollController.hasClients 
        ? _scrollController.offset 
        : 0.0;

    setState(() {
      _isSubmitting = true;
    });

    // Restore scroll position after setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(scrollPosition);
      }
    });

    bool didPop = false;
    double? scrollToRestore;

    try {
      final apiService = ApiService();

      // Edit mode: PUT /api/v1/annual-surveys/{surveyId}
      if (widget.surveyId != null) {
        print('📋 Edit mode: Updating survey ID ${widget.surveyId}');
        // Use logged-in user's village_id when village_data has village_id 0
        final authService = AuthService();
        final fallbackVillageId = await authService.getVillageId();
        if (fallbackVillageId != null) {
          print('📍 Fallback village_id for village_data: $fallbackVillageId (from login)');
        }
        final payload = _prepareUpdatePayload(fallbackVillageId: fallbackVillageId);
        await apiService.updateAnnualSurvey(
          surveyId: widget.surveyId!,
          payload: payload,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GP Master Data updated successfully!'),
              backgroundColor: Color(0xFF009B56),
            ),
          );
          didPop = true;
          Navigator.pop(context, true);
        }
        return;
      }

      // Add mode: POST /api/v1/annual-surveys/fill
      // Get user information – fetch /me first so village_id (GP) is up to date
      print('📋 Step 1: Retrieving user information...');
      final authService = AuthService();
      print('👤 Fetching current user data ( /me )...');
      final userInfo = await authService.getCurrentUser();
      if (!userInfo['success']) {
        print('❌ Failed to get user information');
        throw Exception('Failed to get user information. Please try again.');
      }

      final userData = userInfo['user'] as Map<String, dynamic>;
      final vdoId = userData['id'];
      final gpId = await authService.getVillageId();
      print('📍 GP ID: $gpId (from /me → village_id)');
      print('👤 VDO ID: $vdoId');

      if (gpId == null || vdoId == null) {
        print('❌ Missing required information - GP ID: $gpId, VDO ID: $vdoId');
        throw Exception(
          'Your GP/Village is not assigned to your account. Please ensure you are logged in as VDO with an assigned GP. Contact admin if the issue persists.',
        );
      }

      // Step 1: Get active FY ID
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Step 2: Getting active FY ID...');
      final fyId = await apiService.getActiveFyId();
      print('✅ Active FY ID retrieved: $fyId');

      // Step 2: Prepare survey data
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Step 3: Preparing survey data...');
      final surveyData = _prepareSurveyData(
        fyId: fyId,
        gpId: gpId,
        vdoId: vdoId,
      );
      print('✅ Survey data prepared');
      print('📊 Data summary:');
      print('   - FY ID: $fyId');
      print('   - GP ID: $gpId');
      print('   - VDO ID: $vdoId');
      print('   - Survey Date: ${surveyData['survey_date']}');
      print(
        '   - Villages: ${(surveyData['village_data'] as List?)?.length ?? 0}',
      );

      // Step 3: Submit the survey
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Step 4: Submitting survey to API...');
      final response = await apiService.submitAnnualSurvey(
        fyId: fyId,
        gpId: gpId,
        vdoId: vdoId,
        surveyData: surveyData,
      );
      print('✅ Survey submitted successfully');
      print('📦 Response ID: ${response['id']}');

      // Success
      if (mounted) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('✅ FORM SUBMISSION COMPLETED SUCCESSFULLY');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: Color(0xFF009B56),
          ),
        );

        // Get current date for completion
        final now = DateTime.now();
        final completionDate = '${now.day}/${now.month}/${now.year}';
        print('📅 Completion date: $completionDate');

        // Navigate back with completion date
        didPop = true;
        Navigator.pop(context, completionDate);
      }
    } catch (e) {
      // Save scroll position BEFORE showing dialog/snackbar; they can trigger
      // rebuilds (e.g. overlay routes) that reset the scroll to top.
      scrollToRestore = _scrollController.hasClients
          ? _scrollController.offset
          : 0.0;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ FORM SUBMISSION FAILED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💥 Error: $e');
      print('📚 Error type: ${e.runtimeType}');
      print('⏰ Timestamp: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (mounted) {
        // Check if it's a SurveyAlreadyFilledException
        if (e is SurveyAlreadyFilledException ||
            e.toString().contains('already been submitted') ||
            e.toString().contains('already filled')) {
          // Show dialog for survey already filled
          _showSurveyAlreadyFilledDialog(context);
        } else {
          // Show snackbar for other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userFriendlyApiMessage(e)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      // Only reset state and restore scroll when staying on the form (did not pop).
      // On success we pop, so skip to avoid extra rebuild and scroll flash during pop.
      if (mounted && !didPop) {
        final position = scrollToRestore ??
            (_scrollController.hasClients ? _scrollController.offset : 0.0);

        setState(() {
          _isSubmitting = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(position);
          }
        });

        print('🔄 Form submission state reset');
      }
    }
  }

  Map<String, dynamic> _prepareSurveyData({
    required int fyId,
    required int gpId,
    required int vdoId,
  }) {
    // Format date as YYYY-MM-DD
    final surveyDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Helper: parse int from text (handles "20.0" from API)
    int parseInteger(String? value) => _parseIntFromText(value);

    // Prepare work order data
    Map<String, dynamic>? workOrder;
    if (_workOrderNoController.text.isNotEmpty ||
        _workOrderDateController.text.isNotEmpty ||
        _workOrderAmountController.text.isNotEmpty) {
      workOrder = {
        'work_order_no': _workOrderNoController.text,
        'work_order_date': _formatDateForApi(_workOrderDateController.text),
        'work_order_amount': parseInteger(_workOrderAmountController.text),
      };
    }

    // Prepare fund sanctioned data
    Map<String, dynamic>? fundSanctioned;
    if (_fundAmountController.text.isNotEmpty || _selectedFundHead != null) {
      fundSanctioned = {
        'amount': parseInteger(_fundAmountController.text),
        'head': _fundHeadToApi(_selectedFundHead),
        if (_selectedFundHead == 'Other' &&
            _fundHeadOtherController.text.trim().isNotEmpty)
          'head_other': _fundHeadOtherController.text.trim(),
      };
    }

    // Prepare door to door collection data
    Map<String, dynamic>? doorToDoorCollection;
    if (_householdsController.text.isNotEmpty ||
        _shopsController.text.isNotEmpty ||
        _selectedCollectionFrequency != null) {
      doorToDoorCollection = {
        'num_households': parseInteger(_householdsController.text),
        'num_shops': parseInteger(_shopsController.text),
        'collection_frequency': _selectedCollectionFrequency ?? 'DAILY',
      };
    }

    // Prepare road sweeping data
    Map<String, dynamic>? roadSweeping;
    if (_roadWidthController.text.isNotEmpty ||
        _roadLengthController.text.isNotEmpty ||
        _selectedRoadCleaningFrequency != null) {
      roadSweeping = {
        'width': parseInteger(_roadWidthController.text),
        'length': parseInteger(_roadLengthController.text),
        'cleaning_frequency': _selectedRoadCleaningFrequency ?? 'DAILY',
      };
    }

    // Prepare drain cleaning data
    Map<String, dynamic>? drainCleaning;
    if (_drainLengthController.text.isNotEmpty ||
        _selectedDrainCleaningFrequency != null) {
      drainCleaning = {
        'length': parseInteger(_drainLengthController.text),
        'cleaning_frequency': _selectedDrainCleaningFrequency ?? 'DAILY',
      };
    }

    // Prepare CSC details
    Map<String, dynamic>? cscDetails;
    if (_cscNumbersController.text.isNotEmpty ||
        _selectedCscCleaningFrequency != null) {
      cscDetails = {
        'numbers': parseInteger(_cscNumbersController.text),
        'cleaning_frequency': _selectedCscCleaningFrequency ?? 'DAILY',
      };
    }

    // Prepare SWM assets
    Map<String, dynamic>? swmAssets;
    if (_rrcController.text.isNotEmpty ||
        _pwmuController.text.isNotEmpty ||
        _compositPitController.text.isNotEmpty ||
        _collectionVehicleController.text.isNotEmpty) {
      swmAssets = {
        'rrc': parseInteger(_rrcController.text),
        'pwmu': parseInteger(_pwmuController.text),
        'compost_pit': parseInteger(_compositPitController.text),
        'collection_vehicle': parseInteger(_collectionVehicleController.text),
      };
    }

    // Prepare SBMG targets
    Map<String, dynamic>? sbmgTargets;
    if (_ihhlController.text.isNotEmpty ||
        _sbmgCscController.text.isNotEmpty ||
        _sbmgRrcController.text.isNotEmpty ||
        _sbmgPwmuController.text.isNotEmpty ||
        _soakPitController.text.isNotEmpty ||
        _magicPitController.text.isNotEmpty ||
        _leachPitController.text.isNotEmpty ||
        _wspController.text.isNotEmpty ||
        _dewatsController.text.isNotEmpty) {
      sbmgTargets = {
        'ihhl': parseInteger(_ihhlController.text),
        'csc': parseInteger(_sbmgCscController.text),
        'rrc': parseInteger(_sbmgRrcController.text),
        'pwmu': parseInteger(_sbmgPwmuController.text),
        'soak_pit': parseInteger(_soakPitController.text),
        'magic_pit': parseInteger(_magicPitController.text),
        'leach_pit': parseInteger(_leachPitController.text),
        'wsp': parseInteger(_wspController.text),
        'dewats': parseInteger(_dewatsController.text),
      };
    }

    // Prepare village data
    List<Map<String, dynamic>> villageData = [];
    for (var village in _villages) {
      final villageNameController =
          village['villageName'] as TextEditingController;
      final populationController =
          village['population'] as TextEditingController;
      final householdsController =
          village['households'] as TextEditingController;
      final ihhlController = village['ihhl'] as TextEditingController;
      final cscController = village['csc'] as TextEditingController;
      final soakPitController = village['soakPit'] as TextEditingController;
      final magicPitController = village['magicPit'] as TextEditingController;
      final leachPitController = village['leachPit'] as TextEditingController;
      final wspController = village['wsp'] as TextEditingController;
      final dewatsController = village['dewats'] as TextEditingController;
      final villageId = village['villageId'] is int
          ? village['villageId'] as int
          : (int.tryParse(village['villageId']?.toString() ?? '0') ?? 0);

      if (villageNameController.text.isNotEmpty) {
        villageData.add({
          'village_id': villageId,
          'village_name': villageNameController.text,
          'population': parseInteger(populationController.text),
          'num_households': parseInteger(householdsController.text),
          'sbmg_assets': {
            'ihhl': parseInteger(ihhlController.text),
            'csc': parseInteger(cscController.text),
          },
          'gwm_assets': {
            'soak_pit': parseInteger(soakPitController.text),
            'magic_pit': parseInteger(magicPitController.text),
            'leach_pit': parseInteger(leachPitController.text),
            'wsp': parseInteger(wspController.text),
            'dewats': parseInteger(dewatsController.text),
          },
        });
      }
    }

    return {
      'fy_id': fyId,
      'gp_id': gpId,
      'survey_date': surveyDate,
      'vdo_id': vdoId,
      'vdo_name': _vdoNameController.text.trim().isEmpty
          ? 'string'
          : _vdoNameController.text.trim(),
      'sarpanch_name': _sarpanchNameController.text.isNotEmpty
          ? _sarpanchNameController.text
          : 'string',
      'sarpanch_contact': _sarpanchContactController.text.isNotEmpty
          ? _sarpanchContactController.text
          : 'string',
      'num_ward_panchs': parseInteger(_numWardPanchsController.text),
      'agency_id': _selectedAgency?.id ?? 0,
      if (workOrder != null) 'work_order': workOrder,
      if (fundSanctioned != null) 'fund_sanctioned': fundSanctioned,
      if (doorToDoorCollection != null)
        'door_to_door_collection': doorToDoorCollection,
      if (roadSweeping != null) 'road_sweeping': roadSweeping,
      if (drainCleaning != null) 'drain_cleaning': drainCleaning,
      if (cscDetails != null) 'csc_details': cscDetails,
      if (swmAssets != null) 'swm_assets': swmAssets,
      if (sbmgTargets != null) 'sbmg_targets': sbmgTargets,
      if (villageData.isNotEmpty) 'village_data': villageData,
    };
  }

  /// Builds the PUT body for /api/v1/annual-surveys/{id}. Same shape as
  /// _prepareSurveyData but without fy_id, gp_id, survey_date, vdo_id, agency_id.
  /// [fallbackVillageId] When a village_data entry has village_id 0, use this
  /// (from logged-in user's village_id) so the API accepts the payload.
  /// Parses an integer from controller text. Handles API values like "20.0"
  /// (int.tryParse("20.0") is null in Dart, so we also try double then round).
  static int _parseIntFromText(String? value) {
    if (value == null || value.isEmpty) return 0;
    final v = value.trim();
    return int.tryParse(v) ?? (double.tryParse(v)?.round() ?? 0);
  }

  Map<String, dynamic> _prepareUpdatePayload({int? fallbackVillageId}) {
    int parseInteger(String? value) => _parseIntFromText(value);

    Map<String, dynamic>? workOrder;
    if (_workOrderNoController.text.isNotEmpty ||
        _workOrderDateController.text.isNotEmpty ||
        _workOrderAmountController.text.isNotEmpty) {
      workOrder = {
        'work_order_no': _workOrderNoController.text,
        'work_order_date': _formatDateForApi(_workOrderDateController.text),
        'work_order_amount': parseInteger(_workOrderAmountController.text),
      };
    }

    Map<String, dynamic>? fundSanctioned;
    if (_fundAmountController.text.isNotEmpty || _selectedFundHead != null) {
      fundSanctioned = {
        'amount': parseInteger(_fundAmountController.text),
        'head': _fundHeadToApi(_selectedFundHead),
        if (_selectedFundHead == 'Other' &&
            _fundHeadOtherController.text.trim().isNotEmpty)
          'head_other': _fundHeadOtherController.text.trim(),
      };
    }

    Map<String, dynamic>? doorToDoorCollection;
    if (_householdsController.text.isNotEmpty ||
        _shopsController.text.isNotEmpty ||
        _selectedCollectionFrequency != null) {
      doorToDoorCollection = {
        'num_households': parseInteger(_householdsController.text),
        'num_shops': parseInteger(_shopsController.text),
        'collection_frequency': _selectedCollectionFrequency ?? 'DAILY',
      };
    }

    Map<String, dynamic>? roadSweeping;
    if (_roadWidthController.text.isNotEmpty ||
        _roadLengthController.text.isNotEmpty ||
        _selectedRoadCleaningFrequency != null) {
      roadSweeping = {
        'width': parseInteger(_roadWidthController.text),
        'length': parseInteger(_roadLengthController.text),
        'cleaning_frequency': _selectedRoadCleaningFrequency ?? 'DAILY',
      };
    }

    Map<String, dynamic>? drainCleaning;
    if (_drainLengthController.text.isNotEmpty ||
        _selectedDrainCleaningFrequency != null) {
      drainCleaning = {
        'length': parseInteger(_drainLengthController.text),
        'cleaning_frequency': _selectedDrainCleaningFrequency ?? 'DAILY',
      };
    }

    Map<String, dynamic>? cscDetails;
    if (_cscNumbersController.text.isNotEmpty ||
        _selectedCscCleaningFrequency != null) {
      cscDetails = {
        'numbers': parseInteger(_cscNumbersController.text),
        'cleaning_frequency': _selectedCscCleaningFrequency ?? 'DAILY',
      };
    }

    Map<String, dynamic>? swmAssets;
    if (_rrcController.text.isNotEmpty ||
        _pwmuController.text.isNotEmpty ||
        _compositPitController.text.isNotEmpty ||
        _collectionVehicleController.text.isNotEmpty) {
      swmAssets = {
        'rrc': parseInteger(_rrcController.text),
        'pwmu': parseInteger(_pwmuController.text),
        'compost_pit': parseInteger(_compositPitController.text),
        'collection_vehicle': parseInteger(_collectionVehicleController.text),
      };
    }

    Map<String, dynamic>? sbmgTargets;
    if (_ihhlController.text.isNotEmpty ||
        _sbmgCscController.text.isNotEmpty ||
        _sbmgRrcController.text.isNotEmpty ||
        _sbmgPwmuController.text.isNotEmpty ||
        _soakPitController.text.isNotEmpty ||
        _magicPitController.text.isNotEmpty ||
        _leachPitController.text.isNotEmpty ||
        _wspController.text.isNotEmpty ||
        _dewatsController.text.isNotEmpty) {
      sbmgTargets = {
        'ihhl': parseInteger(_ihhlController.text),
        'csc': parseInteger(_sbmgCscController.text),
        'rrc': parseInteger(_sbmgRrcController.text),
        'pwmu': parseInteger(_sbmgPwmuController.text),
        'soak_pit': parseInteger(_soakPitController.text),
        'magic_pit': parseInteger(_magicPitController.text),
        'leach_pit': parseInteger(_leachPitController.text),
        'wsp': parseInteger(_wspController.text),
        'dewats': parseInteger(_dewatsController.text),
      };
    }

    List<Map<String, dynamic>> villageData = [];
    for (var village in _villages) {
      final villageNameController =
          village['villageName'] as TextEditingController;
      final populationController =
          village['population'] as TextEditingController;
      final householdsController =
          village['households'] as TextEditingController;
      final ihhlController = village['ihhl'] as TextEditingController;
      final cscController = village['csc'] as TextEditingController;
      final soakPitController = village['soakPit'] as TextEditingController;
      final magicPitController = village['magicPit'] as TextEditingController;
      final leachPitController = village['leachPit'] as TextEditingController;
      final wspController = village['wsp'] as TextEditingController;
      final dewatsController = village['dewats'] as TextEditingController;
      int villageId = village['villageId'] is int
          ? village['villageId'] as int
          : (int.tryParse(village['villageId']?.toString() ?? '0') ?? 0);
      // Use logged-in user's village_id when stored value is 0 (invalid in villages table)
      if (villageId == 0 && fallbackVillageId != null) {
        villageId = fallbackVillageId;
      }

      if (villageNameController.text.isNotEmpty) {
        villageData.add({
          'village_id': villageId,
          'village_name': villageNameController.text,
          'population': parseInteger(populationController.text),
          'num_households': parseInteger(householdsController.text),
          'sbmg_assets': {
            'ihhl': parseInteger(ihhlController.text),
            'csc': parseInteger(cscController.text),
          },
          'gwm_assets': {
            'soak_pit': parseInteger(soakPitController.text),
            'magic_pit': parseInteger(magicPitController.text),
            'leach_pit': parseInteger(leachPitController.text),
            'wsp': parseInteger(wspController.text),
            'dewats': parseInteger(dewatsController.text),
          },
        });
      }
    }

    final numWardPanchs = int.tryParse(_numWardPanchsController.text) ?? 0;
    return {
      'vdo_name': _vdoNameController.text.trim().isEmpty
          ? ''
          : _vdoNameController.text.trim(),
      'sarpanch_name': _sarpanchNameController.text.isNotEmpty
          ? _sarpanchNameController.text
          : '',
      'sarpanch_contact': _sarpanchContactController.text.isNotEmpty
          ? _sarpanchContactController.text
          : '',
      'num_ward_panchs': numWardPanchs,
      if (workOrder != null) 'work_order': workOrder,
      if (fundSanctioned != null) 'fund_sanctioned': fundSanctioned,
      if (doorToDoorCollection != null)
        'door_to_door_collection': doorToDoorCollection,
      if (roadSweeping != null) 'road_sweeping': roadSweeping,
      if (drainCleaning != null) 'drain_cleaning': drainCleaning,
      if (cscDetails != null) 'csc_details': cscDetails,
      if (swmAssets != null) 'swm_assets': swmAssets,
      if (sbmgTargets != null) 'sbmg_targets': sbmgTargets,
      if (villageData.isNotEmpty) 'village_data': villageData,
    };
  }

  String _formatDateForApi(String dateString) {
    // Handle DD/MM/YYYY format from date picker
    if (dateString.contains('/')) {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    }
    // If already in correct format or empty, return as is
    return dateString;
  }

  void _showSurveyAlreadyFilledDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Survey Already Submitted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This survey has already been submitted for this Gram Panchayat for the current financial year.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'You can only submit the survey once per year.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF009B56),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
