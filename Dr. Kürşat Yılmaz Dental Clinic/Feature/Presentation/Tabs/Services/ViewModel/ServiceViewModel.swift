//
//  ServiceViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import FirebaseAuth

// =========================================================================
// MARK: - ServiceViewModel
// Browse dental services, filter by category
// =========================================================================

@MainActor
final class ServiceViewModel: ObservableObject {

    @Published private(set) var services: [Service] = []
    @Published private(set) var filteredServices: [Service] = []
    @Published var selectedCategory: ServiceCategory? = nil {
        didSet { applyFilter() }
    }
    @Published var searchQuery: String = "" {
        didSet { applyFilter() }
    }
    @Published var selectedService: Service?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { startListener() }
    deinit { listener?.remove() }

    // MARK: Computed
    var servicesByCategory: [ServiceCategory: [Service]] {
        Dictionary(grouping: services, by: \.category)
    }

    var featuredServices: [Service] {
        services.filter { $0.badgeText != nil }
    }

    var categories: [ServiceCategory] {
        Array(Set(services.map(\.category))).sorted { $0.rawValue < $1.rawValue }
    }

    // MARK: Listener
    private func startListener() {
        isLoading = true
        listener = db.collection("dental_services")
            .whereField("is_active", isEqualTo: true)
            .order(by: "title")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error { self.errorMessage = error.localizedDescription; return }
                do {
                    self.services = try snapshot?.documents
                        .compactMap { try $0.data(as: Service.self) } ?? []
                    self.applyFilter()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    // MARK: Filter
    private func applyFilter() {
        var result = services

        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) ||
                $0.subtitle.lowercased().contains(q) ||
                $0.tags.contains { $0.lowercased().contains(q) }
            }
        }
        filteredServices = result
    }

    func clearFilter() {
        selectedCategory = nil
        searchQuery = ""
    }

    func service(withId id: String) -> Service? {
        services.first { $0.id == id }
    }
}

// =========================================================================
// MARK: - ClinicViewModel
// Customer browses clinic locations and info (read-only)
// =========================================================================

@MainActor
final class ClinicViewModel: ObservableObject {

    @Published private(set) var clinics: [Clinic] = []
    @Published var selectedClinic: Clinic?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { startListener() }
    deinit { listener?.remove() }

