//
//  Patient.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import FirebaseFirestore



struct Patient: Identifiable, Codable, Hashable {

    // MARK: Firestore document ID
    @DocumentID var id: String?

    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: Gender
    var phone: String?
    var email: String?
    var address: Address?
    var tcKimlikNo: String?
    var bloodType: BloodType?
    var addresses: [Address]
    var allergies: [Allergy]
    var smokingStatus: SmokingStatus
    var alcoholStatus: AlcoholStatus
    var medications: [Medication]
    var chronicDiseases: [ChronicDisease]
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    var loyaltyPoints: Int
    var isPregnant: Bool?
    var toothSensitivityLevel: Int
    var lastTetanusDate: Date?
    var emergencyContacts: [EmergencyContact]
    var profilePhotoPath: String?
    var fullName: String { "\(firstName) \(lastName)" }
    var avatarLetter: String { firstName.prefix(1).uppercased() }
    var age: Int { Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0 }
    
    init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        birthDate: Date,
        gender: Gender,
        notes: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        loyaltyPoints: Int = 0,
        address: Address? = nil,
        isPregnant: Bool? = nil,
        addresses: [Address] = [],
        tcKimlikNo: String? = nil,
        bloodType: BloodType? = nil,
        lastTetanusDate: Date? = nil,
        toothSensitivityLevel: Int = 0,
        allergies: [Allergy] = [],
        medications: [Medication] = [],
        alcoholStatus: AlcoholStatus = .never,
        smokingStatus: SmokingStatus = .never,
        chronicDiseases: [ChronicDisease] = [],
        emergencyContacts: [EmergencyContact] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.notes = notes
        self.phone = phone
        self.email = email
        self.gender = gender
        self.address = address
        self.lastName = lastName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.firstName = firstName
        self.birthDate = birthDate
        self.bloodType = bloodType
        self.allergies = allergies
        self.addresses = addresses
        self.isPregnant = isPregnant
        self.tcKimlikNo = tcKimlikNo
        self.medications = medications
        self.smokingStatus = smokingStatus
        self.alcoholStatus = alcoholStatus
        self.loyaltyPoints = loyaltyPoints
        self.chronicDiseases = chronicDiseases
        self.lastTetanusDate = lastTetanusDate
        self.emergencyContacts = emergencyContacts
        self.toothSensitivityLevel = toothSensitivityLevel
    }
}


enum BloodType: String, Codable, CaseIterable, Identifiable {
    case aPos    = "A+"
    case aNeg    = "A-"
    case bPos    = "B+"
    case bNeg    = "B-"
    case abPos   = "AB+"
    case abNeg   = "AB-"
    case zeroPos = "0+"
    case zeroNeg = "0-"
    case unknown = "Bilinmiyor"
    var id: String { rawValue }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Erkek"
    case female = "Kadın"
    case other = "Diğer"
}

enum SmokingStatus: String, Codable {
    case never = "Hayır"
    case former = "Bıraktım"
    case current = "Evet"
}

enum AlcoholStatus: String, Codable {
    case never = "Hayır"
    case occasional = "Ara sıra"
    case regular = "Düzenli"
}

enum TreatmentStatus: String, Codable {
    case planned = "Planlandı"
    case active = "Aktif"
    case completed = "Tamamlandı"
    case pending = "Bekliyor"
}

enum PaymentMethod: String, Codable {
    case cash = "Nakit"
    case creditCard = "Kredi Kartı"
    case bankTransfer = "Havale/EFT"
    case insurance = "Sigorta"
}

enum PaymentStatus: String, Codable {
    case paid = "Ödendi"
    case pending = "Bekliyor"
    case overdue = "Gecikmiş"
    case partial = "Kısmi"
}

enum DocumentType: String, Codable, CaseIterable {
    case xray = "Röntgen"
    case tomography = "Tomografi"
    case photo = "Fotoğraf"
    case labResult = "Lab Sonucu"
    case consent = "Onam Formu"
    case contract = "Sözleşme"
    case prescription = "Reçete"
    case invoice = "Fatura"
}


struct Allergy: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var severity: AllergySeverity
    var notes: String?

    enum AllergySeverity: String, Codable, Hashable {
        case mild = "Hafif"
        case moderate = "Orta"
        case severe = "Şiddetli"
    }
}

struct ChronicDisease: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var diagnosedYear: Int?
    var notes: String?
}

struct Medication: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var dosage: String
    var frequency: String
    var startDate: Date?
}

struct Address: Codable, Hashable {
    var type: AddressType
    var street: String
    var district: String
    var city: String
    var postalCode: String?

    enum AddressType: String, Codable, Hashable {
        case home = "Ev"
        case office = "İş"
        case other = "Diğer"
    }

    var fullAddress: String {
        "\(street), \(district), \(city)"
    }
}

struct EmergencyContact: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var relationship: String
    var phone: String
}

struct ToothTreatment: Identifiable, Codable, Hashable {
    var id = UUID()
    var toothNumber: Int?
    var treatmentName: String
    var totalSessions: Int
    var completedSessions: Int
    var status: TreatmentStatus
    var startDate: Date
    var estimatedEndDate: Date?
    var doctorName: String
    var notes: String?
    var cost: Double

    var progressPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
}


struct Payment: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var amount: Double
    var method: PaymentMethod
    var status: PaymentStatus
    var description: String
    var invoiceNumber: String?
}

struct PaymentPlan: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var totalAmount: Double
    var paidAmount: Double
    var installments: [Installment]
    
    var remainingAmount: Double { totalAmount - paidAmount }
    var progressPercentage: Double {
        guard totalAmount > 0 else { return 0 }
        return paidAmount / totalAmount
    }
    
    struct Installment: Identifiable, Codable, Hashable {
        var id = UUID()
        var dueDate: Date
        var amount: Double
        var isPaid: Bool
    }
}

struct PatientDocument: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var type: DocumentType
    var date: Date
    var fileSize: String
    var thumbnailSystemImage: String
}

extension Patient {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        case notes
        case phone
        case email
        case loyaltyPoints = "loyalty_points"
        case address
        case isPregnant = "is_pregnant"
        case addresses
        case tcKimlikNo = "tc_kimlik_no"
        case bloodType = "blood_type"
        case lastTetanusDate = "last_tetanus_date"
        case toothSensitivityLevel = "tooth_sensitivity_level"
        case allergies
        case medications
        case alcoholStatus = "alcohol_status"
        case smokingStatus = "smoking_status"
        case chronicDiseases = "chronic_diseases"
        case emergencyContacts = "emergency_contacts"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case profilePhotoPath = "profile_photo_path"
    }
}
