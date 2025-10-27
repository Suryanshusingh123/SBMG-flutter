class Agency {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Agency({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}

class ContractorDetails {
  final int id;
  final Agency agency;
  final String personName;
  final String personPhone;
  final int villageId;
  final String villageName;
  final String blockName;
  final String districtName;
  final String contractStartDate;
  final String? contractEndDate;

  ContractorDetails({
    required this.id,
    required this.agency,
    required this.personName,
    required this.personPhone,
    required this.villageId,
    required this.villageName,
    required this.blockName,
    required this.districtName,
    required this.contractStartDate,
    this.contractEndDate,
  });

  factory ContractorDetails.fromJson(Map<String, dynamic> json) {
    return ContractorDetails(
      id: json['id'] ?? 0,
      agency: Agency.fromJson(json['agency'] ?? {}),
      personName: json['person_name'] ?? '',
      personPhone: json['person_phone'] ?? '',
      villageId: json['village_id'] ?? 0,
      villageName: json['village_name'] ?? '',
      blockName: json['block_name'] ?? '',
      districtName: json['district_name'] ?? '',
      contractStartDate: json['contract_start_date'] ?? '',
      contractEndDate: json['contract_end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agency': agency.toJson(),
      'person_name': personName,
      'person_phone': personPhone,
      'village_id': villageId,
      'village_name': villageName,
      'block_name': blockName,
      'district_name': districtName,
      'contract_start_date': contractStartDate,
      'contract_end_date': contractEndDate,
    };
  }

  // Helper method to format contract start date
  String get formattedContractStartDate {
    try {
      final date = DateTime.parse(contractStartDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return contractStartDate;
    }
  }

  // Helper method to get contract duration
  String get contractDuration {
    try {
      final startDate = DateTime.parse(contractStartDate);
      final endDate = contractEndDate != null
          ? DateTime.parse(contractEndDate!)
          : DateTime.now();
      final difference = endDate.difference(startDate);
      final months = (difference.inDays / 30).round();
      return '$months months';
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper method to get work frequency (placeholder)
  String get workFrequency => '3 times a day';
}
