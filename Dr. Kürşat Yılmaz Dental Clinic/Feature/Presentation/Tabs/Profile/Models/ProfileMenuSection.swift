//
//  ProfileMenuSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation


struct ProfileMenuSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [ProfileMenuItem]
}
