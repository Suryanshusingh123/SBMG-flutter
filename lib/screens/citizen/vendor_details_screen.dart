import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';

class VendorDetailsScreen extends StatefulWidget {
  const VendorDetailsScreen({super.key});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  // Selected values
  District? selectedDistrict;
  Block? selectedBlock;
  Village? selectedVillage;

  // Data lists
  List<District> districts = [];
  List<Block> blocks = [];
  List<Village> villages = [];

  // Loading states
  bool isLoadingDistricts = true;
  bool isLoadingBlocks = false;
  bool isLoadingVillages = false;
  bool isLoadingContractor = false;

  // Contractor data
  Contractor? contractor;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      setState(() => isLoadingDistricts = true);
      final fetchedDistricts = await ApiService().getDistricts();
      setState(() {
        districts = fetchedDistricts;
        isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => isLoadingDistricts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load districts'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadBlocks(int districtId) async {
    try {
      setState(() {
        isLoadingBlocks = true;
        blocks = [];
        selectedBlock = null;
        villages = [];
        selectedVillage = null;
      });

      final fetchedBlocks = await ApiService().getBlocks(
        districtId: districtId,
      );
      setState(() {
        blocks = fetchedBlocks;
        isLoadingBlocks = false;
      });
    } catch (e) {
      setState(() => isLoadingBlocks = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load blocks'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadVillages(int blockId, int districtId) async {
    try {
      setState(() {
        isLoadingVillages = true;
        villages = [];
        selectedVillage = null;
      });

      final fetchedVillages = await ApiService().getVillages(
        blockId: blockId,
        districtId: districtId,
      );
      setState(() {
        villages = fetchedVillages;
        isLoadingVillages = false;
      });
    } catch (e) {
      setState(() => isLoadingVillages = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load villages'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadContractor(int villageId) async {
    try {
      setState(() => isLoadingContractor = true);

      final fetchedContractor = await ApiService().getContractorByVillageId(
        villageId,
      );
      setState(() {
        contractor = fetchedContractor;
        isLoadingContractor = false;
      });

      if (mounted) {
        _showVendorDetailsBottomSheet(context);
      }
    } catch (e) {
      setState(() => isLoadingContractor = false);

      // Extract user-friendly message from error
      String errorMessage = 'Failed to load contractor details';
      final errorString = e.toString();

      // Parse the error message from API response
      if (errorString.contains('"message":"')) {
        final messageStart = errorString.indexOf('"message":"') + 11;
        final messageEnd = errorString.indexOf('"', messageStart);
        if (messageEnd != -1) {
          errorMessage = errorString.substring(messageStart, messageEnd);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        ),
        title: const Text(
          'Know your areas vendor',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // District and Block Row
            Row(
              children: [
                // District Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'District',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isLoadingDistricts
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF009B56),
                                  ),
                                ),
                              )
                            : PopupMenuButton<District>(
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedDistrict?.name ??
                                              'Select District',
                                          style: TextStyle(
                                            color: selectedDistrict == null
                                                ? Colors.grey
                                                : Colors.black,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => districts.map((district) {
                                  return PopupMenuItem<District>(
                                    value: district,
                                    child: Text(district.name),
                                  );
                                }).toList(),
                                onSelected: (district) {
                                  setState(() {
                                    selectedDistrict = district;
                                    selectedBlock = null;
                                    selectedVillage = null;
                                    blocks = [];
                                    villages = [];
                                  });
                                  _loadBlocks(district.id);
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 16.w),

                // Block Dropdown
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Block',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: isLoadingBlocks
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF009B56),
                                  ),
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<Block>(
                                  value: selectedBlock,
                                  hint: const Text(
                                    'Select Block',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  menuMaxHeight: 300,
                                  alignment: AlignmentDirectional.bottomStart,
                                  items: blocks.map((block) {
                                    return DropdownMenuItem<Block>(
                                      value: block,
                                      child: Text(block.name),
                                    );
                                  }).toList(),
                                  onChanged: selectedDistrict == null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedBlock = value;
                                            selectedVillage = null;
                                            villages = [];
                                          });
                                          if (value != null &&
                                              selectedDistrict != null) {
                                            _loadVillages(
                                              value.id,
                                              selectedDistrict!.id,
                                            );
                                          }
                                        },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Gram Panchayat Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gram Panchayat',
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: isLoadingVillages
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF009B56),
                            ),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<Village>(
                            value: selectedVillage,
                            hint: const Text(
                              'Select Gram Panchayat',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            menuMaxHeight: 300,
                            alignment: AlignmentDirectional.bottomStart,
                            items: villages.map((village) {
                              return DropdownMenuItem<Village>(
                                value: village,
                                child: Text(village.name),
                              );
                            }).toList(),
                            onChanged: selectedBlock == null
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedVillage = value;
                                    });
                                  },
                          ),
                        ),
                ),
              ],
            ),

            const Spacer(),

            // Get Details Button
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: isLoadingContractor
                    ? null
                    : () {
                        if (selectedDistrict != null &&
                            selectedBlock != null &&
                            selectedVillage != null) {
                          _loadContractor(selectedVillage!.id);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select all fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: isLoadingContractor
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Get details',
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVendorDetailsBottomSheet(BuildContext context) {
    if (contractor == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vendor details',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF111827)),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Location Details
              _buildDetailRow('District', contractor!.districtName),
              SizedBox(height: 16.h),
              _buildDetailRow('Block', contractor!.blockName),
              SizedBox(height: 16.h),
              _buildDetailRow('Village', contractor!.villageName),
              SizedBox(height: 16.h),

              const Divider(height: 32),

              // Agency Details
              const Text(
                'Agency Information',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('Agency Name', contractor!.agency.name),
              SizedBox(height: 16.h),
              _buildDetailRow('Agency Phone', contractor!.agency.phone),
              SizedBox(height: 16.h),
              _buildDetailRow('Agency Email', contractor!.agency.email),
              SizedBox(height: 16.h),
              _buildDetailRow('Agency Address', contractor!.agency.address),
              SizedBox(height: 16.h),

              const Divider(height: 32),

              // Contractor Person Details
              const Text(
                'Contractor Details',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('Person Name', contractor!.personName),
              SizedBox(height: 16.h),
              _buildDetailRow('Person Phone', contractor!.personPhone),
              SizedBox(height: 16.h),

              const Divider(height: 32),

              // Contract Details
              const Text(
                'Contract Information',
                style: TextStyle(
                  fontFamily: 'Noto Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 16.h),
              _buildDetailRow('Start Date', contractor!.contractStartDate),
              SizedBox(height: 16.h),
              _buildDetailRow('End Date', contractor!.contractEndDate),

              SizedBox(height: 30.h),

              // Close Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009B56),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Noto Sans',
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

}
