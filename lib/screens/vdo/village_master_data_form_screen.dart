import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VillageMasterDataFormScreen extends StatefulWidget {
  const VillageMasterDataFormScreen({super.key});

  @override
  State<VillageMasterDataFormScreen> createState() =>
      _VillageMasterDataFormScreenState();
}

class _VillageMasterDataFormScreenState
    extends State<VillageMasterDataFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _vdoNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _sarpanchNameController = TextEditingController();
  final _sarpanchContactController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _workOrderNoController = TextEditingController();
  final _workOrderDateController = TextEditingController();
  final _workOrderAmountController = TextEditingController();
  final _fundAmountController = TextEditingController();
  final _fundHeadController = TextEditingController();
  final _householdsController = TextEditingController();
  final _shopsController = TextEditingController();

  // Expansion states
  bool _sarpanchExpanded = false;
  bool _contractorExpanded = false;
  bool _workOrderExpanded = false;
  bool _fundExpanded = false;
  bool _collectionExpanded = false;

  @override
  void dispose() {
    _vdoNameController.dispose();
    _contactNumberController.dispose();
    _sarpanchNameController.dispose();
    _sarpanchContactController.dispose();
    _contractorNameController.dispose();
    _workOrderNoController.dispose();
    _workOrderDateController.dispose();
    _workOrderAmountController.dispose();
    _fundAmountController.dispose();
    _fundHeadController.dispose();
    _householdsController.dispose();
    _shopsController.dispose();
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
        title: const Text(
          'Village Master data Form',
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
                    // VDO Name
                    _buildFormField(
                      label: 'VOD Name',
                      controller: _vdoNameController,
                      placeholder: 'VDO Name',
                    ),

                    SizedBox(height: 20.h),

                    // Contact Number
                    _buildFormField(
                      label: 'Contact Number',
                      controller: _contactNumberController,
                      placeholder: 'Contact Number',
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 20.h),

                    // Sarpanch details (Expandable)
                    _buildExpandableSection(
                      title: 'Sarpanch details',
                      isExpanded: _sarpanchExpanded,
                      onToggle: () => setState(
                        () => _sarpanchExpanded = !_sarpanchExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Name',
                          controller: _sarpanchNameController,
                          placeholder: 'Name',
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Contact Number',
                          controller: _sarpanchContactController,
                          placeholder: 'Number',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Contractor details (Expandable)
                    _buildExpandableSection(
                      title: 'Contractor details',
                      isExpanded: _contractorExpanded,
                      onToggle: () => setState(
                        () => _contractorExpanded = !_contractorExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Name',
                          controller: _contractorNameController,
                          placeholder: 'Name',
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Work order details (Expandable)
                    _buildExpandableSection(
                      title: 'Work order details',
                      isExpanded: _workOrderExpanded,
                      onToggle: () => setState(
                        () => _workOrderExpanded = !_workOrderExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'Work order no',
                          controller: _workOrderNoController,
                          placeholder: 'No.',
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Date',
                          controller: _workOrderDateController,
                          placeholder: 'Date',
                          onTap: () =>
                              _selectDate(context, _workOrderDateController),
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Amount',
                          controller: _workOrderAmountController,
                          placeholder: 'amount',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Fund Sanctioned (Expandable)
                    _buildExpandableSection(
                      title: 'Fund Sanctioned',
                      isExpanded: _fundExpanded,
                      onToggle: () =>
                          setState(() => _fundExpanded = !_fundExpanded),
                      children: [
                        _buildFormField(
                          label: 'Amount',
                          controller: _fundAmountController,
                          placeholder: 'amount',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'Head',
                          controller: _fundHeadController,
                          placeholder: 'Head',
                          suffixIcon: Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Door to door collection details (Expandable)
                    _buildExpandableSection(
                      title: 'Door to door collection details',
                      isExpanded: _collectionExpanded,
                      onToggle: () => setState(
                        () => _collectionExpanded = !_collectionExpanded,
                      ),
                      children: [
                        _buildFormField(
                          label: 'No. of households',
                          controller: _householdsController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16.h),
                        _buildFormField(
                          label: 'No. of shops',
                          controller: _shopsController,
                          placeholder: 'No',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),

            // Submit Button
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
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
    TextInputType? keyboardType,
    VoidCallback? onTap,
    IconData? suffixIcon,
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
          keyboardType: keyboardType,
          onTap: onTap,
          readOnly: onTap != null,
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
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey.shade600, size: 20)
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

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
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
      controller.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Color(0xFF009B56),
        ),
      );

      // Get current date for completion
      final now = DateTime.now();
      final completionDate = '${now.day}/${now.month}/${now.year}';

      // Navigate back with completion date
      Navigator.pop(context, completionDate);
    }
  }
}
