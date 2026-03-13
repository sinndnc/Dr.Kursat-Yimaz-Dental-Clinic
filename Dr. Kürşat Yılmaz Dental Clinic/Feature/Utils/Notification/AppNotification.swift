//
//  AppNotification.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import FirebaseFirestore

struct AppNotification: Identifiable, Codable, Hashable {
    
    @DocumentID var id: String?
    
    var recipientId: String          // Patient UID
    var title: String
    var body: String
    var type: NotificationType
    var relatedId: String?           // appointmentId, serviceId, etc.
    var isRead: Bool
    var createdAt: Date
    
    // MARK: Init
    init(
        id: String? = nil,
        recipientId: String,
        title: String,
        body: String,
        type: NotificationType,
        relatedId: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.recipientId = recipientId
        self.title = title
        self.body = body
        self.type = type
        self.relatedId = relatedId
        self.isRead = isRead
        self.createdAt = createdAt
    }
    
    // MARK: - NotificationType
    enum NotificationType: String, Codable, CaseIterable, Identifiable {
        case appointmentReminder  = "appointment_reminder"
        case appointmentConfirmed = "appointment_confirmed"
        case appointmentCancelled = "appointment_cancelled"
        case appointmentRescheduled = "appointment_rescheduled"
        case treatmentPlanReady   = "treatment_plan_ready"
        case invoiceReady         = "invoice_ready"
        case generalInfo          = "general_info"
        case promotionOffer       = "promotion_offer"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .appointmentReminder:    return "bell.fill"
            case .appointmentConfirmed:   return "checkmark.circle.fill"
            case .appointmentCancelled:   return "xmark.circle.fill"
            case .appointmentRescheduled: return "arrow.triangle.2.circlepath"
            case .treatmentPlanReady:     return "doc.text.fill"
            case .invoiceReady:           return "creditcard.fill"
            case .generalInfo:            return "info.circle.fill"
            case .promotionOffer:         return "tag.fill"
            }
        }
        
        var colorName: String {
            switch self {
            case .appointmentReminder:    return "orange"
            case .appointmentConfirmed:   return "green"
            case .appointmentCancelled:   return "red"
            case .appointmentRescheduled: return "blue"
            case .treatmentPlanReady:     return "purple"
            case .invoiceReady:           return "indigo"
            case .generalInfo:            return "blue"
            case .promotionOffer:         return "pink"
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipientId  = "recipient_id"
        case title, body, type
        case relatedId    = "related_id"
        case isRead       = "is_read"
        case createdAt    = "created_at"
    }
}

// MARK: - Factory helpers (create common notification payloads)
extension AppNotification {

    static func appointmentReminder(for appointment: Appointment, patientId: String) -> AppNotification {
        AppNotification(
            recipientId: patientId,
            title: "Randevu Hatırlatması",
            body: "Yarın \(appointment.time) saatinde \(appointment.doctorName) ile randevunuz var.",
            type: .appointmentReminder,
            relatedId: appointment.id
        )
    }

    static func appointmentConfirmed(for appointment: Appointment, patientId: String) -> AppNotification {
        AppNotification(
            recipientId: patientId,
            title: "Randevunuz Onaylandı",
            body: "\(appointment.date.formatted(date: .long, time: .omitted)) tarihinde \(appointment.time) saatinde randevunuz oluşturuldu.",
            type: .appointmentConfirmed,
            relatedId: appointment.id
        )
    }

    static func appointmentCancelled(for appointment: Appointment, patientId: String) -> AppNotification {
        AppNotification(
            recipientId: patientId,
            title: "Randevunuz İptal Edildi",
            body: "\(appointment.doctorName) ile olan randevunuz iptal edildi.",
            type: .appointmentCancelled,
            relatedId: appointment.id
        )
    }
}