    private func startListener() {
        isLoading = true
        listener = db.collection("clinics")
            .whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error { self.errorMessage = error.localizedDescription; return }
                do {
                    self.clinics = try snapshot?.documents
                        .compactMap { try $0.data(as: Clinic.self) } ?? []
                    // Auto-select first clinic if none selected
                    if self.selectedClinic == nil {
                        self.selectedClinic = self.clinics.first
                    }
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    func clinic(withId id: String) -> Clinic? {
        clinics.first { $0.id == id }
    }
}

// =========================================================================
// MARK: - ProfileViewModel
// Patient views and edits their own profile
// =========================================================================

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: Form state (bound to edit sheet fields)
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phone: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: Patient.Gender? = nil
    @Published var bloodType: Patient.BloodType? = nil
    @Published var allergiesText: String = ""       // comma-separated input
    @Published var chronicDiseasesText: String = "" // comma-separated input
    @Published var smoking: Bool = false
    @Published var tcKimlikNo: String = ""
    @Published var notes: String = ""

    // MARK: UI state
    @Published var isEditing: Bool = false
    @Published private(set) var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showDeleteAccountAlert = false

    // MARK: Source of truth
    @Injected private var authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Whenever the patient profile updates (real-time), sync form fields
        authService.currentPatientPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] patient in
                self?.populateForm(from: patient)
            }
            .store(in: &cancellables)
    }

    // MARK: Computed
    var currentPatient: Patient? { authService.currentPatient }
    var fullName: String { currentPatient?.fullName ?? "" }
    var initials: String {
        guard let p = currentPatient else { return "?" }
        return "\(p.firstName.prefix(1))\(p.lastName.prefix(1))".uppercased()
    }
    var email: String { authService.currentPatient?.email ?? "" }
    var hasChanges: Bool {
        guard let p = currentPatient else { return false }
        return firstName != p.firstName || lastName != p.lastName ||
               phone != (p.phone ?? "") || gender != p.gender ||
               bloodType != p.bloodType || smoking != p.smoking ||
               tcKimlikNo != (p.tcKimlikNo ?? "") || notes != (p.notes ?? "") ||
               allergiesAsArray != p.allergies ||
               chronicDiseasesAsArray != p.chronicDiseases
    }

    // MARK: Helpers
    private var allergiesAsArray: [String] {
        allergiesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
    private var chronicDiseasesAsArray: [String] {
        chronicDiseasesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    // MARK: Populate form from Patient
    private func populateForm(from patient: Patient) {
        firstName           = patient.firstName
        lastName            = patient.lastName
        phone               = patient.phone ?? ""
        birthDate           = patient.birthDate ?? Date()
        gender              = patient.gender
        bloodType           = patient.bloodType
        allergiesText       = patient.allergies.joined(separator: ", ")
        chronicDiseasesText = patient.chronicDiseases.joined(separator: ", ")
        smoking             = patient.smoking
        tcKimlikNo          = patient.tcKimlikNo ?? ""
        notes               = patient.notes ?? ""
    }

    func startEditing() { isEditing = true }
    func cancelEditing() {
        isEditing = false
        if let p = currentPatient { populateForm(from: p) }  // reset unsaved changes
        errorMessage = nil
    }

    // MARK: Validate
    private func validate() -> [String] {
        var errors: [String] = []
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty { errors.append("Ad boş bırakılamaz.") }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty  { errors.append("Soyad boş bırakılamaz.") }
        if !phone.isEmpty && phone.count < 10                     { errors.append("Geçerli bir telefon numarası girin.") }
        if !tcKimlikNo.isEmpty && tcKimlikNo.count != 11          { errors.append("TC Kimlik No 11 haneli olmalıdır.") }
        return errors
    }

    // MARK: Save
    func saveProfile() async {
        let errors = validate()
        guard errors.isEmpty else { errorMessage = errors.joined(separator: "\n"); return }
        guard var patient = currentPatient else { return }

        isSaving = true
        defer { isSaving = false }

        patient.firstName        = firstName.trimmingCharacters(in: .whitespaces)
        patient.lastName         = lastName.trimmingCharacters(in: .whitespaces)
        patient.phone            = phone.isEmpty ? nil : phone
        patient.birthDate        = birthDate
        patient.gender           = gender
        patient.bloodType        = bloodType
        patient.allergies        = allergiesAsArray
        patient.chronicDiseases  = chronicDiseasesAsArray
        patient.smoking          = smoking
        patient.tcKimlikNo       = tcKimlikNo.isEmpty ? nil : tcKimlikNo
        patient.notes            = notes.isEmpty ? nil : notes

        do {
            try await authService.updateCurrentPatient(patient)
            successMessage = "Profiliniz güncellendi ✅"
            isEditing = false
        } catch {
            errorMessage = "Güncelleme başarısız: \(error.localizedDescription)"
        }
    }

    // MARK: Change Password
    func changePassword(current: String, new: String, confirm: String) async {
        guard new == confirm else { errorMessage = "Yeni şifreler eşleşmiyor."; return }
        guard new.count >= 6 else { errorMessage = "Şifre en az 6 karakter olmalıdır."; return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await authService.changePassword(currentPassword: current, newPassword: new)
            successMessage = "Şifreniz başarıyla değiştirildi."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Sign Out
    func signOut() {
        try? authService.signOut()
    }

    // MARK: Delete Account
    func deleteAccount() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = "Hesap silinemedi: \(error.localizedDescription)"
        }
    }
}
