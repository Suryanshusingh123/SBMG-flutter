import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../l10n/app_localizations.dart';

class BdoNewInspectionScreen extends StatefulWidget {
  final int gpId;
  final String gpName;
  const BdoNewInspectionScreen({super.key, required this.gpId, required this.gpName});

  @override
  State<BdoNewInspectionScreen> createState() => _BdoNewInspectionScreenState();
}

class _BdoNewInspectionScreenState extends State<BdoNewInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form controllers
  final _villageController = TextEditingController();
  final _numberOfWardsController = TextEditingController();
  final _suggestionsController = TextEditingController();

  // Radio button selections
  String? _dailyRegisterMaintained; // Yes/No
  String? _wasteCollectionInterval; // Daily, Weekly, Fortnight, None
  String? _separateCollectionWetDry; // Yes/No
  String? _wasteDisposalAtRRC; // Yes/No
  String? _arrangementAtRRC; // Yes/No
  String? _vehicleProperlyPrepared; // Yes/No
  String? _roadCleaningInterval; // Daily, Weekly, Fortnight, None
  String? _drainCleaningInterval; // Daily, Weekly, Fortnight, None
  String? _sludgeDisposalArrangement; // Yes/No
  String? _drainWasteCollectedRoadside; // Yes/No
  String? _cscCleaningInterval; // Daily, Weekly, Fortnight, None
  String? _cscElectricityWaterAvailable; // Yes/No
  String? _cscUsedByCommunity; // Yes/No
  String? _pinkToiletUsedInSchools; // Yes/No
  String? _firmPaidRegularly; // Yes/No
  String? _staffPaidRegularly; // Yes/No
  String? _safetyEquipmentProvided; // Yes/No
  String? _feedbackRegisterEntry; // Yes/No
  String? _rateChartPrepared; // Yes/No
  String? _rateChartDisplayed; // Yes/No

  // Expansion states - all closed initially, will expand as user fills previous sections
  bool _generalDetailsExpanded = false;
  bool _householdWasteExpanded = false;
  bool _roadCleaningExpanded = false;
  bool _drainCleaningExpanded = false;
  bool _cscCleaningExpanded = false;
  bool _otherPointsExpanded = false;
  bool _suggestionsExpanded = false;

  // Image uploads - section-specific
  List<File> _generalDetailsImages = [];
  List<File> _householdWasteImages = [];
  List<File> _roadCleaningImages = [];
  List<File> _drainCleaningImages = [];
  List<File> _cscCleaningImages = [];
  List<File> _otherPointsImages = [];

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Prefill village name with selected GP name
    _villageController.text = widget.gpName;
    // Auto-expand General Details section initially since Village is pre-filled
    _generalDetailsExpanded = true;
  }

  @override
  void dispose() {
    _villageController.dispose();
    _numberOfWardsController.dispose();
    _suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.inspection,
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
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      label: l10n.village,
                      controller: _villageController,
                      placeholder: l10n.enterVillageName,
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.thisFieldIsRequired : null,
                    ),
                    SizedBox(height: 20.h),
                    _buildExpandableSection(
                      title: l10n.generalDetails,
                      isExpanded: _generalDetailsExpanded,
                      onToggle: () => setState(() => _generalDetailsExpanded = !_generalDetailsExpanded),
                      children: [
                        _buildFormField(
                          label: l10n.numberOfWards,
                          controller: _numberOfWardsController,
                          placeholder: l10n.numberPlaceholder,
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.thisFieldIsRequired : null,
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.dailyRegisterMaintainedAtHeadquarters,
                          selectedValue: _dailyRegisterMaintained,
                          onChanged: (value) {
                            setState(() => _dailyRegisterMaintained = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _generalDetailsImages,
                          (images) => setState(() => _generalDetailsImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.householdWasteCollectionDisposal,
                      isExpanded: _householdWasteExpanded,
                      onToggle: () => setState(() => _householdWasteExpanded = !_householdWasteExpanded),
                      children: [
                        _buildIntervalRadioGroup(
                          label: l10n.atWhatIntervalWasteCollected,
                          selectedValue: _wasteCollectionInterval,
                          onChanged: (value) {
                            setState(() => _wasteCollectionInterval = value);
                          },
                          includeFortnight: false,
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.arrangementSeparateWetDryWaste,
                          selectedValue: _separateCollectionWetDry,
                          onChanged: (value) {
                            setState(() => _separateCollectionWetDry = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.wasteDisposedAtRrc,
                          selectedValue: _wasteDisposalAtRRC,
                          onChanged: (value) {
                            setState(() => _wasteDisposalAtRRC = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.arrangementWasteAtRrc,
                          selectedValue: _arrangementAtRRC,
                          onChanged: (value) {
                            setState(() => _arrangementAtRRC = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.wasteCollectionVehiclePrepared,
                          selectedValue: _vehicleProperlyPrepared,
                          onChanged: (value) {
                            setState(() => _vehicleProperlyPrepared = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _householdWasteImages,
                          (images) => setState(() => _householdWasteImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.roadCleaningWork,
                      isExpanded: _roadCleaningExpanded,
                      onToggle: () => setState(() => _roadCleaningExpanded = !_roadCleaningExpanded),
                      children: [
                        _buildIntervalRadioGroup(
                          label: l10n.atWhatIntervalRoadsSwept,
                          selectedValue: _roadCleaningInterval,
                          onChanged: (value) {
                            setState(() => _roadCleaningInterval = value);
                          },
                          includeDaily: false, // API: WEEKLY, FORTNIGHTLY, MONTHLY, NONE only
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _roadCleaningImages,
                          (images) => setState(() => _roadCleaningImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.drainCleaningWork,
                      isExpanded: _drainCleaningExpanded,
                      onToggle: () => setState(() => _drainCleaningExpanded = !_drainCleaningExpanded),
                      children: [
                        _buildIntervalRadioGroup(
                          label: l10n.atWhatIntervalDrainsCleaned,
                          selectedValue: _drainCleaningInterval,
                          onChanged: (value) {
                            setState(() => _drainCleaningInterval = value);
                          },
                          includeDaily: false, // API: WEEKLY, FORTNIGHTLY, MONTHLY, NONE only
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.disposalSludgeFromDrains,
                          selectedValue: _sludgeDisposalArrangement,
                          onChanged: (value) {
                            setState(() => _sludgeDisposalArrangement = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.drainWasteOnRoadside,
                          selectedValue: _drainWasteCollectedRoadside,
                          onChanged: (value) {
                            setState(() => _drainWasteCollectedRoadside = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _drainCleaningImages,
                          (images) => setState(() => _drainCleaningImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.cscCleaningWork,
                      isExpanded: _cscCleaningExpanded,
                      onToggle: () => setState(() => _cscCleaningExpanded = !_cscCleaningExpanded),
                      children: [
                        _buildIntervalRadioGroup(
                          label: l10n.intervalCscCleaning,
                          selectedValue: _cscCleaningInterval,
                          onChanged: (value) {
                            setState(() => _cscCleaningInterval = value);
                          },
                          includeFortnight: false,
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.availabilityElectricityWaterCsc,
                          selectedValue: _cscElectricityWaterAvailable,
                          onChanged: (value) {
                            setState(() => _cscElectricityWaterAvailable = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.cscUsedByCommunity,
                          selectedValue: _cscUsedByCommunity,
                          onChanged: (value) {
                            setState(() => _cscUsedByCommunity = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.pinkToiletInSchoolsUsed,
                          selectedValue: _pinkToiletUsedInSchools,
                          onChanged: (value) {
                            setState(() => _pinkToiletUsedInSchools = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _cscCleaningImages,
                          (images) => setState(() => _cscCleaningImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.otherPoints,
                      isExpanded: _otherPointsExpanded,
                      onToggle: () => setState(() => _otherPointsExpanded = !_otherPointsExpanded),
                      children: [
                        _buildYesNoRadioGroup(
                          label: l10n.firmPaidRegularly,
                          selectedValue: _firmPaidRegularly,
                          onChanged: (value) {
                            setState(() => _firmPaidRegularly = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.cleaningStaffPaidRegularly,
                          selectedValue: _staffPaidRegularly,
                          onChanged: (value) {
                            setState(() => _staffPaidRegularly = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.safetyEquipmentProvided,
                          selectedValue: _safetyEquipmentProvided,
                          onChanged: (value) {
                            setState(() => _safetyEquipmentProvided = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.entryInFeedbackRegister,
                          selectedValue: _feedbackRegisterEntry,
                          onChanged: (value) {
                            setState(() => _feedbackRegisterEntry = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.rateChartPrepared,
                          selectedValue: _rateChartPrepared,
                          onChanged: (value) {
                            setState(() => _rateChartPrepared = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildYesNoRadioGroup(
                          label: l10n.rateChartDisplayed,
                          selectedValue: _rateChartDisplayed,
                          onChanged: (value) {
                            setState(() => _rateChartDisplayed = value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildImageUploadSection(
                          _otherPointsImages,
                          (images) => setState(() => _otherPointsImages = images),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    _buildExpandableSection(
                      title: l10n.suggestionsByInspector,
                      isExpanded: _suggestionsExpanded,
                      onToggle: () => setState(() => _suggestionsExpanded = !_suggestionsExpanded),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: _suggestionsController,
                            maxLines: 5,
                            maxLength: 100,
                            validator: (v) => (v == null || v.trim().isEmpty) ? l10n.thisFieldIsRequired : null,
                            decoration: InputDecoration(
                              hintText: l10n.writeYourCommentHere,
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.all(12.r),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
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
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                    ),
                  ),
                  Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }

  Widget _buildYesNoRadioGroup({
    required String label,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        SizedBox(height: 8.h),
        Row(
          children: [
            _buildRadioOption(value: 'Yes', groupValue: selectedValue, onChanged: onChanged),
            SizedBox(width: 24.w),
            _buildRadioOption(value: 'No', groupValue: selectedValue, onChanged: onChanged),
          ],
        ),
      ],
    );
  }

  Widget _buildIntervalRadioGroup({
    required String label,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool includeFortnight = true,
    bool includeDaily = true,
  }) {
    final options = <Widget>[
      if (includeDaily) ...[
        _buildRadioOption(value: 'Daily', groupValue: selectedValue, onChanged: onChanged),
        SizedBox(width: 16.w),
      ],
      _buildRadioOption(value: 'Weekly', groupValue: selectedValue, onChanged: onChanged),
      if (includeFortnight) ...[
        SizedBox(width: 16.w),
        _buildRadioOption(value: 'Fortnight', groupValue: selectedValue, onChanged: onChanged),
      ],
      SizedBox(width: 16.w),
      _buildRadioOption(value: 'None', groupValue: selectedValue, onChanged: onChanged),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: options,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: AppColors.primaryColor,
          ),
          SizedBox(width: 4.w),
          Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(List<File> images, Function(List<File>) onImagesChanged) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo count indicator
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            '${images.length}/5 photos',
            style: TextStyle(
              fontSize: 12.sp,
              color: images.length >= 5 ? Colors.orange : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (images.isEmpty)
          GestureDetector(
            onTap: () => _pickImages(images, onImagesChanged),
            child: Container(
              width: double.infinity,
              height: 140.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.values[1]),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40.sp, color: Colors.grey.shade400),
                  SizedBox(height: 8.h),
                  Text(l10n.uploadImage, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...images.map((image) => Stack(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () {
                            final newImages = List<File>.from(images);
                            newImages.remove(image);
                            onImagesChanged(newImages);
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  )),
              if (images.length < 5)
                GestureDetector(
                  onTap: () => _pickImages(images, onImagesChanged),
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.values[1]),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 24.sp, color: Colors.grey.shade400),
                        SizedBox(height: 4.h),
                        Text(l10n.add, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickImages(List<File> currentImages, Function(List<File>) onImagesChanged) async {
    // Check if already at maximum limit
    if (currentImages.length >= 5) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.maximumFivePhotosUploaded),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> pickedImages = await picker.pickMultiImage(imageQuality: 80);
      if (pickedImages.isNotEmpty) {
        final int remainingSlots = 5 - currentImages.length;
        final List<File> newImages = [
          ...currentImages,
          ...pickedImages.take(remainingSlots).map((xFile) => File(xFile.path)),
        ];
        onImagesChanged(newImages);
        
        // Show message if user tried to add more than allowed
        if (pickedImages.length > remainingSlots) {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.onlyPhotosAddedMaximumFive(remainingSlots)),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToPickImagesError(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: const BoxDecoration(color: Color(0xFFFFB800), shape: BoxShape.circle),
                child: const Icon(Icons.star, color: Colors.white, size: 32),
              ),
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context)!.inspectionSubmittedSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context, true); // Return true to indicate successful submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.close, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _convertIntervalToApi(String? value, {bool allowDaily = true, bool allowFortnight = false}) {
    if (value == null) return null;
    switch (value) {
      case 'Daily':
        return allowDaily ? 'DAILY' : 'WEEKLY';
      case 'Weekly':
        return 'WEEKLY';
      case 'Fortnight':
        return allowFortnight ? 'FORTNIGHTLY' : 'WEEKLY';
      case 'None':
        return 'NONE';
      default:
        return value.toUpperCase();
    }
  }

  // API only accepts WEEKLY, FORTNIGHTLY, MONTHLY, NONE for road/drain (no DAILY; UI hides Daily for these)
  String? _convertRoadDrainIntervalToApi(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'Weekly':
        return 'WEEKLY';
      case 'Fortnight':
        return 'FORTNIGHTLY';
      case 'None':
        return 'NONE';
      default:
        final upper = value.toUpperCase();
        if (['WEEKLY', 'FORTNIGHTLY', 'MONTHLY', 'NONE'].contains(upper)) {
          return upper;
        }
        return 'WEEKLY';
    }
  }

  bool? _convertYesNoToBool(String? value) {
    if (value == null) return null;
    return value == 'Yes';
  }

  /// Returns null if all required fields (except images) are filled; otherwise returns error message.
  String? _validateAllRequiredFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_villageController.text.trim().isEmpty) return l10n.pleaseFillAllFields;
    if (_numberOfWardsController.text.trim().isEmpty) return l10n.pleaseFillAllFields;
    if (_suggestionsController.text.trim().isEmpty) return l10n.pleaseFillAllFields;
    if (_dailyRegisterMaintained == null) return l10n.pleaseFillAllFields;
    if (_wasteCollectionInterval == null) return l10n.pleaseFillAllFields;
    if (_separateCollectionWetDry == null) return l10n.pleaseFillAllFields;
    if (_wasteDisposalAtRRC == null) return l10n.pleaseFillAllFields;
    if (_arrangementAtRRC == null) return l10n.pleaseFillAllFields;
    if (_vehicleProperlyPrepared == null) return l10n.pleaseFillAllFields;
    if (_roadCleaningInterval == null) return l10n.pleaseFillAllFields;
    if (_drainCleaningInterval == null) return l10n.pleaseFillAllFields;
    if (_sludgeDisposalArrangement == null) return l10n.pleaseFillAllFields;
    if (_drainWasteCollectedRoadside == null) return l10n.pleaseFillAllFields;
    if (_cscCleaningInterval == null) return l10n.pleaseFillAllFields;
    if (_cscElectricityWaterAvailable == null) return l10n.pleaseFillAllFields;
    if (_cscUsedByCommunity == null) return l10n.pleaseFillAllFields;
    if (_pinkToiletUsedInSchools == null) return l10n.pleaseFillAllFields;
    if (_firmPaidRegularly == null) return l10n.pleaseFillAllFields;
    if (_staffPaidRegularly == null) return l10n.pleaseFillAllFields;
    if (_safetyEquipmentProvided == null) return l10n.pleaseFillAllFields;
    if (_feedbackRegisterEntry == null) return l10n.pleaseFillAllFields;
    if (_rateChartPrepared == null) return l10n.pleaseFillAllFields;
    if (_rateChartDisplayed == null) return l10n.pleaseFillAllFields;
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final validationError = _validateAllRequiredFields(context);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String lat = '';
      String long = '';
      try {
        final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        lat = position.latitude.toString();
        long = position.longitude.toString();
      } catch (_) {}

      final now = DateTime.now();
      final inspectionDate = DateFormat('yyyy-MM-dd').format(now);
      final startTime = now.toUtc().toIso8601String();

      final formData = <String, dynamic>{
        'gp_id': widget.gpId,
        'village_name': _villageController.text.trim(),
        'remarks': _suggestionsController.text.trim().isNotEmpty ? _suggestionsController.text.trim() : 'string',
        'inspection_date': inspectionDate,
        'start_time': startTime,
        'lat': lat.isEmpty ? 'string' : lat,
        'long': long.isEmpty ? 'string' : long,
        'register_maintenance': _convertYesNoToBool(_dailyRegisterMaintained) ?? false,
        'household_waste': {
          'waste_collection_frequency': _convertIntervalToApi(_wasteCollectionInterval, allowFortnight: false) ?? 'DAILY',
          'dry_wet_vehicle_segregation': _convertYesNoToBool(_separateCollectionWetDry) ?? false,
          'covered_collection_in_vehicles': _convertYesNoToBool(_separateCollectionWetDry) ?? false,
          'waste_disposed_at_rrc': _convertYesNoToBool(_wasteDisposalAtRRC) ?? false,
          'rrc_waste_collection_and_disposal_arrangement': _convertYesNoToBool(_arrangementAtRRC) ?? false,
          'waste_collection_vehicle_functional': _convertYesNoToBool(_vehicleProperlyPrepared) ?? false,
        },
        'road_and_drain': {
          'road_cleaning_frequency': _convertRoadDrainIntervalToApi(_roadCleaningInterval) ?? 'WEEKLY',
          'drain_cleaning_frequency': _convertRoadDrainIntervalToApi(_drainCleaningInterval) ?? 'WEEKLY',
          'disposal_of_sludge_from_drains': _convertYesNoToBool(_sludgeDisposalArrangement) ?? false,
          'drain_waste_colllected_on_roadside': _convertYesNoToBool(_drainWasteCollectedRoadside) ?? false,
        },
        'community_sanitation': {
          'csc_cleaning_frequency': _convertIntervalToApi(_cscCleaningInterval, allowFortnight: false) ?? 'DAILY',
          'electricity_and_water': _convertYesNoToBool(_cscElectricityWaterAvailable) ?? false,
          'csc_used_by_community': _convertYesNoToBool(_cscUsedByCommunity) ?? false,
          'pink_toilets_cleaning': _convertYesNoToBool(_pinkToiletUsedInSchools) ?? false,
          'pink_toilets_used': _convertYesNoToBool(_pinkToiletUsedInSchools) ?? false,
        },
        'other_items': {
          'firm_paid_regularly': _convertYesNoToBool(_firmPaidRegularly) ?? false,
          'cleaning_staff_paid_regularly': _convertYesNoToBool(_staffPaidRegularly) ?? false,
          'firm_provided_safety_equipment': _convertYesNoToBool(_safetyEquipmentProvided) ?? false,
          'regular_feedback_register_entry': _convertYesNoToBool(_feedbackRegisterEntry) ?? false,
          'chart_prepared_for_cleaning_work': _convertYesNoToBool(_rateChartPrepared) ?? false,
          'village_visibly_clean': true,
          'rate_chart_displayed': _convertYesNoToBool(_rateChartDisplayed) ?? false,
        },
      };

      await _apiService.submitInspection(formData);
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToSubmitInspection(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}


