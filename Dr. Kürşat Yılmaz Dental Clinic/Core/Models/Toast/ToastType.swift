//
//  ToastType.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//
import SwiftUI
import Foundation

public enum ToastType {
    case success
    case error
    case warning
    case info
    case loading
    case custom(icon: String, color: Color)
 
    var icon: String {
        switch self {
        case .success:              return "checkmark.circle.fill"
        case .error:                return "xmark.circle.fill"
        case .warning:              return "exclamationmark.triangle.fill"
        case .info:                 return "info.circle.fill"
        case .loading:              return "arrow.2.circlepath"
        case .custom(let icon, _):  return icon
        }
    }
 
    var color: Color {
        switch self {
        case .success:              return Color(hex: "22C55E")
        case .error:                return Color(hex: "EF4444")
        case .warning:              return Color(hex: "F59E0B")
        case .info:                 return Color(hex: "3B82F6")
        case .loading:              return Color(hex: "8B5CF6")
        case .custom(_, let color): return color
        }
    }
}
 
