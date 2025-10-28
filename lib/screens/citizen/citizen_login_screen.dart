import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sbmg/services/auth_services.dart';
import '../../config/connstants.dart';
import '../../l10n/app_localizations.dart';
import 'citizen_otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // UI State
  bool _isLoading = false;
  bool _otpSent = false;

  // Controllers
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  // Error message
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handlePublicLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Send OTP
      final message = await _authService.sendOtp(_mobileController.text.trim());
      _showSuccess(message);

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CitizenOtpVerificationScreen(
            mobileNumber: _mobileController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                // Lock Icon
                Image.asset(
                  'assets/icons/lock.png',
                  height: 120.h,
                  width: 120.w,
                ),
                SizedBox(height: 30.h),

                // Title
                Text(
                  l10n.login,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                // Subtitle
                Text(
                  l10n.enterYourPhoneNumber,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 40.h),

                // Phone Number Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (value) {
                        setState(
                          () {},
                        ); // Trigger rebuild to update button state
                      },
                      decoration: InputDecoration(
                        hintText: l10n.enterMobileNumberPlaceholder,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: _errorMessage != null
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 12.w),
                            const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8.w),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black87,
                              size: 20,
                            ),
                            SizedBox(width: 4.w),
                            const Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                          return '';
                        }
                        if (value.length != 10) {
                          return '';
                            }
                            return null;
                          },
                        ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),

                if (_otpSent) ...[
                  SizedBox(height: 24.h),
                  // OTP Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                              hintText: 'Enter 6-digit OTP',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _errorMessage != null
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          prefixIcon: const Icon(
                            Icons.security,
                            color: Colors.grey,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              _errorMessage = 'Please enter the OTP';
                            });
                            return 'Please enter the OTP';
                          }
                          if (value.length != 6) {
                            setState(() {
                              _errorMessage = 'OTP must be 6 digits';
                            });
                            return 'OTP must be 6 digits';
                          }
                          setState(() => _errorMessage = null);
                          return null;
                        },
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 40.h),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading || _mobileController.text.length != 10)
                            ? null
                            : _handlePublicLogin,
                        style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                          ),
                      elevation: 0,
                        ),
                        child: _isLoading
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
                            _otpSent ? l10n.verifyOTP : l10n.sentOTP,
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
      ),
    );
  }
}
