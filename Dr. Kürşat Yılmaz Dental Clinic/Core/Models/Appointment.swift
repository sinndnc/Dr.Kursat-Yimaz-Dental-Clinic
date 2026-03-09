//
//  Appointment.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Appointment: Identifiable, Codable, Hashable {

    // MARK: Firestore document ID
    @DocumentID var id: String?

    var patientId: String
    var patientName: String       // denormalized for quick display
    var doctorId: String
    var doctorName: String
    var doctorSpecialty: String
    var clinicId: String
    var date: Date
    var time: String              // "09:30" – human readable slot
    var durationMinutes: Int      // appointment length in minutes
    var type: AppointmentType
    var status: AppointmentStatus
    var notes: String
    var roomNumber: String
    var serviceId: String?        // linked DentalService
    var createdAt: Date
    var updatedAt: Date

    // MARK: Computed helpers
    var isUpcoming: Bool { status == .upcoming && date > Date() }
    var isPast: Bool    { date < Date() }

    // MARK: Init
    init(
        id: String? = nil,
        patientId: String,
        patientName: String,
        doctorId: String,
        doctorName: String,
        doctorSpecialty: String,
        clinicId: String = "",
        date: Date,
        time: String,
        durationMinutes: Int = 30,
        type: AppointmentType,
        status: AppointmentStatus = .upcoming,
        notes: String = "",
        roomNumber: String = "",
        serviceId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.patientId = patientId
        self.patientName = patientName
        self.doctorId = doctorId
        self.doctorName = doctorName
        self.doctorSpecialty = doctorSpecialty
        self.clinicId = clinicId
        self.date = date
        self.time = time
        self.durationMinutes = durationMinutes
        self.type = type
        self.status = status
        self.notes = notes
        self.roomNumber = roomNumber
        self.serviceId = serviceId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // MARK: - AppointmentType
    enum AppointmentType: String, Codable, CaseIterable, Identifiable, Hashable {
        case checkup      = "Kontrol"
        case cleaning     = "Temizlik"
        case implant      = "İmplant"
        case orthodontics = "Ortodonti"
        case whitening    = "Beyazlatma"
        case rootCanal    = "Kanal Tedavisi"
        case extraction   = "Çekim"
        case prosthetics  = "Protez"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .checkup:      return "magnifyingglass.circle.fill"
            case .cleaning:     return "sparkles"
            case .implant:      return "cross.circle.fill"
            case .orthodontics: return "mouth.fill"
            case .whitening:    return "sun.max.fill"
            case .rootCanal:    return "waveform.path.ecg.rectangle.fill"
            case .extraction:   return "scissors"
            case .prosthetics:  return "staroflife.fill"
            }
        }

        var colorName: String {
            switch self {
            case .checkup:      return "blue"
            case .cleaning:     return "cyan"
            case .implant:      return "purple"
            case .orthodontics: return "orange"
            case .whitening:    return "yellow"
            case .rootCanal:    return "red"
            case .extraction:   return "pink"
            case .prosthetics:  return "indigo"
            }
        }

        var color: Color { Color(colorName: colorName) }
    }

    // MARK: - AppointmentStatus
    enum AppointmentStatus: String, Codable, CaseIterable, Identifiable, Hashable {
        case upcoming   = "Yaklaşan"
        case inProgress = "Devam Ediyor"
        case completed  = "Tamamlandı"
        case cancelled  = "İptal"
        case noShow     = "Gelmedi"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .upcoming:   return "clock"
            case .inProgress: return "arrow.triangle.2.circlepath"
            case .completed:  return "checkmark.circle.fill"
            case .cancelled:  return "xmark.circle.fill"
            case .noShow:     return "person.fill.xmark"
            }
        }

        var color: Color {
            switch self {
            case .upcoming:   return .blue
            case .inProgress: return .orange
            case .completed:  return .green
            case .cancelled:  return .red
            case .noShow:     return .gray
            }
        }
    }

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case patientId       = "patient_id"
        case patientName     = "patient_name"
        case doctorId        = "doctor_id"
        case doctorName      = "doctor_name"
        case doctorSpecialty = "doctor_specialty"
        case clinicId        = "clinic_id"
        case date
        case time
        case durationMinutes = "duration_minutes"
        case type
        case status
        case notes
        case roomNumber      = "room_number"
        case serviceId       = "service_id"
        case createdAt       = "created_at"
        case updatedAt       = "updated_at"
    }
}

extension Array where Element == Appointment {
    var upcoming: [Appointment] {
        filter { $0.status == .upcoming && $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }
    
    var past: [Appointment] {
        filter { $0.status == .completed || $0.status == .cancelled ||
                 $0.status == .noShow || ($0.status == .upcoming && $0.date < Date()) }
            .sorted { $0.date > $1.date }
    }
    
    var next: Appointment? { upcoming.first }
    
    var cancelled: [Appointment] {
        filter { $0.status == .cancelled }.sorted { $0.date > $1.date }
    }
}
