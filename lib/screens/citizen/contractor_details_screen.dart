import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../utils/api_error_utils.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/citizen_colors.dart';

class ContractorDetailsScreen extends StatefulWidget {
  const ContractorDetailsScreen({super.key});

  @override
  State<ContractorDetailsScreen> createState() => _ContractorDetailsScreenState();
}

class _ContractorDetailsScreenState extends State<ContractorDetailsScreen> {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
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
        _showContractorDetailsBottomSheet(context);
      }
    } catch (e) {
      setState(() {
        isLoadingContractor = false;
        contractor = null;
      });

      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(userFriendlyApiMessage(e)),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      _showNoDataBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    final secondaryTextColor = CitizenColors.textSecondary(context);
    return Scaffold(
      backgroundColor: CitizenColors.background(context),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
        ),
        title: Text(
          l10n.knowYourAreasContractor,
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
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
                      Text(
                        l10n.district,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
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
                            : GestureDetector(
                                onTap: () {
                                  BottomSheetPicker.show<District>(
                                    context: context,
                                    title: l10n.selectDistrict,
                                    items: districts,
                                    selectedItem: selectedDistrict,
                                    itemBuilder: (district) => district.name,
                                    showSearch: true,
                                    searchHint: l10n.searchDistricts,
                                    isLoading: isLoadingDistricts,
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
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedDistrict?.name ??
                                            l10n.selectDistrict,
                                        style: TextStyle(
                                          color: selectedDistrict == null
                                              ? secondaryTextColor
                                              : primaryTextColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: secondaryTextColor,
                                    ),
                                  ],
                                ),
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
                      Text(
                        l10n.block,
                        style: TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: surfaceColor,
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
                            : GestureDetector(
                                onTap: selectedDistrict == null
                                    ? null
                                    : () {
                                        BottomSheetPicker.show<Block>(
                                          context: context,
                                          title: l10n.selectBlock,
                                          items: blocks,
                                          selectedItem: selectedBlock,
                                          itemBuilder: (block) => block.name,
                                          showSearch: true,
                                          searchHint: l10n.searchBlocks,
                                          isLoading: isLoadingBlocks,
                                          onSelected: (block) {
                                            setState(() {
                                              selectedBlock = block;
                                              selectedVillage = null;
                                              villages = [];
                                            });
                                            if (selectedDistrict != null) {
                                              _loadVillages(
                                                block.id,
                                                selectedDistrict!.id,
                                              );
                                            }
                                          },
                                        );
                                      },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedBlock?.name ?? l10n.selectBlock,
                                        style: TextStyle(
                                          color: selectedBlock == null
                                              ? secondaryTextColor
                                              : primaryTextColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: secondaryTextColor,
                                    ),
                                  ],
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
                Text(
                  l10n.gramPanchayat,
                  style: TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: primaryTextColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
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
                      : GestureDetector(
                          onTap: selectedBlock == null
                              ? null
                              : () {
                                  BottomSheetPicker.show<Village>(
                                    context: context,
                                    title: l10n.selectGramPanchayat,
                                    items: villages,
                                    selectedItem: selectedVillage,
                                    itemBuilder: (village) => village.name,
                                    showSearch: true,
                                    searchHint: l10n.searchVillages,
                                    isLoading: isLoadingVillages,
                                    onSelected: (village) {
                                      setState(() {
                                        selectedVillage = village;
                                      });
                                    },
                                  );
                                },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  selectedVillage?.name ??
                                      l10n.selectGramPanchayat,
                                  style: TextStyle(
                                    color: selectedVillage == null
                                        ? secondaryTextColor
                                        : primaryTextColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: secondaryTextColor,
                              ),
                            ],
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
                            SnackBar(
                              content: Text(
                                l10n.pleaseSelectAllFieldsForMasterData,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  foregroundColor: CitizenColors.light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: isLoadingContractor
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CitizenColors.light,
                        ),
                      )
                    : Text(
                        l10n.getDetails,
                        style: const TextStyle(
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

  void _showContractorDetailsBottomSheet(BuildContext context) {
    if (contractor == null) return;
    final l10n = AppLocalizations.of(context)!;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.contractorDetails,
                    style: const TextStyle(
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

              SizedBox(height: 24.h),

              _buildDetailRow(
                l10n.agencyName,
                contractor!.agency.name,
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.name,
                contractor!.personName,
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.personPhone,
                contractor!.personPhone,
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.workOrderDate,
                _formatDate(contractor!.contractStartDate),
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.durationOfWork,
                _calculateDuration(
                  contractor!.contractStartDate,
                  contractor!.contractEndDate,
                ),
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.annualContractAmount,
                '₹ ${contractor!.workOrderAmount.toStringAsFixed(2)}',
                Colors.grey,
                const Color(0xFF111827),
              ),
              SizedBox(height: 16.h),

              _buildDetailRow(
                l10n.frequencyOfWork,
                contractor!.cleaningFrequency.toUpperCase() == 'FORTNIGHTLY'
                    ? '—'
                    : contractor!.cleaningFrequency,
                Colors.grey,
                const Color(0xFF111827),
              ),

              SizedBox(height: 30.h),

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
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
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

  void _showNoDataBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surfaceColor = CitizenColors.surface(context);
    final primaryTextColor = CitizenColors.textPrimary(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/nodata.png',
              width: 140.w,
              height: 140.w,
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.contractorDetailsNotAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: primaryTextColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009B56),
                  foregroundColor: CitizenColors.light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.close,
                  style: const TextStyle(
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

  Widget _buildDetailRow(
    String label,
    String value,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryTextColor,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  String _calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'N/A';
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final duration = end.difference(start);
      final months = (duration.inDays / 30).round();
      return '$months months';
    } catch (e) {
      return 'N/A';
    }
  }
}
