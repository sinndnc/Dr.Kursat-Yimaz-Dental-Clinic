//
//  DoctorViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
import Combine
import SwiftUI
import FirebaseFirestore

@MainActor
final class DoctorViewModel: ObservableObject {

    @Published private(set) var doctors: [Doctor] = []
    @Published private(set) var filteredDoctors: [Doctor] = []
    @Published var selectedDoctor: Doctor?
    @Published var searchQuery: String = "" {
        didSet { applyFilter() }
    }
    @Published var selectedSpecialty: String? = nil {
        didSet { applyFilter() }
    }
    @Published var selectedClinicId: String? = nil {
        didSet { applyFilter() }
    }
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { startListener() }
    deinit { listener?.remove() }

    // MARK: Computed
    var allSpecialties: [String] {
        Array(Set(doctors.map(\.specialty))).sorted()
    }

    var hasActiveFilter: Bool {
        selectedSpecialty != nil || selectedClinicId != nil || !searchQuery.isEmpty
    }

    // MARK: Listener
    private func startListener() {
        isLoading = true
        listener = db.collection("doctors")
            .whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error { self.errorMessage = error.localizedDescription; return }
                do {
                    self.doctors = try snapshot?.documents
                        .compactMap { try $0.data(as: Doctor.self) } ?? []
                    self.applyFilter()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    // MARK: Filter
    private func applyFilter() {
        var result = doctors

        if let clinicId = selectedClinicId {
            result = result.filter { $0.clinicIds.contains(clinicId) }
        }
        if let specialty = selectedSpecialty {
            result = result.filter { $0.specialty == specialty }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(q) ||
                $0.specialty.lowercased().contains(q)
            }
        }
        filteredDoctors = result
    }

    func clearFilters() {
        searchQuery = ""
        selectedSpecialty = nil
        selectedClinicId = nil
    }

    /// Returns true if the doctor works on the given day (uses Turkish day names)
    func isAvailable(_ doctor: Doctor, on date: Date) -> Bool {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "EEEE"
        let dayName = fmt.string(from: date).capitalized
        return doctor.availableDays.contains(dayName)
    }

    /// Doctors who are available on a specific date
    func availableDoctors(on date: Date) -> [Doctor] {
        doctors.filter { isAvailable($0, on: date) }
    }

    func doctor(withId id: String) -> Doctor? {
        doctors.first { $0.id == id }
    }
}
