//
//  AppointmentFilter.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import Foundation

enum AppointmentFilter: String, CaseIterable {
    case all = "Tümü"; case upcoming = "Yaklaşan"; case completed = "Geçmiş"
}
