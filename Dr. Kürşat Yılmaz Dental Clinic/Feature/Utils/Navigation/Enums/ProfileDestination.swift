//
//  ProfileDestination.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
import Foundation

enum ProfileDestination: Hashable {
    case auth
    case login
    case signup
    // Main tabs
    case appointments
    case treatments
    case payments
    case healthInfo
    case documents
    // Detail pages
    case treatmentDetail(id: String)
    case paymentDetail(id: String)
    case documentDetail(id: String)
    case appointmentDetail(appointment: Appointment)
    case editProfile
    case notifications
    case allergiesDetail
    case medicationsDetail
    case emergencyContacts
    case loyaltyPoints
    case privacyPolicy
    case helpSupport
}
