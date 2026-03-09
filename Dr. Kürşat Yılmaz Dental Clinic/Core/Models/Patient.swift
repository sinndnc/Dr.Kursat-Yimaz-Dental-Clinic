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
    var birthDate: Date?
    var gender: Gender?
    var phone: String?
    var email: String?
    var address: String?

    /// TC Kimlik No (Turkey national ID)
    var tcKimlikNo: String?

    var bloodType: BloodType?
    var allergies: [String]
    var chronicDiseases: [String]
    var smoking: Bool
    var notes: String?

    var createdAt: Date
    var updatedAt: Date

    // MARK: Computed (not stored in Firestore)
    var fullName: String { "\(firstName) \(lastName)" }

    /// Age in years, nil if birthDate is missing
    var age: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    var avatarLetter: String { firstName.prefix(1).uppercased() }

    
    // MARK: Init
    init(
        id: String? = nil,
        firstName: String,
        lastName: String,
        birthDate: Date? = nil,
        gender: Gender? = nil,
        phone: String? = nil,
        email: String? = nil,
        address: String? = nil,
        tcKimlikNo: String? = nil,
        bloodType: BloodType? = nil,
        allergies: [String] = [],
        chronicDiseases: [String] = [],
        smoking: Bool = false,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.phone = phone
        self.email = email
        self.address = address
        self.tcKimlikNo = tcKimlikNo
        self.bloodType = bloodType
        self.allergies = allergies
        self.chronicDiseases = chronicDiseases
        self.smoking = smoking
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - Gender
    enum Gender: String, Codable, CaseIterable, Identifiable {
        case male   = "Erkek"
        case female = "Kadın"
        case other  = "Diğer"
        var id: String { rawValue }
    }

    // MARK: - BloodType
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
}

// MARK: - Firestore CodingKeys
// Firestore field names (snake_case → camelCase handled by encoder config)
extension Patient {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName       = "first_name"
        case lastName        = "last_name"
        case birthDate       = "birth_date"
        case gender
        case phone
        case email
        case address
        case tcKimlikNo      = "tc_kimlik_no"
        case bloodType       = "blood_type"
        case allergies
        case chronicDiseases = "chronic_diseases"
        case smoking
        case notes
        case createdAt       = "created_at"
        case updatedAt       = "updated_at"
    }
}
