//
//  AuthViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var currentPatient: Patient? = nil
    
    @Injected private var authService: AuthServiceProtocol
    @Injected private var firestoreService: FirestoreServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        bindToAuthService()
    }
    
    private func bindToAuthService() {
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .loading,.registrationPending,.unauthenticated:
                    self.authState = state
                case .authenticated:
                    self.authState = state
                    self.firestoreService
                        .startListeners(
                            patientId: self.authService.currentUID,
                            clinicId: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
                        )
                }
            }
            .store(in: &cancellables)
        
        authService.currentPatientPublisher
            .assign(to: &$currentPatient)
        
        authService.isLoadingPublisher
            .assign(to: &$isLoading)
        
        authService.errorMessagePublisher
            .assign(to: &$errorMessage)
    }
    
    var isAuthenticated: Bool { authState == .authenticated }
    
    // MARK: - Actions
    
    func signIn(email: String, password: String) async {
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func register(
        email:     String,
        password:  String,
        firstName: String,
        lastName:  String,
        phone:     String?         = nil,
        birthDate: Date?           = nil,
        gender:    Patient.Gender? = nil
    ) async {
        do {
            try await authService.register(
                email:     email,
                password:  password,
                firstName: firstName,
                lastName:  lastName,
                phone:     phone,
                birthDate: birthDate,
                gender:    gender
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendPasswordReset(to email: String) async {
        do {
            try await authService.sendPasswordReset(to: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateCurrentPatient(_ patient: Patient) async {
        do {
            try await authService.updateCurrentPatient(patient)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async {
        do {
            try await authService.changePassword(
                currentPassword: currentPassword,
                newPassword:     newPassword
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
