import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../config/connstants.dart';
import '../../services/api_services.dart';
import '../../models/complaint_type_model.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';
import 'complaint_location_screen.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class ImageWithLocation {
  final File imageFile;
  final double latitude;
  final double longitude;

  ImageWithLocation({
    required this.imageFile,
    required this.latitude,
    required this.longitude,
  });
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  // Form state
  List<ImageWithLocation> _uploadedImages = [];
  ComplaintType? _selectedComplaintType;
  final TextEditingController _descriptionController = TextEditingController();
  final int maxDescriptionLength = 100;

  List<ComplaintType> _complaintTypes = [];
  bool _isLoadingTypes = false;

  @override
  void initState() {
    super.initState();
    _loadComplaintTypes();
  }

  Future<void> _loadComplaintTypes() async {
    setState(() {
      _isLoadingTypes = true;
    });

    try {
      final types = await ApiService().getComplaintTypes();
      setState(() {
        _complaintTypes = types;
        _isLoadingTypes = false;
      });
    } catch (e) {
      print('❌ Error loading complaint types: $e');
      setState(() {
        _isLoadingTypes = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load complaint types'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    if (_uploadedImages.length >= 2) return;

    // Get camera permission
    final ImagePicker imagePicker = ImagePicker();

    try {
      // Pick image from camera
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return;

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _uploadedImages.add(
          ImageWithLocation(
            imageFile: File(photo.path),
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
      });

      print(
        '📸 Image captured at: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      print('❌ Error capturing image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/citizen-dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/citizen-dashboard');
            },
          ),
          title: Text(
            l10n.raiseComplaint,
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
                    // Upload Image Section
                    Text(
                      l10n.uploadImage,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 16.h,
                      children: [
                        // Uploaded images
                        ...List.generate(_uploadedImages.length, (index) {
                          return SizedBox(
                            width:
                                (MediaQuery.of(context).size.width -
                                    48.w -
                                    16.w) /
                                2,
                            height: 140.h,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8.r),
                                    image: DecorationImage(
                                      image: FileImage(
                                        _uploadedImages[index].imageFile,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      width: 24.w,
                                      height: 24.h,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Add Image Button
                        if (_uploadedImages.length < 2)
                          GestureDetector(
                            onTap: _addImage,
                            child: Container(
                              width:
                                  (MediaQuery.of(context).size.width -
                                      48.w -
                                      16.w) /
                                  2,
                              height: 140.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.greyColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Container(
                                  width: 28.w,
                                  height: 28.h,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Select Type of Complaint
                    Text(
                      l10n.selectTypeOfComplaint,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () {
                        if (!_isLoadingTypes && _complaintTypes.isNotEmpty) {
                          _showComplaintTypeBottomSheet();
                        }
                      },
                      child: Container(
                        height: 50.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.white,
                        ),
                        child: _isLoadingTypes
                            ? Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      _selectedComplaintType?.name ??
                                          l10n.selectOption,
                                      style: TextStyle(
                                        color: _selectedComplaintType != null
                                            ? Colors.black
                                            : Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Describe Complaint
                    Text(
                      l10n.describeComplaint,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: l10n.inputText,
                        counterText: '', // Hide the default counter
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
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 4.h),
                    // Character Counter
                    Text(
                      '${_descriptionController.text.length}/$maxDescriptionLength',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            // Fixed Button at Bottom
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
                  onPressed: () {
                    // Navigate to complaint location screen with form data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintLocationScreen(
                          uploadedImages: _uploadedImages,
                          selectedComplaintType: _selectedComplaintType,
                          description: _descriptionController.text,
                        ),
                      ),
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
                    l10n.nextAddLocation,
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
      ),
    );
  }

  void _showComplaintTypeBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    BottomSheetPicker.show<ComplaintType>(
      context: context,
      title: l10n.selectComplaintType,
      items: _complaintTypes,
      selectedItem: _selectedComplaintType,
      itemBuilder: (type) => type.name,
      showSearch: true,
      searchHint: l10n.searchComplaintTypes,
      onSelected: (type) {
        setState(() {
          _selectedComplaintType = type;
        });
      },
    );
  }
}
