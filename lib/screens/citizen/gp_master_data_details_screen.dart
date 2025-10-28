import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/geography_model.dart';
import '../../services/api_services.dart';
import '../../widgets/common/bottom_sheet_picker.dart';
import '../../l10n/app_localizations.dart';
import 'village_master_data_form_screen.dart';

class GpMasterDataDetailsScreen extends StatefulWidget {
  const GpMasterDataDetailsScreen({super.key});

  @override
  State<GpMasterDataDetailsScreen> createState() =>
      _GpMasterDataDetailsScreenState();
}

class _GpMasterDataDetailsScreenState extends State<GpMasterDataDetailsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        ),
        title: Text(
          l10n.masterDataDetails,
          style: const TextStyle(
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
                      Text(
                        l10n.district,
                        style: const TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        style: const TextStyle(
                          fontFamily: 'Noto Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  style: const TextStyle(
                    fontFamily: 'Noto Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                ),
              ],
            ),

            const Spacer(),

            // Continue Button
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (selectedDistrict != null &&
                      selectedBlock != null &&
                      selectedVillage != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VillageMasterDataFormScreen(
                          villageId: selectedVillage!.id,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.pleaseSelectAllFieldsForMasterData),
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
                child: Text(
                  l10n.continueButton,
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
}
