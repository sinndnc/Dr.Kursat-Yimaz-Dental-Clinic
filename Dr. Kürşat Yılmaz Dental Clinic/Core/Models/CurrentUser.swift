//
//  CurrentUser.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import SwiftUI
import FirebaseAuth

@MainActor
final class CurrentUser: ObservableObject {
    
    // MARK: Shared ref to AuthService
    private let auth = AuthService.shared
    
    // MARK: Published — views bind to these
    @Published private(set) var patient: Patient?
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool = false
    
    // MARK: Convenience
    var isAuthenticated: Bool       { authState == .authenticated }
    var isRegistrationPending: Bool { authState == .registrationPending }
    var fullName: String            { patient?.fullName ?? "Misafir" }
    var initials: String {
        guard let p = patient else { return "?" }
        let f = p.firstName.prefix(1).uppercased()
        let l = p.lastName.prefix(1).uppercased()
        return "\(f)\(l)"
    }
    var avatarLetter: String { patient?.firstName.prefix(1).uppercased() ?? "?" }

    // MARK: Init — observe AuthService
    init() {
        // Mirror AuthService publishers into CurrentUser
        auth.$currentPatient
            .receive(on: DispatchQueue.main)
            .assign(to: &$patient)

        auth.$authState
            .receive(on: DispatchQueue.main)
            .assign(to: &$authState)

        auth.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        auth.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
    }

    // =========================================================================
    // MARK: - Auth Actions (thin wrappers — keeps views clean)
    // =========================================================================

    func signIn(email: String, password: String) async throws {
        try await auth.signIn(email: email, password: password)
    }

    func register(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phone: String? = nil,
        birthDate: Date? = nil,
        gender: Patient.Gender? = nil
    ) async throws {
        try await auth.register(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            birthDate: birthDate,
            gender: gender
        )
    }

    func signOut() throws {
        try auth.signOut()
    }

    func sendPasswordReset(to email: String) async throws {
        try await auth.sendPasswordReset(to: email)
    }

    func updateProfile(_ updated: Patient) async throws {
        try await auth.updateCurrentPatient(updated)
    }

    func changePassword(current: String, new: String) async throws {
        try await auth.changePassword(currentPassword: current, newPassword: new)
    }

    func deleteAccount() async throws {
        try await auth.deleteAccount()
    }
}
