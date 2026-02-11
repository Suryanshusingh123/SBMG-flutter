/// Nested model for household_waste section of inspection API.
class HouseholdWaste {
  final int? id;
  final String? wasteCollectionFrequency;
  final bool dryWetVehicleSegregation;
  final bool coveredCollectionInVehicles;
  final bool wasteDisposedAtRrc;
  final bool rrcWasteCollectionAndDisposalArrangement;
  final bool wasteCollectionVehicleFunctional;

  HouseholdWaste({
    this.id,
    this.wasteCollectionFrequency,
    required this.dryWetVehicleSegregation,
    required this.coveredCollectionInVehicles,
    required this.wasteDisposedAtRrc,
    required this.rrcWasteCollectionAndDisposalArrangement,
    required this.wasteCollectionVehicleFunctional,
  });

  factory HouseholdWaste.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return HouseholdWaste(
        dryWetVehicleSegregation: false,
        coveredCollectionInVehicles: false,
        wasteDisposedAtRrc: false,
        rrcWasteCollectionAndDisposalArrangement: false,
        wasteCollectionVehicleFunctional: false,
      );
    }
    return HouseholdWaste(
      id: json['id'] as int?,
      wasteCollectionFrequency: json['waste_collection_frequency'] as String?,
      dryWetVehicleSegregation: json['dry_wet_vehicle_segregation'] == true,
      coveredCollectionInVehicles: json['covered_collection_in_vehicles'] == true,
      wasteDisposedAtRrc: json['waste_disposed_at_rrc'] == true,
      rrcWasteCollectionAndDisposalArrangement:
          json['rrc_waste_collection_and_disposal_arrangement'] == true,
      wasteCollectionVehicleFunctional:
          json['waste_collection_vehicle_functional'] == true,
    );
  }
}

/// Nested model for road_and_drain section of inspection API.
class RoadAndDrain {
  final int? id;
  final String? roadCleaningFrequency;
  final String? drainCleaningFrequency;
  final bool disposalOfSludgeFromDrains;
  final bool drainWasteCollectedOnRoadside;

  RoadAndDrain({
    this.id,
    this.roadCleaningFrequency,
    this.drainCleaningFrequency,
    required this.disposalOfSludgeFromDrains,
    required this.drainWasteCollectedOnRoadside,
  });

  factory RoadAndDrain.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RoadAndDrain(
        disposalOfSludgeFromDrains: false,
        drainWasteCollectedOnRoadside: false,
      );
    }
    return RoadAndDrain(
      id: json['id'] as int?,
      roadCleaningFrequency: json['road_cleaning_frequency'] as String?,
      drainCleaningFrequency: json['drain_cleaning_frequency'] as String?,
      disposalOfSludgeFromDrains:
          json['disposal_of_sludge_from_drains'] == true,
      drainWasteCollectedOnRoadside:
          json['drain_waste_colllected_on_roadside'] == true,
    );
  }
}

/// Nested model for community_sanitation section of inspection API.
class CommunitySanitation {
  final int? id;
  final String? cscCleaningFrequency;
  final bool electricityAndWater;
  final bool cscUsedByCommunity;
  final bool pinkToiletsCleaning;
  final bool pinkToiletsUsed;

  CommunitySanitation({
    this.id,
    this.cscCleaningFrequency,
    required this.electricityAndWater,
    required this.cscUsedByCommunity,
    required this.pinkToiletsCleaning,
    required this.pinkToiletsUsed,
  });

  factory CommunitySanitation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CommunitySanitation(
        electricityAndWater: false,
        cscUsedByCommunity: false,
        pinkToiletsCleaning: false,
        pinkToiletsUsed: false,
      );
    }
    return CommunitySanitation(
      id: json['id'] as int?,
      cscCleaningFrequency: json['csc_cleaning_frequency'] as String?,
      electricityAndWater: json['electricity_and_water'] == true,
      cscUsedByCommunity: json['csc_used_by_community'] == true,
      pinkToiletsCleaning: json['pink_toilets_cleaning'] == true,
      pinkToiletsUsed: json['pink_toilets_used'] == true,
    );
  }
}

/// Nested model for other_items section of inspection API.
class InspectionOtherItems {
  final int? id;
  final bool firmPaidRegularly;
  final bool cleaningStaffPaidRegularly;
  final bool firmProvidedSafetyEquipment;
  final bool regularFeedbackRegisterEntry;
  final bool chartPreparedForCleaningWork;
  final bool villageVisiblyClean;
  final bool rateChartDisplayed;

  InspectionOtherItems({
    this.id,
    required this.firmPaidRegularly,
    required this.cleaningStaffPaidRegularly,
    required this.firmProvidedSafetyEquipment,
    required this.regularFeedbackRegisterEntry,
    required this.chartPreparedForCleaningWork,
    required this.villageVisiblyClean,
    required this.rateChartDisplayed,
  });

