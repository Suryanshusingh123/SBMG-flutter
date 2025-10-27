import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/storage_service.dart';
import '../../models/geography_model.dart';

class SmdDistrictSelectionScreen extends StatefulWidget {
  const SmdDistrictSelectionScreen({super.key});

  @override
  State<SmdDistrictSelectionScreen> createState() =>
      _SmdDistrictSelectionScreenState();
}

class _SmdDistrictSelectionScreenState
    extends State<SmdDistrictSelectionScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  List<District> _districts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      setState(() => _isLoading = true);
      final districts = await _apiService.getDistricts();
      setState(() {
        _districts = districts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading districts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<District> get _filteredDistricts {
    if (_searchQuery.isEmpty) return _districts;
    return _districts
        .where(
          (district) =>
              district.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  void _selectDistrict(District district) async {
    // Store the selected district_id for SMD
    await _storageService.saveString(
      'smd_selected_district_id',
      district.id.toString(),
    );

    print('✅ SMD selected district: ${district.name} (ID: ${district.id})');

    // Navigate to SMD dashboard
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/smd-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select District',
          style: TextStyle(
            fontFamily: 'Noto Sans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search District...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Districts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDistricts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_city_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No districts found',
                            style: TextStyle(
                              fontFamily: 'Noto Sans',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDistricts.length,
                    itemBuilder: (context, index) {
                      final district = _filteredDistricts[index];
                      return _buildDistrictCard(district);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictCard(District district) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDistrict(district),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF009B56).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_city,
                    color: Color(0xFF009B56),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    district.name,
                    style: const TextStyle(
                      fontFamily: 'Noto Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
