//
//  ProfileMenuItem.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import SwiftUI

struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let route: ProfileDestination
    let subtitle: String?
    let icon: String
    let color: Color
    let trailingText: String?
    let isDestructive: Bool
    let hasChevron: Bool
}