  factory InspectionOtherItems.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InspectionOtherItems(
        firmPaidRegularly: false,
        cleaningStaffPaidRegularly: false,
        firmProvidedSafetyEquipment: false,
        regularFeedbackRegisterEntry: false,
        chartPreparedForCleaningWork: false,
        villageVisiblyClean: false,
        rateChartDisplayed: false,
      );
    }
    return InspectionOtherItems(
      id: json['id'] as int?,
      firmPaidRegularly: json['firm_paid_regularly'] == true,
      cleaningStaffPaidRegularly: json['cleaning_staff_paid_regularly'] == true,
      firmProvidedSafetyEquipment:
          json['firm_provided_safety_equipment'] == true,
      regularFeedbackRegisterEntry:
          json['regular_feedback_register_entry'] == true,
      chartPreparedForCleaningWork:
          json['chart_prepared_for_cleaning_work'] == true,
      villageVisiblyClean: json['village_visibly_clean'] == true,
      rateChartDisplayed: json['rate_chart_displayed'] == true,
    );
  }
}

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
  /// Media URLs from the API (e.g. inspection photos). Null-safe for older API/cache.
  final List<String>? mediaUrls;

  /// Optional fields from GET /api/v1/inspections/{id} detail response.
  final int? positionHolderId;
  final String? startTime;
  final String? lat;
  final String? long;
  final bool? registerMaintenance;
  final HouseholdWaste? householdWaste;
  final RoadAndDrain? roadAndDrain;
  final CommunitySanitation? communitySanitation;
  final InspectionOtherItems? otherItems;

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
    this.mediaUrls,
    this.positionHolderId,
    this.startTime,
    this.lat,
    this.long,
    this.registerMaintenance,
    this.householdWaste,
    this.roadAndDrain,
    this.communitySanitation,
    this.otherItems,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    // API returns "images": [] for inspection photos (GET /api/v1/inspections/{id})
    final rawImages = json['images'];
    List<String> fromImages = [];
    if (rawImages != null && rawImages is List) {
      for (final e in rawImages) {
        if (e == null) continue;
        if (e is String && e.isNotEmpty) {
          fromImages.add(e);
        } else if (e is Map<String, dynamic>) {
          final url = e['url'] ?? e['media_url'] ?? e['file'];
          if (url != null && url.toString().isNotEmpty) {
            fromImages.add(url.toString());
          }
        }
      }
    }
    final fromMediaUrls = json['media_urls'] != null
        ? (json['media_urls'] as List<dynamic>)
            .map((e) => e?.toString())
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];
    final mediaList = json['media'] as List<dynamic>?;
    final fromMedia = mediaList != null
        ? mediaList
            .map((e) => (e as Map<String, dynamic>)['media_url']?.toString())
            .whereType<String>()
            .toList()
        : <String>[];
    final allUrls = fromImages.isNotEmpty
        ? fromImages
        : (fromMediaUrls.isNotEmpty ? fromMediaUrls : fromMedia);

    // API uses register_maintenance; list endpoint may use visibly_clean
    final visiblyClean = json['register_maintenance'] ?? json['visibly_clean'] ?? false;
    final registerMaintenance = json['register_maintenance'] as bool?;

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
      visiblyClean: visiblyClean is bool ? visiblyClean : false,
      overallScore: (json['overall_score'] ?? 0).toDouble(),
      mediaUrls: allUrls.isEmpty ? null : allUrls,
      positionHolderId: json['position_holder_id'] as int?,
      startTime: json['start_time']?.toString(),
      lat: json['lat']?.toString(),
      long: json['long']?.toString(),
      registerMaintenance: registerMaintenance,
      householdWaste: json['household_waste'] != null
          ? HouseholdWaste.fromJson(
              json['household_waste'] as Map<String, dynamic>)
          : null,
      roadAndDrain: json['road_and_drain'] != null
          ? RoadAndDrain.fromJson(
              json['road_and_drain'] as Map<String, dynamic>)
          : null,
      communitySanitation: json['community_sanitation'] != null
          ? CommunitySanitation.fromJson(
              json['community_sanitation'] as Map<String, dynamic>)
          : null,
      otherItems: json['other_items'] != null
          ? InspectionOtherItems.fromJson(
              json['other_items'] as Map<String, dynamic>)
          : null,
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
      'register_maintenance': registerMaintenance ?? visiblyClean,
      'overall_score': overallScore,
      'media_urls': mediaUrls ?? [],
      'images': mediaUrls ?? [],
      if (positionHolderId != null) 'position_holder_id': positionHolderId,
      if (startTime != null) 'start_time': startTime,
      if (lat != null) 'lat': lat,
      if (long != null) 'long': long,
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
