import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/connstants.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    // Get current language from provider
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    _selectedLanguage = localeProvider.locale.languageCode;
  }

  void _saveLanguage() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_selectedLanguage == 'en') {
      localeProvider.setLocale(const Locale('en'));
    } else if (_selectedLanguage == 'hi') {
      localeProvider.setLocale(const Locale('hi'));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.languageSavedSuccessfully),
        backgroundColor: const Color(0xFF009B56),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildLanguageOption(String language, String code) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1FAE5) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : const Color(0xFF9CA3AF),
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            Text(
              language,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
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
          l10n.language,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // English option
            _buildLanguageOption(l10n.english, 'en'),

            // Hindi option
            _buildLanguageOption(l10n.hindi, 'hi'),

            SizedBox(height: 24.h),
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
            onPressed: _saveLanguage,
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
