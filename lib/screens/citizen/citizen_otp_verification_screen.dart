import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/connstants.dart';
import '../../services/auth_services.dart';
import '../../l10n/app_localizations.dart';

class CitizenOtpVerificationScreen extends StatefulWidget {
  final String mobileNumber;

  const CitizenOtpVerificationScreen({super.key, required this.mobileNumber});

  @override
  State<CitizenOtpVerificationScreen> createState() =>
      _CitizenOtpVerificationScreenState();
}

class _CitizenOtpVerificationScreenState
    extends State<CitizenOtpVerificationScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        if (_resendTimer > 0) {
          _startResendTimer();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await _authService.sendOtp(widget.mobileNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _canResend = false;
        _resendTimer = 60;
      });
      _startResendTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterCompleteOTP;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verifyOtp(widget.mobileNumber, otp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loginSuccessful),
            backgroundColor: AppColors.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
        // Clear navigation stack and go to raise complaint screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/create-complaint',
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // Lock Icon
              Image.asset('assets/icons/lock.png', height: 120.h, width: 120.w),
              SizedBox(height: 30.h),

              // Title
              Text(
                AppLocalizations.of(context)!.verifyOTP,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),

              // Subtitle
              Text(
                AppLocalizations.of(context)!.enterOtpSentTo,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30.h),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45.w,
                    height: 45.h,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) => _onChanged(value, index),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 0.h,
                        ),
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
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 24.h),

              // Resend Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.didntReceiveCode} ',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: _canResend ? _resendOtp : null,
                    child: Text(
                      AppLocalizations.of(context)!.resend,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _canResend
                            ? AppColors.primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Timer
              Center(
                child: Text(
                  _formatTimer(_resendTimer),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),

              SizedBox(height: 60.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
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
                          AppLocalizations.of(context)!.submit,
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
}
