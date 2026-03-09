//
//  AppointmentStatus.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI
import Foundation

enum AppointmentStatus: String, CaseIterable {
    case upcoming  = "Yaklaşan"
    case completed = "Tamamlanan"
    case cancelled = "İptal"

    var color: Color {
        switch self {
        case .upcoming:  return Color(red: 0.4,  green: 0.78, blue: 0.50)
        case .completed: return Color(red: 0.82, green: 0.72, blue: 0.50)
        case .cancelled: return Color(red: 0.85, green: 0.38, blue: 0.38)
        }
    }

    var icon: String {
        switch self {
        case .upcoming:  return "clock.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}
