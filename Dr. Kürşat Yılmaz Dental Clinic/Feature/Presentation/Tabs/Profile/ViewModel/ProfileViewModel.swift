//
//  ProfileViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Combine
import SwiftUI
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    
    
    @Injected private var auth: AuthServiceProtocol
    @Injected private var storage: SupabaseStorageServiceProtocol
    @Injected private var firestore: FirestoreServiceProtocol
    
    @Published var patient: Patient? = nil
    @Published var appointments: [Appointment] = []
    @Published var treatments: [ToothTreatment] = []
    @Published var documents: [PatientDocument] = []
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
    @Published var profilePhotoURL: URL? = nil
    
    var pendingPhoto: UIImage?
    var isUploading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        firestore.appointmentsPublisher
            .assign(to: &$appointments)
        
        auth.currentPatientPublisher
            .assign(to: &$patient)
    }
    
    func loadPatientImage(id: String) async {
        isLoading = true
        do {
            let path = "A88BE787-507A-4D83-A2DA-ED7199885724/photo_0.jpg"
            let url = try await storage.getPublicURL(
                bucket: .patients,
                path: path
            )
            self.profilePhotoURL = url
        } catch {
        }
        
        isLoading = false
    }
    
    func uploadPhoto(_ image: UIImage) async throws {
        guard let id = patient?.id else { return }
        let path = try await storage.uploadProfilePhoto(patientID: id, image: image)
        try await firestore.updatePatientField("profile_photo_path", value: path, patientID: id)
        patient?.profilePhotoPath = path
        pendingPhoto = nil
    }
    
    func signOut(){
        do {
            try auth.signOut()
        } catch(let error) {
            Logger.log("\(error)")
        }
    }
   
    var activeTreatments: [ToothTreatment] {
        treatments.filter { $0.status == .active }
    }
    
    
    var completedAppointments: [Appointment] {
        appointments.filter { $0.status == .completed }
    }
    
}
