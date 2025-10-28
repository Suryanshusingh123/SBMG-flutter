import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import '../../models/geography_model.dart';
import '../../models/complaint_type_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';
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
  final _locationController = TextEditingController();

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
                child: const Icon(Icons.star, color: Colors.white, size: 32),
              ),
              SizedBox(height: 20.h),

              // Success message
              Text(
                l10n.yourComplaintHasBeenSubmittedSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
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
                    foregroundColor: Colors.white,
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
        _wardAreaController.text.isEmpty ||
        _locationController.text.isEmpty) {
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
      print('   - Selected Village: ${selectedVillage?.name}');
      print('   - GP ID: ${selectedVillage?.gpId ?? 1}');
      print('   - Village Text: ${_villageController.text}');
      print('   - Ward/Area: ${_wardAreaController.text}');
      print('   - Location: ${_locationController.text}');
      print('   - Description: ${widget.description}');

      if (widget.selectedComplaintType == null) {
        print('❌ Complaint type is null');
        throw Exception('Complaint type not selected');
      }

      print('📝 Step 5: Calling submitComplaint API...');

      // Submit complaint
      await ApiService().submitComplaint(
        token: token,
        complaintTypeId: widget.selectedComplaintType!.id,
        gpId: selectedVillage?.gpId ?? 1, // Use gp_id from selected village
        description: widget.description,
        files: imageFiles,
        lat: firstImage.latitude,
        long: firstImage.longitude,
        location: _locationController.text,
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
    _locationController.dispose();
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
          l10n.complaintLocation,
          style: const TextStyle(
            color: Colors.black,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () {
                      BottomSheetPicker.show<District>(
                        context: context,
                        title: l10n.selectDistrict,
                        items: districts,
                        selectedItem: selectedDistrict,
                        itemBuilder: (district) => district.name,
                        showSearch: true,
                        searchHint: l10n.searchDistricts,
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
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDistrict?.name ?? l10n.selectDistrict,
                              style: TextStyle(
                                color: selectedDistrict != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Block
                  Text(
                    l10n.block,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: selectedDistrict == null
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
                        color: selectedDistrict == null
                            ? Colors.grey.shade100
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedBlock?.name ?? l10n.selectBlock,
                              style: TextStyle(
                                color: selectedBlock != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Gram Panchayat
                  Text(
                    l10n.gramPanchayat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: selectedBlock == null
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
                        color: selectedBlock == null
                            ? Colors.grey.shade100
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedVillage?.name ?? l10n.selectGramPanchayat,
                              style: TextStyle(
                                color: selectedVillage != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Village
                  Text(
                    l10n.village,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
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
                  SizedBox(height: 16.h),

                  // Location
                  Text(
                    l10n.location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: l10n.enterLocation,
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
              color: Colors.white,
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
                  foregroundColor: Colors.white,
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
                            Colors.white,
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
