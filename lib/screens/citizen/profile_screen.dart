import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Gender selection
  String? selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterYourName),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterMobileNumber),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectGender), backgroundColor: Colors.red),
      );
      return;
    }

    // TODO: Save profile data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.profileSavedSuccessfully),
        backgroundColor: const Color(0xFF009B56),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.profile,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Name field
            Text(
              l10n.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: l10n.name,
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Phone Number field
            Text(
              l10n.phoneNumber,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  // Country code section
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8.w),
                        Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF6B7280),
                          size: 16.sp,
                        ),
                      ],
                    ),
                  ),

                  // Phone input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        hintText: '00000 00000',
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Gender field
            Text(
              l10n.selectGender,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                BottomSheetPicker.show<String>(
                  context: context,
                  title: l10n.selectGender,
                  items: [l10n.genderMale, l10n.genderFemale, l10n.genderOther],
                  selectedItem: selectedGender,
                  itemBuilder: (gender) => gender,
                  onSelected: (gender) {
                    setState(() {
                      selectedGender = gender;
                    });
                  },
                );
              },
              child: Container(
                height: 50.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 24.sp,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        selectedGender ?? l10n.selectOption,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: selectedGender != null
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF6B7280),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),

      // Save Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.save,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
