import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../models/complaint_type_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/citizen_colors.dart';
import 'dart:io';
import 'raise_complaint_screen.dart';

class ComplaintLocationScreen extends StatefulWidget {
  final List<ImageWithLocation> uploadedImages;
  final ComplaintType? selectedComplaintType;
  final String description;

  const ComplaintLocationScreen({
    super.key,
    required this.uploadedImages,
    required this.selectedComplaintType,
    required this.description,
  });

  @override
  State<ComplaintLocationScreen> createState() =>
      _ComplaintLocationScreenState();
}

class _ComplaintLocationScreenState extends State<ComplaintLocationScreen> {
  // Location data
  District? selectedDistrict;
  Block? selectedBlock;
  Village? selectedVillage;

  // Text controllers
  final _villageController = TextEditingController();
  final _wardAreaController = TextEditingController();

  // Data lists
  List<District> districts = [];
  List<Block> blocks = [];
  List<Village> villages = [];

  // Loading states
  bool isLoadingDistricts = true;
  bool isLoadingBlocks = false;
  bool isLoadingVillages = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      setState(() => isLoadingDistricts = true);
      final fetchedDistricts = await ApiService().getDistricts();
      setState(() {
        districts = fetchedDistricts;
        isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => isLoadingDistricts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load districts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBlocks(int districtId) async {
    try {
      setState(() {
        isLoadingBlocks = true;
        blocks = [];
        selectedBlock = null;
        villages = [];
        selectedVillage = null;
        _villageController.clear();
      });

      final fetchedBlocks = await ApiService().getBlocks(
        districtId: districtId,
      );
      setState(() {
        blocks = fetchedBlocks;
        isLoadingBlocks = false;
      });
    } catch (e) {
      setState(() => isLoadingBlocks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load blocks'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadVillages(int blockId, int districtId) async {
    try {
      setState(() {
        isLoadingVillages = true;
        villages = [];
        selectedVillage = null;
        _villageController.clear();
      });

      final fetchedVillages = await ApiService().getVillages(
        blockId: blockId,
        districtId: districtId,
      );
      setState(() {
        villages = fetchedVillages;
        isLoadingVillages = false;
      });
    } catch (e) {
      setState(() => isLoadingVillages = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load villages'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: CitizenColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Star icon
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB800),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: CitizenColors.light,
                  size: 32,
                ),
              ),
              SizedBox(height: 20.h),

              // Success message
              Text(
                l10n.yourComplaintHasBeenSubmittedSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CitizenColors.textPrimary(context),
                ),
              ),
              SizedBox(height: 24.h),

              // Close button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(
                      context,
                      '/citizen-dashboard',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: CitizenColors.light,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitComplaint() async {
    final l10n = AppLocalizations.of(context)!;
    if (selectedDistrict == null ||
        selectedBlock == null ||
        _villageController.text.isEmpty ||
        _wardAreaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      print('🚀 Starting complaint submission...');
      print('📝 Step 1: Getting auth token...');

      // Get auth token
      final authService = AuthService();
      final token = await authService.getToken();

      if (token == null) {
        print('❌ No auth token found');
        throw Exception('User not authenticated');
      }
      print('✅ Auth token retrieved');

      print('📝 Step 2: Processing uploaded images...');
      print('   - Total images: ${widget.uploadedImages.length}');

      if (widget.uploadedImages.isEmpty) {
        print('❌ No images uploaded');
        throw Exception('No images uploaded');
      }

      final List<File> imageFiles = widget.uploadedImages
          .map((img) => img.imageFile)
          .toList();
      print('   - Converted to File list: ${imageFiles.length} files');

      print('📝 Step 3: Getting location from first image...');
      final firstImage = widget.uploadedImages.first;
      print('   - Latitude: ${firstImage.latitude}');
      print('   - Longitude: ${firstImage.longitude}');

      print('📝 Step 4: Preparing complaint data...');
      print('   - Complaint Type ID: ${widget.selectedComplaintType?.id}');
      final resolvedGpId = selectedVillage?.gpId ?? selectedVillage?.id ?? 1;
      print('   - Selected Village: ${selectedVillage?.name}');
      print('   - GP ID: $resolvedGpId');
      print('   - Village Text: ${_villageController.text}');
      print('   - Ward/Area: ${_wardAreaController.text}');
      print('   - Description: ${widget.description}');

      if (widget.selectedComplaintType == null) {
        print('❌ Complaint type is null');
        throw Exception('Complaint type not selected');
      }

      print('📝 Step 5: Calling submitComplaint API...');

      // Submit complaint
      // Location will be automatically fetched from GPS coordinates by the API
      await ApiService().submitComplaint(
        token: token,
        complaintTypeId: widget.selectedComplaintType!.id,
        gpId: resolvedGpId,
        description: widget.description,
        files: imageFiles,
        lat: firstImage.latitude,
        long: firstImage.longitude,
        location: '', // Empty string - API will get location from GPS coordinates
      );

      print('✅ Complaint submitted successfully!');

      if (mounted) {
        await _showSuccessDialog();
      }
    } catch (e, stackTrace) {
      print('❌ Error submitting complaint: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _villageController.dispose();
    _wardAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Scaffold(
      backgroundColor: CitizenColors.background(context),
      appBar: AppBar(
        backgroundColor: CitizenColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.complaintLocation,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // District
                  Text(
                    l10n.district,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: isLoadingDistricts
                        ? null
                        : () {
                            BottomSheetPicker.show<District>(
                              context: context,
                              title: l10n.selectDistrict,
                              items: districts,
                              selectedItem: selectedDistrict,
                              itemBuilder: (district) => district.name,
                              showSearch: true,
                              searchHint: l10n.searchDistricts,
                              isLoading: isLoadingDistricts,
                              onSelected: (district) {
                                setState(() {
                                  selectedDistrict = district;
                                  selectedBlock = null;
                                  selectedVillage = null;
                                  blocks = [];
                                  villages = [];
                                });
                                if (selectedDistrict != null) {
                                  _loadBlocks(selectedDistrict!.id);
                                }
                              },
                            );
                          },
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                        color: isLoadingDistricts
                            ? Colors.grey.shade100
                            : surfaceColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: isLoadingDistricts
                                ? Row(
                                    children: [
                                      SizedBox(
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
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Loading districts...',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    selectedDistrict?.name ?? l10n.selectDistrict,
                                    style: TextStyle(
                                      color: selectedDistrict != null
                                          ? primaryTextColor
                                          : secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          if (!isLoadingDistricts)
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Block
                  Text(
                    l10n.block,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: (selectedDistrict == null || isLoadingBlocks)
                        ? null
                        : () {
                            BottomSheetPicker.show<Block>(
                              context: context,
                              title: l10n.selectBlock,
                              items: blocks,
                              selectedItem: selectedBlock,
                              itemBuilder: (block) => block.name,
                              showSearch: true,
                              searchHint: l10n.searchBlocks,
                              isLoading: isLoadingBlocks,
                              onSelected: (block) {
                                setState(() {
                                  selectedBlock = block;
                                  selectedVillage = null;
                                  villages = [];
                                });
                                if (selectedDistrict != null) {
                                  _loadVillages(
                                    selectedBlock!.id,
                                    selectedDistrict!.id,
                                  );
                                }
                              },
                            );
                          },
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                        color: (selectedDistrict == null || isLoadingBlocks)
                            ? Colors.grey.shade100
                            : surfaceColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: isLoadingBlocks
                                ? Row(
                                    children: [
                                      SizedBox(
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
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Loading blocks...',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    selectedBlock?.name ?? l10n.selectBlock,
                                    style: TextStyle(
                                      color: selectedBlock != null
                                          ? primaryTextColor
                                          : secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          if (!isLoadingBlocks)
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Gram Panchayat
                  Text(
                    l10n.gramPanchayat,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: (selectedBlock == null || isLoadingVillages)
                        ? null
                        : () {
                            BottomSheetPicker.show<Village>(
                              context: context,
                              title: l10n.selectGramPanchayat,
                              items: villages,
                              selectedItem: selectedVillage,
                              itemBuilder: (village) => village.name,
                              showSearch: true,
                              searchHint: l10n.searchVillages,
                              isLoading: isLoadingVillages,
                              onSelected: (village) {
                                setState(() {
                                  selectedVillage = village;
                                  _villageController.text = village.name;
                                });
                              },
                            );
                          },
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                        color: (selectedBlock == null || isLoadingVillages)
                            ? Colors.grey.shade100
                            : surfaceColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: isLoadingVillages
                                ? Row(
                                    children: [
                                      SizedBox(
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
                                      SizedBox(width: 8.w),
                                      Text(
                                        'Loading villages...',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    selectedVillage?.name ?? l10n.selectGramPanchayat,
                                    style: TextStyle(
                                      color: selectedVillage != null
                                          ? primaryTextColor
                                          : secondaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          if (!isLoadingVillages)
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Village
                  Text(
                    l10n.village,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _villageController,
                    decoration: InputDecoration(
                      hintText: l10n.enterVillage,
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
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Ward/Area
                  Text(
                    l10n.wardArea,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _wardAreaController,
                    decoration: InputDecoration(
                      hintText: l10n.enterWardArea,
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
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: CitizenColors.light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CitizenColors.light,
                          ),
                        ),
                      )
                    : Text(
                        l10n.submitComplaint,
                        style: const TextStyle(
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
}
