//
//  TechItem.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation

struct TechItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let badge: String?
}
