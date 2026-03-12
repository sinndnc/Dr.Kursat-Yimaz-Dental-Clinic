//
//  ProfileTab.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import Foundation

enum ProfileTab: String, CaseIterable {
    case appointments = "Randevular"
    case treatments = "Tedaviler"
    case payments = "Ödemeler"
    case health = "Sağlık"
    case documents = "Belgeler"
    case settings = "Ayarlar"

    var icon: String {
        switch self {
        case .appointments: return "calendar"
        case .treatments: return "cross.case.fill"
        case .payments: return "creditcard.fill"
        case .health: return "heart.text.square.fill"
        case .documents: return "folder.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

