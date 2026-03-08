//
//  NotificationItem.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import FirebaseFirestore
import Foundation
import SwiftUI

struct NotificationItem: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var message: String
    var typeName: String
    var isRead: Bool
    var createdAt: Date?
    
    enum NotificationType: String {
        case reminder, result, promotion, info
        var icon: String {
            switch self {
            case .reminder:  return "bell.fill"
            case .result:    return "doc.text.fill"
            case .promotion: return "gift.fill"
            case .info:      return "info.circle.fill"
            }
        }
        var color: Color {
            switch self {
            case .reminder:  return .orange
            case .result:    return .blue
            case .promotion: return .purple
            case .info:      return .green
            }
        }
    }
    
    var notifType: NotificationType { NotificationType(rawValue: typeName) ?? .info }
    
    var timeAgo: String {
        guard let date = createdAt else { return "" }
        let diff = Date().timeIntervalSince(date)
        if diff < 3600  { return "\(Int(diff / 60)) dakika önce" }
        if diff < 86400 { return "\(Int(diff / 3600)) saat önce" }
        return "\(Int(diff / 86400)) gün önce"
    }
}
