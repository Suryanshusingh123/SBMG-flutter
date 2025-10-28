import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/auth_services.dart';

class ResetPasswordVerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const ResetPasswordVerifyScreen({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordVerifyScreen> createState() =>
      _ResetPasswordVerifyScreenState();
}

class _ResetPasswordVerifyScreenState extends State<ResetPasswordVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService().verifyPasswordResetOtp(
        phoneNumber: widget.phoneNumber,
        otp: _otpController.text.trim(),
      );

      if (response['success'] == true) {
        // TODO: Navigate to set new password screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP verified! Please set your new password.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Invalid OTP';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),

                // Lock Icon
                Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009B56).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security,
                    size: 60.sp,
                    color: const Color(0xFF009B56),
                  ),
                ),

                SizedBox(height: 20.h),

                // OTP Visual
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pin,
                        size: 20.sp,
                        color: const Color(0xFF009B56),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'OTP',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF009B56),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // Title
                Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Enter the OTP sent to ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                SizedBox(height: 40.h),

                // OTP Field
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '000000',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: _errorMessage != null
                            ? Colors.red
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: _errorMessage != null
                            ? Colors.red
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF009B56)),
                    ),
                    filled: true,
                    fillColor: _errorMessage != null
                        ? Colors.red.shade50
                        : Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),

                // Error Message
                if (_errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                // Verify OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009B56),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
