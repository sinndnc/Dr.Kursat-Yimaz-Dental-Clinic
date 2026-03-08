//
//  ServiceCategory.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//


// MARK: - DentalService.swift
// Production-level DentalService model for Firestore

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - ServiceCategory
enum ServiceCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case restorative = "Restoratif"
    case aesthetic   = "Estetik Gülüş"
//    case surgical    = "Cerrahi"
//    case preventive  = "Önleyici"
//    case pediatric   = "Pedodonti"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .aesthetic:  return "sparkles"
        case .restorative: return "cross.circle"
//        case .surgical:   return "scalpel"
//        case .preventive: return "shield.checkered"
//        case .pediatric:  return "figure.and.child.holdinghands"
        }
    }

    var colorName: String {
        switch self {
        case .aesthetic:  return "yellow"
        case .restorative: return "blue"
//        case .surgical:   return "red"
//        case .preventive: return "green"
//        case .pediatric:  return "orange"
        }
    }

    var color: Color { Color(colorName: colorName) }
}

struct Service: Identifiable, Codable, Hashable {
    
    /// String-based stable ID for Firestore
    var id: String
    
    var category: ServiceCategory
    var title: String
    var subtitle: String
    var description: String
    var tags: [String]
    var badgeText: String?
    var sfSymbol: String
    var colorName: String         // ✅ real field, drives accentColor
    var details: [ServiceDetail]
    var isActive: Bool

    // MARK: UI-only
    var accentColor: Color { Color(colorName: colorName) }

    init(
        id: String = UUID().uuidString,
        category: ServiceCategory,
        title: String,
        subtitle: String,
        description: String,
        tags: [String] = [],
        badgeText: String? = nil,
        sfSymbol: String,
        colorName: String = "blue",
        details: [ServiceDetail] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.badgeText = badgeText
        self.sfSymbol = sfSymbol
        self.colorName = colorName
        self.details = details
        self.isActive = isActive
    }

    enum CodingKeys: String, CodingKey {
        case id, category, title, subtitle, description
        case tags
        case badgeText  = "badge_text"
        case sfSymbol   = "sf_symbol"
        case colorName  = "color_name"
        case details
        case isActive   = "is_active"
    }
}

// MARK: - ServiceDetail
struct ServiceDetail: Identifiable, Codable, Hashable {

    var id: String
    var heading: String
    var bullets: [String]

    init(id: String = UUID().uuidString,
         heading: String,
         bullets: [String] = []) {
        self.id = id
        self.heading = heading
        self.bullets = bullets
    }
}
