//
//  Clinic.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import FirebaseFirestore

// MARK: - Clinic
struct Clinic: Identifiable, Codable, Hashable {
    
    // MARK: Firestore document ID
    @DocumentID var id: String?
    
    var name: String
    var branchCode: String?
    var address: ClinicAddress?
    var phone: String?
    var email: String?
    var website: String?
    var taxNumber: String?
    var licenseNumber: String?
    var openingDate: Date?
    var clinicType: ClinicType
    var totalAreaSquareMeters: Double?
    var rooms: [ClinicRoom]
    var equipmentSummary: ClinicEquipmentSummary?
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: Computed (not stored)
    var treatmentRoomCount: Int {
        rooms.filter { $0.type == .treatment || $0.type == .muayene }.count
    }
    
    /// Minimum required waiting area in m² based on Turkish regulation (approximate)
    var minimumRequiredWaitingArea: Double {
        switch clinicType {
        case .muayenehane: return 10.0 + Double(max(0, treatmentRoomCount - 1)) * 5.0
        case .poliklinik:  return 15.0 + Double(max(0, treatmentRoomCount - 2)) * 5.0
        case .merkez:      return 50.0 + Double(max(0, treatmentRoomCount - 10)) * 5.0
        case .hastane:     return 100.0
        }
    }
    
    // MARK: Init
    init(
        id: String? = nil,
        name: String,
        branchCode: String? = nil,
        address: ClinicAddress? = nil,
        phone: String? = nil,
        email: String? = nil,
        website: String? = nil,
        taxNumber: String? = nil,
        licenseNumber: String? = nil,
        openingDate: Date? = nil,
        clinicType: ClinicType = .muayenehane,
        totalAreaSquareMeters: Double? = nil,
        rooms: [ClinicRoom] = [],
        equipmentSummary: ClinicEquipmentSummary? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.branchCode = branchCode
        self.address = address
        self.phone = phone
        self.email = email
        self.website = website
        self.taxNumber = taxNumber
        self.licenseNumber = licenseNumber
        self.openingDate = openingDate
        self.clinicType = clinicType
        self.totalAreaSquareMeters = totalAreaSquareMeters
        self.rooms = rooms
        self.equipmentSummary = equipmentSummary
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - ClinicType (Turkish legal classification)
    enum ClinicType: String, Codable, CaseIterable, Identifiable, Hashable {
        case muayenehane = "Muayenehane"
        case poliklinik  = "Poliklinik"
        case merkez      = "Ağız ve Diş Sağlığı Merkezi"
        case hastane     = "Ağız ve Diş Sağlığı Hastanesi"
        var id: String { rawValue }
    }

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case branchCode           = "branch_code"
        case address
        case phone
        case email
        case website
        case taxNumber            = "tax_number"
        case licenseNumber        = "license_number"
        case openingDate          = "opening_date"
        case clinicType           = "clinic_type"
        case totalAreaSquareMeters = "total_area_sqm"
        case rooms
        case equipmentSummary     = "equipment_summary"
        case isActive             = "is_active"
        case createdAt            = "created_at"
        case updatedAt            = "updated_at"
    }
}

// MARK: - ClinicAddress
struct ClinicAddress: Codable, Hashable {
    var city: String
    var district: String?
    var neighborhood: String?
    var street: String?
    var buildingNo: String?
    var apartmentNo: String?
    var postalCode: String?
    var latitude: Double?
    var longitude: Double?

    init(
        city: String = "İstanbul",
        district: String? = nil,
        neighborhood: String? = nil,
        street: String? = nil,
        buildingNo: String? = nil,
        apartmentNo: String? = nil,
        postalCode: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.city = city
        self.district = district
        self.neighborhood = neighborhood
        self.street = street
        self.buildingNo = buildingNo
        self.apartmentNo = apartmentNo
        self.postalCode = postalCode
        self.latitude = latitude
        self.longitude = longitude
    }

