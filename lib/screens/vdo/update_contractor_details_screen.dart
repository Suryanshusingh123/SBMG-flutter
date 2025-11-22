import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/contractor_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import 'package:intl/intl.dart';

class UpdateContractorDetailsScreen extends StatefulWidget {
  final ContractorDetails? contractorDetails;

  const UpdateContractorDetailsScreen({super.key, this.contractorDetails});

  @override
  State<UpdateContractorDetailsScreen> createState() =>
      _UpdateContractorDetailsScreenState();
}

class _UpdateContractorDetailsScreenState
    extends State<UpdateContractorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _workOrderDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Dropdown values
  String? _selectedDuration;
  String? _selectedFrequency;

  // Date values
  DateTime? _startDate;
  DateTime? _endDate;

  // Loading state
  bool _isLoading = false;

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
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.contractorDetails != null) {
      final details = widget.contractorDetails!;
      _nameController.text = details.personName;

      // Parse and set dates
      try {
        _startDate = DateTime.parse(details.contractStartDate);
        _workOrderDateController.text = _formatDateForDisplay(_startDate!);

        if (details.contractEndDate != null) {
          _endDate = DateTime.parse(details.contractEndDate!);
          _endDateController.text = _formatDateForDisplay(_endDate!);
        }
      } catch (e) {
        print('Error parsing dates: $e');
      }

      // Set duration based on dates
      if (_startDate != null && _endDate != null) {
        final duration = _endDate!.difference(_startDate!);
        final months = (duration.inDays / 30).round();
        // Only set if it matches one of the predefined options
        final calculatedDuration = '$months months';
        if (_durationOptions.contains(calculatedDuration)) {
          _selectedDuration = calculatedDuration;
        } else {
          // Find closest match or set to null
          _selectedDuration = _findClosestDurationOption(months);
        }
      }

      // Set frequency from model (only if it matches predefined options)
      if (_frequencyOptions.contains(details.workFrequency)) {
        _selectedFrequency = details.workFrequency;
      } else {
        // Default to first option if not found
        _selectedFrequency = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workOrderDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Vendor details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans',
          ),
        ),
        centerTitle: false,
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

                          // Work Order Date Field (Start Date)
                          _buildFormField(
                            label: 'Panchayat',
                            controller: _workOrderDateController,
                            placeholder: 'Work Order date',
                            suffixIcon: Icons.calendar_today,
                            onTap: () => _selectStartDate(context),
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
                                // Calculate end date based on duration
                                if (_startDate != null && value != null) {
                                  final months = int.tryParse(
                                    value.replaceAll(' months', ''),
                                  );
                                  if (months != null) {
                                    _endDate = DateTime(
                                      _startDate!.year,
                                      _startDate!.month + months,
                                      _startDate!.day,
                                    );
                                    _endDateController.text =
                                        _formatDateForDisplay(_endDate!);
                                  }
                                }
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
                  onPressed: _isLoading ? null : _saveContractorDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Noto Sans',
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
          initialValue: value,
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _workOrderDateController.text = _formatDateForDisplay(picked);

        // Recalculate end date if duration is selected
        if (_selectedDuration != null) {
          final months = int.tryParse(
            _selectedDuration!.replaceAll(' months', ''),
          );
          if (months != null) {
            _endDate = DateTime(picked.year, picked.month + months, picked.day);
            _endDateController.text = _formatDateForDisplay(_endDate!);
          }
        }
      });
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String? _findClosestDurationOption(int months) {
    // Find the closest predefined duration option
    final availableMonths = [3, 6, 12, 18, 24];
    int? closest;
    int minDiff = 999;

    for (final available in availableMonths) {
      final diff = (months - available).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = available;
      }
    }

    return closest != null ? '$closest months' : null;
  }

  Future<void> _saveContractorDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.contractorDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contractor details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select work order date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duration'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate end date if not set
    if (_endDate == null && _startDate != null && _selectedDuration != null) {
      final months = int.tryParse(_selectedDuration!.replaceAll(' months', ''));
      if (months != null) {
        _endDate = DateTime(
          _startDate!.year,
          _startDate!.month + months,
          _startDate!.day,
        );
      }
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select duration to calculate end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final details = widget.contractorDetails!;
      final authService = AuthService();
      final villageId = await authService.getVillageId();
      final gpId = villageId;

      if (gpId == null) {
        throw Exception('Invalid GP/Village ID');
      }

      // Update contractor details
      final updatedContractor = await ApiService().updateContractor(
        contractorId: details.id,
        agencyId: details.agency.id,
        personName: _nameController.text.trim(),
        personPhone: details.personPhone, // Keep existing phone
        gpId: gpId,
        contractStartDate: _formatDateForApi(_startDate!),
        contractEndDate: _formatDateForApi(_endDate!),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contractor details updated successfully!'),
            backgroundColor: Color(0xFF009B56),
          ),
        );

        // Navigate back
        Navigator.pop(context, updatedContractor);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating contractor details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
