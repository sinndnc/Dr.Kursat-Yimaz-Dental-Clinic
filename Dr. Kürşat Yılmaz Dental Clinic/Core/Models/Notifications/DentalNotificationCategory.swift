//
//  DentalNotificationCategory.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Foundation
import SwiftUI

enum DentalNotificationCategory: String, CaseIterable {
    case appointment = "Randevu"
    case reminder    = "Hatırlatma"
    case result      = "Sonuç"
    case payment     = "Ödeme"
    case promotion   = "Kampanya"
    case system      = "Sistem"

    var icon: String {
        switch self {
        case .appointment: return "calendar.badge.clock"
        case .reminder:    return "bell.badge.fill"
        case .result:      return "cross.case.fill"
        case .payment:     return "creditcard.fill"
        case .promotion:   return "gift.fill"
        case .system:      return "gearshape.fill"
        }
    }

    var color: Color {
        switch self {
        case .appointment: return .kyBlue
        case .reminder:    return .kyOrange
        case .result:      return .kyGreen
        case .payment:     return .kyAccent
        case .promotion:   return .kyPurple
        case .system:      return .kySubtext
        }
    }

    static func from(_ type: AppNotification.NotificationType) -> DentalNotificationCategory {
        switch type {
        case .appointmentReminder, .appointmentConfirmed,
             .appointmentCancelled, .appointmentRescheduled: return .appointment
        case .treatmentPlanReady:                             return .result
        case .invoiceReady:                                   return .payment
        case .promotionOffer:                                 return .promotion
        case .generalInfo:                                    return .system
        }
    }
}