    var fullAddress: String {
        [neighborhood, street,
         [buildingNo, apartmentNo].compactMap { $0 }.joined(separator: "/"),
         district, city, postalCode]
            .compactMap { $0?.isEmpty == false ? $0 : nil }
            .joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case city, district, neighborhood, street
        case buildingNo   = "building_no"
        case apartmentNo  = "apartment_no"
        case postalCode   = "postal_code"
        case latitude, longitude
    }
}

// MARK: - ClinicRoom
struct ClinicRoom: Identifiable, Codable, Hashable {

    var id: String
    var name: String
    var roomNumber: String?
    var type: RoomType
    var areaSquareMeters: Double?
    var widthMeters: Double?
    var lengthMeters: Double?
    var floor: Int
    var hasWindow: Bool
    var hasSink: Bool
    var equipment: [String]
    var assignedDoctorIds: [String]   // ✅ String IDs for Firestore
    var notes: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        roomNumber: String? = nil,
        type: RoomType,
        areaSquareMeters: Double? = nil,
        widthMeters: Double? = nil,
        lengthMeters: Double? = nil,
        floor: Int = 0,
        hasWindow: Bool = false,
        hasSink: Bool = true,
        equipment: [String] = [],
        assignedDoctorIds: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.roomNumber = roomNumber
        self.type = type
        self.areaSquareMeters = areaSquareMeters
        self.widthMeters = widthMeters
        self.lengthMeters = lengthMeters
        self.floor = floor
        self.hasWindow = hasWindow
        self.hasSink = hasSink
        self.equipment = equipment
        self.assignedDoctorIds = assignedDoctorIds
        self.notes = notes
    }

    enum RoomType: String, Codable, CaseIterable, Identifiable, Hashable {
        case muayene        = "Muayene / Tedavi Odası"
        case treatment      = "Tedavi Odası (Ünitli)"
        case waitingArea    = "Bekleme Salonu"
        case reception      = "Resepsiyon / Kayıt"
        case sterilization  = "Sterilizasyon Alanı"
        case xrayPeriapical = "Periapikal Röntgen Odası"
        case xrayPanoramic  = "Panoramik Röntgen Odası"
        case xrayCBCT       = "CBCT / Tomografi Odası"
        case storage        = "Malzeme / Depo Odası"
        case staffRoom      = "Personel Odası / Dinlenme"
        case meeting        = "Toplantı / Eğitim Odası"
        case wcPatient      = "Hasta Tuvaleti"
        case wcStaff        = "Personel Tuvaleti"
        case other          = "Diğer"
        var id: String { rawValue }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, floor, equipment, notes
        case roomNumber        = "room_number"
        case areaSquareMeters  = "area_sqm"
        case widthMeters       = "width_m"
        case lengthMeters      = "length_m"
        case hasWindow         = "has_window"
        case hasSink           = "has_sink"
        case assignedDoctorIds = "assigned_doctor_ids"
    }
}

// MARK: - ClinicEquipmentSummary
struct ClinicEquipmentSummary: Codable, Hashable {
    var dentalUnitsCount: Int
    var panoramicXray: Bool
    var cbct: Bool
    var autoclaveClass: String?   // "B", "S", "N"
    var hasCADCAM: Bool
    var hasLaser: Bool
    var hasIntraOralScanner: Bool

    init(
        dentalUnitsCount: Int = 0,
        panoramicXray: Bool = false,
        cbct: Bool = false,
        autoclaveClass: String? = nil,
        hasCADCAM: Bool = false,
        hasLaser: Bool = false,
        hasIntraOralScanner: Bool = false
    ) {
        self.dentalUnitsCount = dentalUnitsCount
        self.panoramicXray = panoramicXray
        self.cbct = cbct
        self.autoclaveClass = autoclaveClass
        self.hasCADCAM = hasCADCAM
        self.hasLaser = hasLaser
        self.hasIntraOralScanner = hasIntraOralScanner
    }

    enum CodingKeys: String, CodingKey {
        case dentalUnitsCount        = "dental_units_count"
        case panoramicXray           = "panoramic_xray"
        case cbct
        case autoclaveClass          = "autoclave_class"
        case hasCADCAM               = "has_cad_cam"
        case hasLaser                = "has_laser"
        case hasIntraOralScanner     = "has_intraoral_scanner"
    }
}
