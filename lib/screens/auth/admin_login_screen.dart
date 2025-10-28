import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/auth_services.dart';
import 'reset_password_request_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService().adminLogin(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (response['success'] == true) {
        // Get current user information to determine role
        final userResponse = await AuthService().getCurrentUser();

        if (userResponse['success'] == true) {
          final user = userResponse['user'];
          final role = user['role']?.toLowerCase();
          _navigateToDashboard(role);
        } else {
          setState(() {
            _errorMessage =
                userResponse['message'] ?? 'Failed to get user information';
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Login failed';
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

  Future<void> _navigateToDashboard(String? role) async {
    switch (role) {
      case 'worker': // WORKER role maps to supervisor
        Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
        break;
      case 'supervisor':
        Navigator.pushReplacementNamed(context, '/supervisor-dashboard');
        break;
      case 'bdo':
        Navigator.pushReplacementNamed(context, '/bdo-dashboard');
        break;
      case 'admin': // ADMIN role maps to SMD
        // Check if SMD has selected a district
        final hasDistrict = await AuthService().hasSmdSelectedDistrict();
        if (hasDistrict) {
          Navigator.pushReplacementNamed(context, '/smd-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/smd-district-selection');
        }
        break;
      case 'vdo':
        Navigator.pushReplacementNamed(context, '/vdo-dashboard');
        break;
      case 'ceo':
        Navigator.pushReplacementNamed(context, '/ceo-dashboard');
        break;
      case 'smd':
        Navigator.pushReplacementNamed(context, '/smd-dashboard');
        break;
      case 'contractor':
        Navigator.pushReplacementNamed(context, '/contractor-dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Title
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  'Enter User ID and Password',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                SizedBox(height: 40.h),

                // Username Field
                Text(
                  'User ID',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'User ID',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color(0xFF6B7280),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFF009B56)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your User ID';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Password Field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: _errorMessage != null
                          ? Colors.red
                          : const Color(0xFF6B7280),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF6B7280),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
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
                      return 'Please enter your password';
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

                SizedBox(height: 16.h),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ResetPasswordRequestScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: const Color(0xFF009B56),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Login',
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
