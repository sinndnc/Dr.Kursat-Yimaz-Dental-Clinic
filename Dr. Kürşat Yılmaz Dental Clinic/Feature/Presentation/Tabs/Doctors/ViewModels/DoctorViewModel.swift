//
//  DoctorsViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//
//  Architecture: MVVM + Repository pattern
//  ─────────────────────────────────────────────────────────────────────
//  • Consumes DoctorsRepository (Firestore + Supabase combined stream)
//  • Owns all UI state: filtering, search, sheet presentation, loading
//  • Never touches networking directly — all data via repository
//  • Fully @MainActor — safe to bind directly to SwiftUI
//  ─────────────────────────────────────────────────────────────────────

import Combine
import SwiftUI

@MainActor
final class DoctorsViewModel: ObservableObject {
    
    @Injected private var repository: DoctorsRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var doctors: [EnrichedDoctor] = []
    @Published private(set) var filteredDoctors: [EnrichedDoctor] = []
    
    @Published var searchQuery: String = "" {
        didSet { applyFilter() }
    }
    @Published var selectedSpecialty: String? = nil {
        didSet { applyFilter() }
    }
    @Published var selectedClinicId: String? = nil {
        didSet { applyFilter() }
    }
    
    @Published var errorMessage: String? = nil
    @Published var selectedDoctor: EnrichedDoctor? = nil
    @Published private(set) var isLoadingPhotos = false
    
    var allSpecialties: [String] {
        Array(Set(doctors.map(\.specialty))).sorted()
    }
    
    var hasActiveFilter: Bool {
        selectedSpecialty != nil
        || selectedClinicId != nil
        || !searchQuery.isEmpty
    }
    
    var isEmpty: Bool { filteredDoctors.isEmpty }
    
    init() {
        bindRepository()
    }
    
    private func bindRepository() {
        repository.enrichedDoctorsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enriched in
                guard let self else { return }
                
                let isFirstLoad = self.doctors.isEmpty && !enriched.isEmpty
                self.doctors = enriched
                self.applyFilter()
                
                // Silently refresh selected doctor if sheet is open
                if let current = self.selectedDoctor,
                   let updated = enriched.first(where: { $0.id == current.id }) {
                    self.selectedDoctor = updated
                }
                
                if isFirstLoad {
                    Task { await self.prefetchIfNeeded(enriched) }
                }
            }
            .store(in: &cancellables)
    }
    
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
        searchQuery      = ""
        selectedSpecialty = nil
        selectedClinicId  = nil
    }
    
    func isAvailable(_ doctor: EnrichedDoctor, on date: Date) -> Bool {
        let fmt = DateFormatter()
        fmt.locale     = Locale(identifier: "tr_TR")
        fmt.dateFormat = "EEEE"
        let dayName = fmt.string(from: date).capitalized
        return doctor.availableDays.contains(dayName)
    }
    
    /// Doctors available on a specific date (unfiltered by search/specialty).
    func availableDoctors(on date: Date) -> [EnrichedDoctor] {
        doctors.filter { isAvailable($0, on: date) }
    }
    
    func doctor(withId id: String) -> EnrichedDoctor? {
        doctors.first { $0.id == id }
    }
    
    // MARK: - Photo Actions
    
    /// Call after uploading a new photo for a doctor (admin flow).
    func refreshPhoto(for doctorId: String) {
        Task {
            isLoadingPhotos = true
            defer { isLoadingPhotos = false }
            await repository.refreshPhotos(for: doctorId)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Pre-fetches photos for doctors beyond the first screen (index > 3).
    private func prefetchIfNeeded(_ enriched: [EnrichedDoctor]) async {
        let idsWithoutPhotos = enriched
            .filter { $0.photoURLs.isEmpty }
            .map(\.id)
        
        guard !idsWithoutPhotos.isEmpty else { return }
        
        isLoadingPhotos = true
        await repository.prefetchPhotos(for: idsWithoutPhotos)
        isLoadingPhotos = false
    }
}
