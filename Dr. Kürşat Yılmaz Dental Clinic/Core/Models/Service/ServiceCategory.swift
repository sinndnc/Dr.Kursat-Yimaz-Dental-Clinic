//
//  ServiceCategory.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//


enum ServiceCategory: String, CaseIterable, Identifiable,Codable {
    case restorative = "Restoratif"
    case aesthetic = "Estetik Gülüş"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .aesthetic: return "sparkles"
        case .restorative: return "cross.circle"
        }
    }
}
