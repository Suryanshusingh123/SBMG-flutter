import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateContractorDetailsScreen extends StatefulWidget {
  const UpdateContractorDetailsScreen({super.key});

  @override
  State<UpdateContractorDetailsScreen> createState() =>
      _UpdateContractorDetailsScreenState();
}

class _UpdateContractorDetailsScreenState
    extends State<UpdateContractorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _panchayatController = TextEditingController();
  final _durationController = TextEditingController();
  final _frequencyController = TextEditingController();

  // Dropdown values
  String? _selectedDuration;
  String? _selectedFrequency;

  // Duration options
  final List<String> _durationOptions = [
    '3 months',
    '6 months',
    '12 months',
    '18 months',
    '24 months',
  ];

  // Frequency options
  final List<String> _frequencyOptions = [
    'Daily',
    '2 times a day',
    '3 times a day',
    'Weekly',
    'Monthly',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing data (you can get this from API)
    _nameController.text = 'Nishant Singh';
    _panchayatController.text = '12 July 2025';
    _selectedDuration = '12 months';
    _selectedFrequency = '3 times a day';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _panchayatController.dispose();
    _durationController.dispose();
    _frequencyController.dispose();
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vendor details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Card
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Name Field
                          _buildFormField(
                            label: 'Name',
                            controller: _nameController,
                            placeholder: 'Enter contractor name.',
                          ),

                          SizedBox(height: 20.h),

                          // Panchayat/Work Order Date Field
                          _buildFormField(
                            label: 'Panchayat',
                            controller: _panchayatController,
                            placeholder: 'Work Order date.',
                            suffixIcon: Icons.calendar_today,
                            onTap: () =>
                                _selectDate(context, _panchayatController),
                          ),

                          SizedBox(height: 20.h),

                          // Duration Dropdown
                          _buildDropdownField(
                            label: 'Duration of work',
                            value: _selectedDuration,
                            placeholder: 'Select duration',
                            items: _durationOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedDuration = value;
                              });
                            },
                          ),

                          SizedBox(height: 20.h),

                          // Frequency Dropdown
                          _buildDropdownField(
                            label: 'Frequency',
                            value: _selectedFrequency,
                            placeholder: 'Select duration',
                            items: _frequencyOptions,
                            onChanged: (value) {
                              setState(() {
                                _selectedFrequency = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveContractorDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          onTap: onTap,
          readOnly: onTap != null,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey.shade600, size: 20.sp)
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required String placeholder,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
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
              borderSide: const BorderSide(color: Color(0xFF009B56)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a value';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void _saveContractorDetails() {
    if (_formKey.currentState!.validate()) {
      // Handle saving contractor details
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contractor details updated successfully!'),
          backgroundColor: Color(0xFF009B56),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }
}
