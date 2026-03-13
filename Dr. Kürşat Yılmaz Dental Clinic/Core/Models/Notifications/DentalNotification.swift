//
//  DentalNotification.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI
import Foundation

struct DentalNotification: Identifiable, Equatable {
    let id: String
    let isRead: Bool
    let category: DentalNotificationCategory
    let title: String
    let body: String
    let date: Date
    let actionLabel: String?
    let isUrgent: Bool

    init(from app: AppNotification) {
        id       = app.id ?? UUID().uuidString
        isRead   = app.isRead
        category = DentalNotificationCategory.from(app.type)
        title    = app.title
        body     = app.body
        date     = app.createdAt
        isUrgent = app.type == .appointmentCancelled || app.type == .appointmentRescheduled

        switch app.type {
        case .appointmentReminder, .appointmentConfirmed,
             .appointmentCancelled, .appointmentRescheduled: actionLabel = "Randevuyu Gör"
        case .treatmentPlanReady:                             actionLabel = "Sonuçları İncele"
        case .invoiceReady:                                   actionLabel = "Faturayı Gör"
        case .promotionOffer:                                 actionLabel = "Kampanyayı Gör"
        default:                                              actionLabel = nil
        }
    }
}
