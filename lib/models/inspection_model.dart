class Inspection {
  final int id;
  final int villageId;
  final String villageName;
  final String blockName;
  final String districtName;
  final String date;
  final String officerName;
  final String officerRole;
  final String remarks;
  final bool visiblyClean;
  final double overallScore;

  Inspection({
    required this.id,
    required this.villageId,
    required this.villageName,
    required this.blockName,
    required this.districtName,
    required this.date,
    required this.officerName,
    required this.officerRole,
    required this.remarks,
    required this.visiblyClean,
    required this.overallScore,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] ?? 0,
      villageId: json['village_id'] ?? 0,
      villageName: json['village_name'] ?? '',
      blockName: json['block_name'] ?? '',
      districtName: json['district_name'] ?? '',
      date: json['date'] ?? '',
      officerName: json['officer_name'] ?? '',
      officerRole: json['officer_role'] ?? '',
      remarks: json['remarks'] ?? '',
      visiblyClean: json['visibly_clean'] ?? false,
      overallScore: (json['overall_score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'village_id': villageId,
      'village_name': villageName,
      'block_name': blockName,
      'district_name': districtName,
      'date': date,
      'officer_name': officerName,
      'officer_role': officerRole,
      'remarks': remarks,
      'visibly_clean': visiblyClean,
      'overall_score': overallScore,
    };
  }
}

class InspectionResponse {
  final List<Inspection> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  InspectionResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory InspectionResponse.fromJson(Map<String, dynamic> json) {
    return InspectionResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => Inspection.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'page': page,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}
