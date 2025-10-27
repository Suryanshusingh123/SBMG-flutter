import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sbmg/services/auth_services.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // UI State
  bool _isAuthorityLogin = false;
  bool _isLoading = false;
  bool _otpSent = false;

  // Controllers
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  // Error message
  String? _errorMessage;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleAuthorityLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // try {
    //   final response = await _authService.authorityLogin(
    //     userId: _userIdController.text.trim(),
    //     password: _passwordController.text,
    //   );

    //   if (response.success) {
    //     _showSuccess('Login successful!');
    //     // Navigate based on user role
    //     _navigateToDashboard(response.data!.user.role);
    //   } else {
    //     _showError(response.message ?? 'Login failed');
    //   }
    // } catch (e) {
    //   _showError('An error occurred: $e');
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  Future<void> _handlePublicLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // try {
    //   if (!_otpSent) {
    //     // Send OTP
    //     final response = await _authService.sendOtp(
    //       mobileNumber: _mobileController.text.trim(),
    //     );

    //     if (response.success) {
    //       setState(() {
    //         _otpSent = true;
    //       });
    //       _showSuccess('OTP sent to your mobile number');
    //     } else {
    //       _showError(response.message ?? 'Failed to send OTP');
    //     }
    //   } else {
    //     // Verify OTP
    //     final response = await _authService.verifyOtp(
    //       mobileNumber: _mobileController.text.trim(),
    //       otp: _otpController.text.trim(),
    //     );

    //     if (response.success) {
    //       _showSuccess('Login successful!');
    //       _navigateToDashboard(response.data!.user.role);
    //     } else {
    //       _showError(response.message ?? 'OTP verification failed');
    //     }
    //   }
    // } catch (e) {
    //   _showError('An error occurred: $e');
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }

  void _navigateToDashboard(String role) {
    // For now, navigate to citizen dashboard
    // You can implement role-based navigation later
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CitizenHomeScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Login',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),

                // App Logo/Title
                const Text(
                  'Rajasthan Government',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Smart City Management System',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),

                // Login Type Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAuthorityLogin = false;
                              _otpSent = false;
                              _errorMessage = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: _isAuthorityLogin
                                  ? Colors.transparent
                                  : const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Citizen',
                              style: TextStyle(
                                color: _isAuthorityLogin
                                    ? Colors.grey.shade600
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAuthorityLogin = true;
                              _otpSent = false;
                              _errorMessage = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: _isAuthorityLogin
                                  ? const Color(0xFF4CAF50)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Authority',
                              style: TextStyle(
                                color: _isAuthorityLogin
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                // Login Form
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isAuthorityLogin) ...[
                        // Authority Login Fields
                        TextFormField(
                          controller: _userIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your User ID';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        // Public User Login Fields
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            hintText: '+91 9876543210',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid mobile number';
                            }
                            return null;
                          },
                        ),
                        if (_otpSent) ...[
                          SizedBox(height: 16.h),
                          TextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'OTP',
                              prefixIcon: Icon(Icons.security),
                              border: OutlineInputBorder(),
                              hintText: 'Enter 6-digit OTP',
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
                        ],
                      ],
                      SizedBox(height: 24.h),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(12.r),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : _isAuthorityLogin
                            ? _handleAuthorityLogin
                            : _handlePublicLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
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
                                _isAuthorityLogin
                                    ? 'Login'
                                    : _otpSent
                                    ? 'Verify OTP'
                                    : 'Send OTP',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),

                      // Quick Login Button for Testing
                      if (!_isAuthorityLogin && !_otpSent)
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                  });

                                  // try {
                                  //   final response = await _authService
                                  //       .quickLogin(
                                  //         mobileNumber: _mobileController.text
                                  //             .trim(),
                                  //       );

                                  //   if (response.success) {
                                  //     _showSuccess('Quick login successful!');
                                  //     _navigateToDashboard(
                                  //       response.data!.user.role,
                                  //     );
                                  //   } else {
                                  //     _showError(
                                  //       response.message ??
                                  //           'Quick login failed',
                                  //     );
                                  //   }
                                  // } catch (e) {
                                  //   _showError('An error occurred: $e');
                                  // } finally {
                                  //   setState(() {
                                  //     _isLoading = false;
                                  //   });
                                  // }
                                },
                          child: const Text(
                            'Quick Login (Test with 123456)',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
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
