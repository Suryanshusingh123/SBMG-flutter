import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class ResetPasswordFlowScreen extends StatefulWidget {
  const ResetPasswordFlowScreen({super.key});

  @override
  State<ResetPasswordFlowScreen> createState() =>
      _ResetPasswordFlowScreenState();
}

class _ResetPasswordFlowScreenState extends State<ResetPasswordFlowScreen> {
  int _currentStep = 0; // 0: Phone, 1: OTP, 2: New Password
  final PageController _pageController = PageController();

  // Phone step
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;

  // OTP step
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _canResend = false;
  int _resendTimer = 0;

  // Password step
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _canResend = false;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendTimer--;
          if (_resendTimer <= 0) {
            _canResend = true;
          } else {
            _startResendTimer();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _getTitle(),
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        children: [_buildPhoneStep(), _buildOtpStep(), _buildPasswordStep()],
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case 0:
        return 'Reset Password';
      case 1:
        return 'Reset Password';
      case 2:
        return 'Set Password';
      default:
        return 'Reset Password';
    }
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),

          // Lock icon
          _buildLockIcon(),

          SizedBox(height: 24.h),

          // Title
          Text(
            'Reset Password',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'Enter your phone number',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: 40.h),

          // Phone number input
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Number',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _phoneError != null
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Country code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/india_flag.png', // You'll need to add this asset
                            width: 20,
                            height: 15,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  '🇮🇳',
                                  style: TextStyle(fontSize: 22.sp),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
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
                        decoration: InputDecoration(
                          hintText: '00000 00000',
                          hintStyle: TextStyle(
                            fontFamily: 'Noto Sans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111827),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _phoneError = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (_phoneError != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: const Color(0xFFEF4444),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _phoneError!,
                      style: TextStyle(
                        fontFamily: 'Noto Sans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const Spacer(),

          // Send OTP button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Send OTP',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),

          // Lock icon
          _buildLockIcon(),

          SizedBox(height: 24.h),

          // Title
          Text(
            'Reset Password',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'Enter the 6-digit verification code sent to mobile number',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: 40.h),

          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 45,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '0',
                    hintStyle: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF009B56)),
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),

          SizedBox(height: 24.h),

          // Resend option
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Didn\'t receive the code? ',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              GestureDetector(
                onTap: _canResend ? _resendOtp : null,
                child: Text(
                  'Resend',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: _canResend
                        ? const Color(0xFF009B56)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Timer
          Text(
            _canResend
                ? '00:00'
                : '00:${_resendTimer.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),

          const Spacer(),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),

          // Lock icon
          _buildLockIcon(),

          SizedBox(height: 24.h),

          // Title
          Text(
            'Set Password',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'Enter new password',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),

          SizedBox(height: 40.h),

          // New password input
          _buildPasswordField(
            label: 'Enter new password',
            controller: _newPasswordController,
            isVisible: _isNewPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              });
            },
          ),

          SizedBox(height: 20.h),

          // Confirm password input
          _buildPasswordField(
            label: 'Confirm password',
            controller: _confirmPasswordController,
            isVisible: _isConfirmPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),

          // Error message
          if (_passwordError != null) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFEF4444),
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  _passwordError!,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],

          const Spacer(),

          // Set password button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _setNewPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009B56),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Set new password',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockIcon() {
    return Image.asset(
      'assets/icons/lock.png',
      width: 180,
      height: 180,
      fit: BoxFit.contain,
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: const Color(0xFF6B7280),
                size: 20.sp,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF6B7280),
                  size: 20.sp,
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  void _sendOtp() {
    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Phone number is required';
      });
      return;
    }

    if (_phoneController.text.length < 10) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
      return;
    }

    // Move to OTP step
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _resendOtp() {
    _startResendTimer();
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully'),
        backgroundColor: Color(0xFF009B56),
      ),
    );
  }

  void _verifyOtp() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Move to password step
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _setNewPassword() {
    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _passwordError = 'New password is required';
      });
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Please confirm your password';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match';
      });
      return;
    }

    if (_newPasswordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      return;
    }

    // Success
    setState(() {
      _passwordError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully'),
        backgroundColor: Color(0xFF009B56),
      ),
    );

    Navigator.pop(context);
  }
}
