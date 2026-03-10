//
//  ProfileViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Combine
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    
    
    @Injected private var auth: AuthServiceProtocol
    @Injected private var firestore: FirestoreServiceProtocol
    
    @Published var patient: Patient? = nil
    @Published var appointments: [Appointment] = []
    @Published var payments: [Payment] = mockPayments
    @Published var treatments: [ToothTreatment] = mockTreatments
    @Published var documents: [PatientDocument] = mockDocuments
    @Published var isLoading = false
    
    // Notification preferences
    @Published var pushEnabled = true
    @Published var smsEnabled = true
    @Published var whatsappEnabled = false
    @Published var emailNotifications = true
    @Published var campaignNotifications = false
    @Published var birthdayMessages = true
    @Published var appointmentReminder24h = true
    @Published var appointmentReminder1h = true
    
    // App preferences
    @Published var appeared = false
    @Published var selectedLanguage = "TR"
    @Published var isDarkMode = true
    @Published var biometricEnabled = false
    
    init(){
        firestore.appointmentsPublisher
            .assign(to: &$appointments)
        
        auth.currentPatientPublisher
            .assign(to: &$patient)
    }
    
    func signOut(){
        do {
            try auth.signOut()
        } catch(let error) {
            Logger.log("\(error)")
        }
    }
    
    var totalDebt: Double {
        payments.filter { $0.status == .pending || $0.status == .overdue }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalPaid: Double {
        payments.filter { $0.status == .paid }
            .reduce(0) { $0 + $1.amount }
    }
    
    var activeTreatments: [ToothTreatment] {
        treatments.filter { $0.status == .active }
    }
    
    var upcomingAppointments: [Appointment] {
        appointments.upcoming
    }
    
    var nextAppointment: Appointment? {
        appointments.next
    }
    
    var completedAppointments: [Appointment] {
        appointments.filter { $0.status == .completed }
    }
    
}
