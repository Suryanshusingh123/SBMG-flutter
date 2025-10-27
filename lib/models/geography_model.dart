class District {
  final int id;
  final String name;
  final String? description;

  const District({required this.id, required this.name, this.description});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

class Block {
  final int id;
  final String name;
  final String? description;
  final int districtId;

  const Block({
    required this.id,
    required this.name,
    this.description,
    required this.districtId,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      districtId: json['district_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'district_id': districtId,
    };
  }
}

class GramPanchayat {
  final int id;
  final String name;
  final String? description;
  final int? blockId;
  final int? districtId;

  const GramPanchayat({
    required this.id,
    required this.name,
    this.description,
    this.blockId,
    this.districtId,
  });

  factory GramPanchayat.fromJson(Map<String, dynamic> json) {
    return GramPanchayat(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      blockId: json['block_id'] as int?,
      districtId: json['district_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'block_id': blockId,
      'district_id': districtId,
    };
  }
}

class Village {
  final int id;
  final String name;
  final String? description;
  final int? blockId;
  final int? districtId;
  final int? gpId;

  const Village({
    required this.id,
    required this.name,
    this.description,
    this.blockId,
    this.districtId,
    this.gpId,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      blockId: json['block_id'] as int?,
      districtId: json['district_id'] as int?,
      gpId: json['gp_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'block_id': blockId,
      'district_id': districtId,
      'gp_id': gpId,
    };
  }
}

class Agency {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;

  const Agency({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    try {
      return Agency(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Error parsing Agency JSON: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
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

class Contractor {
  final int id;
  final Agency agency;
  final String personName;
  final String personPhone;
  final int villageId;
  final String villageName;
  final String blockName;
  final String districtName;
  final String contractStartDate;
  final String contractEndDate;

  const Contractor({
    required this.id,
    required this.agency,
    required this.personName,
    required this.personPhone,
    required this.villageId,
    required this.villageName,
    required this.blockName,
    required this.districtName,
    required this.contractStartDate,
    required this.contractEndDate,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    try {
      return Contractor(
        id: json['id'] as int,
        agency: Agency.fromJson(json['agency'] as Map<String, dynamic>),
        personName: json['person_name']?.toString() ?? '',
        personPhone: json['person_phone']?.toString() ?? '',
        villageId: json['village_id'] as int,
        villageName: json['village_name']?.toString() ?? '',
        blockName: json['block_name']?.toString() ?? '',
        districtName: json['district_name']?.toString() ?? '',
        contractStartDate: json['contract_start_date']?.toString() ?? '',
        contractEndDate: json['contract_end_date']?.toString() ?? '',
      );
    } catch (e) {
      print('❌ Error parsing Contractor JSON: $e');
      print('📦 JSON data: $json');
      rethrow;
    }
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
}
