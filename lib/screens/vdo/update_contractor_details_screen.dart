import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/contractor_model.dart';
import '../../services/api_services.dart';
import '../../services/auth_services.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/loading_dropdown_field.dart';
import '../../widgets/common/bottom_sheet_picker.dart';

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
  final _workOrderAmountController = TextEditingController();
  final _endDateController = TextEditingController();

  // Dropdown values
  String? _selectedDuration;
  String? _selectedFrequency;
  Agency? _selectedAgency;

  // Agency data
  List<Agency> _agencies = [];
  bool _isLoadingAgencies = false;

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
    'DAILY',
    'WEEKLY',
    'ONCE_IN_THREE_DAYS',
    'MONTHLY',
  ];

  String _getFrequencyLabel(String value) {
    switch (value) {
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        return 'Weekly';
      case 'ONCE_IN_THREE_DAYS':
        return 'Once in 3 days';
      case 'MONTHLY':
        return 'Monthly';
      default:
        return value;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAgencies();
    _loadExistingData();
  }

  Future<void> _loadAgencies() async {
    setState(() {
      _isLoadingAgencies = true;
    });

    try {
      final agencies = await ApiService().getAgencies(limit: 1000);
      // Sort alphabetically
      agencies.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      setState(() {
        _agencies = agencies;
        _isLoadingAgencies = false;

        // If we have existing data, try to match the agency
        if (widget.contractorDetails != null && _selectedAgency == null) {
          try {
            _selectedAgency = _agencies.firstWhere(
              (a) => a.id == widget.contractorDetails!.agency.id,
            );
          } catch (_) {
            // Agency not in the list, maybe add it or just use the one from details
            _selectedAgency = widget.contractorDetails!.agency;
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAgencies = false;
      });
      print('Error loading agencies: $e');
    }
  }

  Future<void> _showAddAgencyDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Add New Agency',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Agency Name*',
                    hintText: 'Enter agency name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 10) {
                      return 'Enter 10 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': emailController.text.trim(),
                  'address': addressController.text.trim(),
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF009B56),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result['name']!.isNotEmpty) {
      setState(() => _isLoadingAgencies = true);
      try {
        final newAgency = await ApiService().createAgency(
          name: result['name']!,
          phone: result['phone']!.isNotEmpty ? result['phone'] : null,
          email: result['email']!.isNotEmpty ? result['email'] : null,
          address: result['address']!.isNotEmpty ? result['address'] : null,
        );
        await _loadAgencies(); // Reload and sort
        setState(() {
          // Robust selection: either find in the refreshed list or use the new one directly
          try {
            _selectedAgency = _agencies.firstWhere((a) => a.id == newAgency.id);
          } catch (_) {
            _selectedAgency = newAgency;
            // Also add to the list if missing (e.g. pagination limit reached)
            if (!_agencies.any((a) => a.id == newAgency.id)) {
              _agencies.add(newAgency);
              _agencies.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
            }
          }
        });
      } catch (e) {
        setState(() => _isLoadingAgencies = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add agency: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showFullAgencyPicker() {
    BottomSheetPicker.show<Agency>(
      context: context,
      title: 'Select Agency',
      items: _agencies,
      itemBuilder: (agency) => agency.name,
      selectedItem: _selectedAgency,
      showSearch: true,
      onAdd: () async {
        await _showAddAgencyDialog();
        if (mounted && _selectedAgency != null) {
          Navigator.pop(context); // Close the picker
        }
      },
      onSelected: (agency) {
        setState(() {
          _selectedAgency = agency;
        });
      },
    );
  }

  void _loadExistingData() {
    if (widget.contractorDetails != null) {
      final details = widget.contractorDetails!;
      _nameController.text = details.personName;
      _workOrderAmountController.text = details.workOrderAmount.toString();

      // Set frequency from model (API accepts DAILY, ONCE_IN_THREE_DAYS, WEEKLY, MONTHLY only)
      final freq = details.cleaningFrequency.toUpperCase();
      if (_frequencyOptions.contains(freq)) {
        _selectedFrequency = freq;
      } else {
        final workFreq = details.workFrequency.toUpperCase();
        _selectedFrequency = _frequencyOptions.contains(workFreq)
            ? workFreq
            : null;
      }
      // FORTNIGHTLY not accepted by backend; do not pre-select

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
    }
  }

  Widget _buildAdvancedAgencySelector() {
    if (_isLoadingAgencies) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agency',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF009B56),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Top 6 agencies sorted alphabetically
    final List<Agency> quickAgencies = _agencies.take(6).toList();

    // Create menu items
    final List<DropdownMenuItem<String>> menuItems = [];

    for (final agency in quickAgencies) {
      menuItems.add(
        DropdownMenuItem(
          value: agency.id.toString(),
          child: Text(
            agency.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    // Add currently selected if not in top 6
    if (_selectedAgency != null &&
        !quickAgencies.any((a) => a.id == _selectedAgency!.id)) {
      menuItems.add(
        DropdownMenuItem(
          value: _selectedAgency!.id.toString(),
          child: Text(
            _selectedAgency!.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      );
    }

    // Add "Other..."
    menuItems.add(
      DropdownMenuItem(
        value: 'OTHER',
        child: Text(
          'Other...',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF009B56),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agency',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
            GestureDetector(
              onTap: _showAddAgencyDialog,
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16.sp,
                    color: const Color(0xFF009B56),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Add New',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF009B56),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedAgency?.id.toString(),
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Select Agency',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 12.h,
            ),
          ),
          items: menuItems,
          onChanged: (value) {
            if (value == 'OTHER') {
              _showFullAgencyPicker();
            } else if (value != null) {
              setState(() {
                _selectedAgency = _agencies.firstWhere(
                  (a) => a.id.toString() == value,
                );
              });
            }
          },
          validator: (value) {
            if (_selectedAgency == null) {
              return 'Please select an agency';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _workOrderDateController.dispose();
    _workOrderAmountController.dispose();
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
          'Contractor details',
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
                          // Agency Dropdown (Advanced Selector)
                          _buildAdvancedAgencySelector(),

                          SizedBox(height: 20.h),

                          // Name Field
                          _buildFormField(
                            label: 'Name',
                            controller: _nameController,
                            placeholder: 'Enter contractor name.',
                          ),

                          SizedBox(height: 20.h),

                          // Work Order Date Field (Start Date)
                          _buildFormField(
                            label: 'Work order date',
                            controller: _workOrderDateController,
                            placeholder: 'Work Order date',
                            suffixIcon: Icons.calendar_today,
                            onTap: () => _selectStartDate(context),
                          ),

                          SizedBox(height: 20.h),

                          // Work Order Amount
                          _buildFormField(
                            label: 'Work order amount',
                            controller: _workOrderAmountController,
                            placeholder: 'Enter amount',
                            suffixIcon: Icons.currency_rupee,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                if (newValue.text.isEmpty) return newValue;
                                if (newValue.text.split('.').length - 1 > 1) {
                                  return oldValue;
                                }
                                return newValue;
                              }),
                            ],
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
                            placeholder: 'Select frequency',
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
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
          validator:
              validator ??
              (value) {
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
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
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
              child: Text(_getFrequencyLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Required' : null,
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

    if (_selectedAgency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an agency'),
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
        agencyId: _selectedAgency!.id,
        personName: _nameController.text.trim(),
        personPhone: details.personPhone, // Keep existing phone
        gpId: gpId,
        contractStartDate: _formatDateForApi(_startDate!),
        contractEndDate: _formatDateForApi(_endDate!),
        workOrderAmount:
            double.tryParse(_workOrderAmountController.text) ?? 0.0,
        cleaningFrequency: _selectedFrequency ?? 'DAILY',
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
