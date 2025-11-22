import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';

class VillageMasterDataFormScreen extends StatefulWidget {
  const VillageMasterDataFormScreen({super.key});

  @override
  State<VillageMasterDataFormScreen> createState() =>
      _VillageMasterDataFormScreenState();
}

class _VillageMasterDataFormScreenState
    extends State<VillageMasterDataFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _vdoNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _sarpanchNameController = TextEditingController();
  final _sarpanchContactController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _workOrderNoController = TextEditingController();
  final _workOrderDateController = TextEditingController();
  final _workOrderAmountController = TextEditingController();
  final _fundAmountController = TextEditingController();
  String? _selectedFundHead; // Radio button selection for Fund Head
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
  bool _contractorExpanded = false;
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

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupAutoExpandListeners();
  }

  void _setupAutoExpandListeners() {
    // Listen to VDO Name and Contact Number to auto-expand Sarpanch section
    _vdoNameController.addListener(_checkAndAutoExpandBasicInfo);
    _contactNumberController.addListener(_checkAndAutoExpandBasicInfo);

    // Listen to Sarpanch fields to auto-expand Contractor section
    _sarpanchNameController.addListener(_checkAndAutoExpandSarpanch);
    _sarpanchContactController.addListener(_checkAndAutoExpandSarpanch);

    // Listen to Contractor field to auto-expand Work Order section
    _contractorNameController.addListener(_checkAndAutoExpandContractor);

    // Listen to Work Order fields to auto-expand Fund section
    _workOrderNoController.addListener(_checkAndAutoExpandWorkOrder);
    _workOrderDateController.addListener(_checkAndAutoExpandWorkOrder);
    _workOrderAmountController.addListener(_checkAndAutoExpandWorkOrder);

    // Listen to Fund fields to auto-expand Collection section
    _fundAmountController.addListener(_checkAndAutoExpandFund);

    // Listen to Collection fields to auto-expand Road Sweeping section
    _householdsController.addListener(_checkAndAutoExpandCollection);
    _shopsController.addListener(_checkAndAutoExpandCollection);

    // Listen to Road Sweeping fields to auto-expand Drain Cleaning section
    _roadWidthController.addListener(_checkAndAutoExpandRoadSweeping);
    _roadLengthController.addListener(_checkAndAutoExpandRoadSweeping);

    // Listen to Drain Cleaning fields to auto-expand CSC section
    _drainLengthController.addListener(_checkAndAutoExpandDrainCleaning);

    // Listen to CSC fields to auto-expand SWM Assets section
    _cscNumbersController.addListener(_checkAndAutoExpandCsc);

    // Listen to SWM Assets fields to auto-expand SBMG Targets section
    _rrcController.addListener(_checkAndAutoExpandSwmAssets);
    _pwmuController.addListener(_checkAndAutoExpandSwmAssets);
    _compositPitController.addListener(_checkAndAutoExpandSwmAssets);
    _collectionVehicleController.addListener(_checkAndAutoExpandSwmAssets);

    // Listen to SBMG Targets fields to auto-expand Villages section
    _ihhlController.addListener(_checkAndAutoExpandSbmgTargets);
    _sbmgCscController.addListener(_checkAndAutoExpandSbmgTargets);
    _sbmgRrcController.addListener(_checkAndAutoExpandSbmgTargets);
    _sbmgPwmuController.addListener(_checkAndAutoExpandSbmgTargets);
    _soakPitController.addListener(_checkAndAutoExpandSbmgTargets);
    _magicPitController.addListener(_checkAndAutoExpandSbmgTargets);
    _leachPitController.addListener(_checkAndAutoExpandSbmgTargets);
    _wspController.addListener(_checkAndAutoExpandSbmgTargets);
    _dewatsController.addListener(_checkAndAutoExpandSbmgTargets);
  }

  void _checkAndAutoExpandBasicInfo() {
    if (_vdoNameController.text.trim().isNotEmpty &&
        _contactNumberController.text.trim().length == 10) {
      _autoExpandNextSection('basic');
    }
  }

  void _checkAndAutoExpandSarpanch() {
    if (_sarpanchNameController.text.trim().isNotEmpty &&
        _sarpanchContactController.text.trim().length == 10) {
      _autoExpandNextSection('sarpanch');
    }
  }

  void _checkAndAutoExpandContractor() {
    if (_contractorNameController.text.trim().isNotEmpty) {
      _autoExpandNextSection('contractor');
    }
  }

  void _checkAndAutoExpandWorkOrder() {
    if (_workOrderNoController.text.trim().isNotEmpty &&
        _workOrderDateController.text.trim().isNotEmpty &&
        _workOrderAmountController.text.trim().isNotEmpty) {
      _autoExpandNextSection('workOrder');
    }
  }

  void _checkAndAutoExpandFund() {
    if (_fundAmountController.text.trim().isNotEmpty &&
        _selectedFundHead != null) {
      _autoExpandNextSection('fund');
    }
  }

  void _checkAndAutoExpandCollection() {
    if (_householdsController.text.trim().isNotEmpty &&
        _shopsController.text.trim().isNotEmpty &&
        _selectedCollectionFrequency != null) {
      _autoExpandNextSection('collection');
    }
  }

  void _checkAndAutoExpandRoadSweeping() {
    if (_roadWidthController.text.trim().isNotEmpty &&
        _roadLengthController.text.trim().isNotEmpty &&
        _selectedRoadCleaningFrequency != null) {
      _autoExpandNextSection('roadSweeping');
    }
  }

  void _checkAndAutoExpandDrainCleaning() {
    if (_drainLengthController.text.trim().isNotEmpty &&
        _selectedDrainCleaningFrequency != null) {
      _autoExpandNextSection('drainCleaning');
    }
  }

  void _checkAndAutoExpandCsc() {
    if (_cscNumbersController.text.trim().isNotEmpty &&
        _selectedCscCleaningFrequency != null) {
      _autoExpandNextSection('csc');
    }
  }

  void _checkAndAutoExpandSwmAssets() {
    if (_rrcController.text.trim().isNotEmpty &&
        _pwmuController.text.trim().isNotEmpty &&
        _compositPitController.text.trim().isNotEmpty &&
        _collectionVehicleController.text.trim().isNotEmpty) {
      _autoExpandNextSection('swmAssets');
    }
  }

  void _checkAndAutoExpandSbmgTargets() {
    if (_ihhlController.text.trim().isNotEmpty &&
        _sbmgCscController.text.trim().isNotEmpty &&
        _sbmgRrcController.text.trim().isNotEmpty &&
        _sbmgPwmuController.text.trim().isNotEmpty &&
        _soakPitController.text.trim().isNotEmpty &&
        _magicPitController.text.trim().isNotEmpty &&
        _leachPitController.text.trim().isNotEmpty &&
        _wspController.text.trim().isNotEmpty &&
        _dewatsController.text.trim().isNotEmpty) {
      _autoExpandNextSection('sbmgTargets');
    }
  }

  void _autoExpandNextSection(String currentSection) {
    if (!mounted) return;

    setState(() {
      // Close current section and open next one
      switch (currentSection) {
        case 'basic':
          // Don't close basic info as it's always visible
          if (!_sarpanchExpanded) {
            _sarpanchExpanded = true;
          }
          break;
        case 'sarpanch':
          _sarpanchExpanded = false;
          if (!_contractorExpanded) {
            _contractorExpanded = true;
          }
          break;
        case 'contractor':
          _contractorExpanded = false;
          if (!_workOrderExpanded) {
            _workOrderExpanded = true;
          }
          break;
        case 'workOrder':
          _workOrderExpanded = false;
          if (!_fundExpanded) {
            _fundExpanded = true;
          }
          break;
        case 'fund':
          _fundExpanded = false;
          if (!_collectionExpanded) {
            _collectionExpanded = true;
          }
          break;
        case 'collection':
          _collectionExpanded = false;
          if (!_roadSweepingExpanded) {
            _roadSweepingExpanded = true;
          }
          break;
        case 'roadSweeping':
          _roadSweepingExpanded = false;
          if (!_drainCleaningExpanded) {
            _drainCleaningExpanded = true;
          }
          break;
        case 'drainCleaning':
          _drainCleaningExpanded = false;
          if (!_cscExpanded) {
            _cscExpanded = true;
          }
          break;
        case 'csc':
          _cscExpanded = false;
          if (!_swmAssetsExpanded) {
            _swmAssetsExpanded = true;
          }
          break;
        case 'swmAssets':
          _swmAssetsExpanded = false;
          if (!_sbmgTargetsExpanded) {
            _sbmgTargetsExpanded = true;
          }
          break;
        case 'sbmgTargets':
          _sbmgTargetsExpanded = false;
          if (!_villagesExpanded) {
            _villagesExpanded = true;
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _vdoNameController.dispose();
    _contactNumberController.dispose();
    _sarpanchNameController.dispose();
    _sarpanchContactController.dispose();
    _contractorNameController.dispose();
    _workOrderNoController.dispose();
    _workOrderDateController.dispose();
    _workOrderAmountController.dispose();
    _fundAmountController.dispose();
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
        title: const Text(
          'GP Master Data Form',
          style: TextStyle(
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
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VDO Name
                    _buildFormField(
                      label: 'VOD Name',
                      controller: _vdoNameController,
                      placeholder: 'VDO Name',
                    ),

                    SizedBox(height: 20.h),

                    // Contact Number
                    _buildFormField(
                      label: 'Contact Number',
                      controller: _contactNumberController,
                      placeholder: 'Contact Number (10 digits)',
                      keyboardType: TextInputType.phone,
                      isContactField: true,
                    ),

                    SizedBox(height: 20.h),

                    // Sarpanch details (Expandable)
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
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Contact Number',
                          controller: _sarpanchContactController,
                          placeholder: 'Number (10 digits)',
                          keyboardType: TextInputType.phone,
                          isContactField: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Contractor details (Expandable)
                    _buildExpandableSection(
                      title: 'Contractor details',
                      isExpanded: _contractorExpanded,
                      onToggle: () => setState(
                        () => _contractorExpanded = !_contractorExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Name',
                          controller: _contractorNameController,
                          placeholder: 'Name',
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Work order details (Expandable)
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
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Date',
                          controller: _workOrderDateController,
                          placeholder: 'Date',
                          onTap: () =>
                              _selectDate(context, _workOrderDateController),
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Amount',
                          controller: _workOrderAmountController,
                          placeholder: 'amount',
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
                        _buildFormField(
                          label: 'Amount',
                          controller: _fundAmountController,
                          placeholder: 'amount',
                          keyboardType: TextInputType.number,
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
                            // Check if section is complete and auto-expand next
                            Future.microtask(
                              () => _checkAndAutoExpandCollection(),
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
                          label: 'Width',
                          controller: _roadWidthController,
                          placeholder: 'Width',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Length',
                          controller: _roadLengthController,
                          placeholder: 'Length',
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
                            // Check if section is complete and auto-expand next
                            Future.microtask(
                              () => _checkAndAutoExpandRoadSweeping(),
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
                            // Check if section is complete and auto-expand next
                            Future.microtask(
                              () => _checkAndAutoExpandDrainCleaning(),
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
                            // Check if section is complete and auto-expand next
                            Future.microtask(() => _checkAndAutoExpandCsc());
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // SWM Assets (Expandable)
                    _buildExpandableSection(
                      title: 'SWM Assets',
                      isExpanded: _swmAssetsExpanded,
                      onToggle: () => setState(
                        () => _swmAssetsExpanded = !_swmAssetsExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'RRC',
                          controller: _rrcController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'PWMU',
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
                      title: 'SBMG year Targets',
                      isExpanded: _sbmgTargetsExpanded,
                      onToggle: () => setState(
                        () => _sbmgTargetsExpanded = !_sbmgTargetsExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'IHHL',
                          controller: _ihhlController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'CSC',
                          controller: _sbmgCscController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'RRC',
                          controller: _sbmgRrcController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'PWMU',
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
                          label: 'WSP',
                          controller: _wspController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'DEWATS',
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
                      : const Text(
                          'Submit',
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
      'MONTHLY',
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
            value: selectedValue,
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
    return FormField<String>(
      validator: (_) {
        if (_selectedFundHead == null || _selectedFundHead!.isEmpty) {
          return 'Please select a fund head';
        }
        return null;
      },
      builder: (state) {
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
                _buildRadioOption('FFC', state),
                SizedBox(height: 12.h),
                _buildRadioOption('SFC', state),
                SizedBox(height: 12.h),
                _buildRadioOption('CSR', state),
                SizedBox(height: 12.h),
                _buildRadioOption('Own income', state),
                SizedBox(height: 12.h),
                _buildRadioOption('Other', state),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRadioOption(String value, FormFieldState<String> state) {
    return InkWell(
      onTap: () {
        setState(() => _selectedFundHead = value);
        state.didChange(value);
      },
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedFundHead,
            onChanged: (String? newValue) {
              setState(() => _selectedFundHead = newValue);
              if (newValue != null) {
                state.didChange(newValue);
              }
              // Check if section is complete and auto-expand next
              Future.microtask(() => _checkAndAutoExpandFund());
            },
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
    bool expandContractor = false;
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

    checkController(_vdoNameController, 'VDO name');
    // Validate contact number - must be exactly 10 digits
    if (_contactNumberController.text.trim().isEmpty) {
      missingFields.add('Contact number');
    } else if (_contactNumberController.text.trim().length != 10) {
      missingFields.add('Contact number must be exactly 10 digits');
    }

    checkController(
      _sarpanchNameController,
      'Sarpanch name',
      markSection: () => expandSarpanch = true,
    );
    // Validate sarpanch contact number - must be exactly 10 digits
    if (_sarpanchContactController.text.trim().isEmpty) {
      missingFields.add('Sarpanch contact number');
      expandSarpanch = true;
    } else if (_sarpanchContactController.text.trim().length != 10) {
      missingFields.add('Sarpanch contact number must be exactly 10 digits');
      expandSarpanch = true;
    }

    checkController(
      _contractorNameController,
      'Contractor name',
      markSection: () => expandContractor = true,
    );

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
      setState(() {
        if (expandSarpanch) _sarpanchExpanded = true;
        if (expandContractor) _contractorExpanded = true;
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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
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

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user information
      print('📋 Step 1: Retrieving user information...');
      final authService = AuthService();
      final gpId = await authService.getVillageId();
      print('📍 GP ID: $gpId');

      // Get current user to get VDO ID
      print('👤 Fetching current user data...');
      final userInfo = await authService.getCurrentUser();
      if (!userInfo['success']) {
        print('❌ Failed to get user information');
        throw Exception('Failed to get user information');
      }

      final userData = userInfo['user'] as Map<String, dynamic>;
      final vdoId = userData['id'];
      print('👤 VDO ID: $vdoId');

      if (gpId == null || vdoId == null) {
        print('❌ Missing required information - GP ID: $gpId, VDO ID: $vdoId');
        throw Exception('Missing required information (GP ID or VDO ID)');
      }

      // Step 1: Get active FY ID
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📋 Step 2: Getting active FY ID...');
      final apiService = ApiService();
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
        Navigator.pop(context, completionDate);
      }
    } catch (e) {
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
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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

    // Helper function to parse integer from text
    int? parseInteger(String? value) {
      if (value == null || value.isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }

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
        'head': _selectedFundHead ?? 'FFC',
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

      if (villageNameController.text.isNotEmpty) {
        villageData.add({
          'village_id': 0, // Will be set by backend if needed
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
      'sarpanch_name': _sarpanchNameController.text.isNotEmpty
          ? _sarpanchNameController.text
          : 'string',
      'sarpanch_contact': _sarpanchContactController.text.isNotEmpty
          ? _sarpanchContactController.text
          : 'string',
      'num_ward_panchs': 0, // Not in form, defaulting to 0
      'agency_id': 0, // Not in form, defaulting to 0
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
