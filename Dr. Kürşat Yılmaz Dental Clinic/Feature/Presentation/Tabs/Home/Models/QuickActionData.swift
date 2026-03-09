//
//  QuickActionData.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation
import SwiftUI

struct QuickActionData{
    
    
    static let items: [QuickAction] = [
        QuickAction(title: "Randevu\nAl",       icon: "calendar.badge.plus",        color: Color.kyAccent),
        QuickAction(title: "Tedavi\nBilgisi",   icon: "cross.case.fill",             color: Color(red: 0.4, green: 0.75, blue: 0.65)),
        QuickAction(title: "Galeri",            icon: "photo.stack.fill",            color: Color(red: 0.55, green: 0.45, blue: 0.85)),
        QuickAction(title: "İletişim",          icon: "phone.fill",                  color: Color(red: 0.3, green: 0.60, blue: 0.90)),
    ]
}
