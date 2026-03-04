//
//  Appointment.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct Appointment: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var doctorId: String
    var doctorName: String
    var doctorSpecialty: String
    var date: Date
    var time: String
    var type: AppointmentType
    var status: AppointmentStatus
    var notes: String
    var roomNumber: String
    var createdAt: Date?
    
    enum AppointmentType: String, Codable, CaseIterable {
        case checkup = "Kontrol"
        case cleaning = "Temizlik"
        case implant = "İmplant"
        case orthodontics = "Ortodonti"
        case whitening = "Beyazlatma"
        case rootCanal = "Kanal"
        
        var icon: String {
            switch self {
            case .checkup: return "magnifyingglass.circle.fill"
            case .cleaning: return "sparkles"
            case .implant: return "cross.circle.fill"
            case .orthodontics: return "mouth.fill"
            case .whitening: return "sun.max.fill"
            case .rootCanal: return "waveform.path.ecg.rectangle.fill"
            }
        }
        var color: Color {
            switch self {
            case .checkup: return .blue
            case .cleaning: return .cyan
            case .implant: return .purple
            case .orthodontics: return .orange
            case .whitening: return .yellow
            case .rootCanal: return .red
            }
        }
    }
    
    enum AppointmentStatus: String, Codable {
        case upcoming = "Yaklaşan"
        case completed = "Tamamlandı"
        case cancelled = "İptal"
        case inProgress = "Devam Ediyor"
    }
}
