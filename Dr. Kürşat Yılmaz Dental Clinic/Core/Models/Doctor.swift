//
//  Doctor.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Doctor: Identifiable, Codable, Hashable {
    // MARK: Firestore document ID
    @DocumentID var id: String?
    
    var name: String
    var title: String          // e.g. "Uzm. Dt."
    var specialty: String
    var tagline: String
    var bio: String
    var experience: String     // e.g. "12 Yıl"
    var patientCount: String   // e.g. "3.500+"
    var satisfactionRate: String // e.g. "%97"
    var avatarInitials: String
    var avatarColorName: String  // Stored as string, resolved to Color in UI
    var expertise: [DoctorExpertise]
    var education: [DoctorEducation]
    var languages: [String]
    var availableDays: [String]  // e.g. ["Pazartesi", "Salı"]
    var clinicIds: [String]      // Clinics this doctor works at
    var isActive: Bool
    
    var accentColor: Color { Color(colorName: avatarColorName) }
    
    // MARK: Init
    init(
        id: String? = nil,
        name: String,
        title: String,
        specialty: String,
        tagline: String = "",
        bio: String = "",
        experience: String = "",
        patientCount: String = "",
        satisfactionRate: String = "",
        avatarInitials: String,
        avatarColorName: String = "blue",
        expertise: [DoctorExpertise] = [],
        education: [DoctorEducation] = [],
        languages: [String] = ["Türkçe"],
        availableDays: [String] = [],
        clinicIds: [String] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.specialty = specialty
        self.tagline = tagline
        self.bio = bio
        self.experience = experience
        self.patientCount = patientCount
        self.satisfactionRate = satisfactionRate
        self.avatarInitials = avatarInitials
        self.avatarColorName = avatarColorName
        self.expertise = expertise
        self.education = education
        self.languages = languages
        self.availableDays = availableDays
        self.clinicIds = clinicIds
        self.isActive = isActive
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case title
        case specialty
        case tagline
        case bio
        case experience
        case patientCount        = "patient_count"
        case satisfactionRate    = "satisfaction_rate"
        case avatarInitials      = "avatar_initials"
        case avatarColorName     = "avatar_color_name"
        case expertise
        case education
        case languages
        case availableDays       = "available_days"
        case clinicIds           = "clinic_ids"
        case isActive            = "is_active"
    }
}

// MARK: - DoctorExpertise
struct DoctorExpertise: Identifiable, Codable, Hashable {

    /// Use a stable string ID so Firestore round-trips are safe
    var id: String
    var title: String
    var icon: String           // SF Symbol name
    var colorName: String      // stored as string

    var color: Color { Color(colorName: colorName) }

    init(id: String = UUID().uuidString,
         title: String,
         icon: String,
         colorName: String = "blue") {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorName = colorName
    }
}

// MARK: - DoctorEducation
struct DoctorEducation: Identifiable, Codable, Hashable {

    var id: String
    var degree: String
    var institution: String
    var year: String

    init(id: String = UUID().uuidString,
         degree: String,
         institution: String,
         year: String) {
        self.id = id
        self.degree = degree
        self.institution = institution
        self.year = year
    }
}

// MARK: - Color name helper (shared extension)
extension Color {
    init(colorName: String) {
        switch colorName.lowercased() {
        case "cyan":   self = .cyan
        case "yellow": self = .yellow
        case "purple": self = .purple
        case "orange": self = .orange
        case "red":    self = .red
        case "green":  self = .green
        case "pink":   self = .pink
        case "indigo": self = .indigo
        case "teal":   self = .teal
        default:       self = .blue
        }
    }
}
