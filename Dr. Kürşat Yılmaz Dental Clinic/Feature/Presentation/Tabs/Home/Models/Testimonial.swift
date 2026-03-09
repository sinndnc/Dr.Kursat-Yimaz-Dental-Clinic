//
//  Testimonial.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation
import SwiftUI

struct Testimonial: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let text: String
    let rating: Int
    let treatment: String
    let avatarColor: Color
}
