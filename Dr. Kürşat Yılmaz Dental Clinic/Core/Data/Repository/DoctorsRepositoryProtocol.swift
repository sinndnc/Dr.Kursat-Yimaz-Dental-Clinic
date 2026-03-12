//
//  DoctorsRepository.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//
//  Responsibilities:
//  ─────────────────────────────────────────────────────────────────────
//  • Combines Firestore (doctor metadata) + Supabase Storage (photos)
//  • Emits a reactive stream of [EnrichedDoctor] via Combine
//  • Photo enrichment is concurrent — all doctors fetched in parallel
//  • Graceful degradation: photo failure never blocks doctor listing
//  • Cache layer: avoids redundant Supabase HEAD checks per session
//  ─────────────────────────────────────────────────────────────────────

import Combine
import Foundation
import UIKit
import SwiftUI

struct EnrichedDoctor: Identifiable, Equatable,Hashable {
    let doctor: Doctor
    
    let photoURLs: [URL]
    
    var primaryPhotoURL: URL? { photoURLs.first }
    
    var id: String { doctor.id ?? "" }
    
    static func == (lhs: EnrichedDoctor, rhs: EnrichedDoctor) -> Bool {
        lhs.id == rhs.id && lhs.photoURLs == rhs.photoURLs
    }
    
    var name:             String      { doctor.name }
    var bio:             String      { doctor.bio }
    var education: [DoctorEducation] { doctor.education }
    var title:            String      { doctor.title }
    var specialty:        String      { doctor.specialty }
    var tagline:          String      { doctor.tagline }
    var experience:       String      { doctor.experience }
    var patientCount:     String      { doctor.patientCount }
    var satisfactionRate: String      { doctor.satisfactionRate }
    var languages:        [String]    { doctor.languages }
    var expertise:        [DoctorExpertise] { doctor.expertise }
    var availableDays:    [String]    { doctor.availableDays }
    var clinicIds:        [String]    { doctor.clinicIds }
    var accentColor:      Color       { doctor.accentColor }
    var avatarInitials:   String      { doctor.avatarInitials }
}


protocol DoctorsRepositoryProtocol: AnyObject {
    
    /// Continuous stream — updates whenever Firestore or photo cache changes.
    var enrichedDoctorsPublisher: AnyPublisher<[EnrichedDoctor], Never> { get }
    
    /// Force-refresh photo URLs for a specific doctor (e.g. after profile edit).
    func refreshPhotos(for doctorId: String) async
    
    /// Single-shot fetch — useful for detail screens.
    func fetchEnrichedDoctor(id: String) async throws -> EnrichedDoctor
    
    /// Pre-warms photo cache for a set of IDs in parallel.
    func prefetchPhotos(for doctorIds: [String]) async
}

// MARK: - Implementation

final class DoctorsRepository: DoctorsRepositoryProtocol {
    
    // MARK: Dependencies
    private let firestoreService: FirestoreServiceProtocol
    private let storageService:   SupabaseStorageServiceProtocol
    
    // MARK: Config
    private let maxPhotosPerDoctor: Int
    private let photoIndexRange: Range<Int>
    
    // MARK: Internals
    private var cancellables = Set<AnyCancellable>()
    
    /// In-memory URL cache: doctorId → [URL]
    /// Actor-isolated to prevent data races.
    private let cache = PhotoURLCache()
    
    // MARK: Output
    private let enrichedSubject = CurrentValueSubject<[EnrichedDoctor], Never>([])
    
    var enrichedDoctorsPublisher: AnyPublisher<[EnrichedDoctor], Never> {
        enrichedSubject.eraseToAnyPublisher()
    }
    
    // MARK: Init
    
    init(
        firestoreService:  FirestoreServiceProtocol,
        storageService:    SupabaseStorageServiceProtocol,
        maxPhotosPerDoctor: Int = 3
    ) {
        self.firestoreService   = firestoreService
        self.storageService     = storageService
        self.maxPhotosPerDoctor = maxPhotosPerDoctor
        self.photoIndexRange    = 0..<maxPhotosPerDoctor
        
        bindFirestore()
    }
    
    // MARK: - Binding
    
    private func bindFirestore() {
        firestoreService.doctorsStatePublisher
            .removeDuplicates()
            .sink { [weak self] doctors in
                guard let self else { return }
                Task { await self.enrich(doctors: doctors) }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Enrichment
    
    /// Concurrently resolves photo URLs for all doctors,
    /// then emits the full enriched list.
    private func enrich(doctors: [Doctor]) async {
        let enriched: [EnrichedDoctor] = await withTaskGroup(
            of: EnrichedDoctor.self
        ) { group in
            for doctor in doctors {
                group.addTask { [weak self] in
                    guard let self, let id = doctor.id else {
                        return EnrichedDoctor(doctor: doctor, photoURLs: [])
                    }
                    let urls = await self.resolvePhotoURLs(for: id)
                    return EnrichedDoctor(doctor: doctor, photoURLs: urls)
                }
            }
            
            var results: [EnrichedDoctor] = []
            for await enrichedDoctor in group {
                results.append(enrichedDoctor)
            }
            
            return results.sorted {x,y in
                guard let lIdx = doctors.firstIndex(where: { _ in x.id == y.id }),
                      let rIdx = doctors.firstIndex(where: { _ in x.id == y.id })
                else { return false }
                return lIdx < rIdx
            }
        }
        
        enrichedSubject.send(enriched)
    }
    
    private func resolvePhotoURLs(for doctorId: String) async -> [URL] {
        if let cached = await cache.urls(for: doctorId) {
            return cached
        }
        
        // Build candidate paths and resolve public URLs
        let urls: [URL] = photoIndexRange.compactMap { index in
            storageService.getPublicURL(
                bucket: .doctors,
                path: "\(doctorId)/photo_\(index).jpg"
            )
        }
        
        // Validate which URLs actually exist (HEAD request)
        let validURLs = await validateURLs(urls)
        await cache.set(validURLs, for: doctorId)
        return validURLs
    }
    
    /// HEAD-checks each candidate URL concurrently.
    /// Non-existent / error responses are filtered out.
    private func validateURLs(_ urls: [URL]) async -> [URL] {
        await withTaskGroup(of: (URL, Bool).self) { group in
            for url in urls {
                group.addTask {
                    let exists = await Self.headCheck(url: url)
                    return (url, exists)
                }
            }
            var valid: [URL] = []
            for await (url, exists) in group where exists {
                valid.append(url)
            }
            // Restore index order (photo_0, photo_1 …)
            return valid.sorted { $0.absoluteString < $1.absoluteString }
        }
    }
    
    private static func headCheck(url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Public API
    
    func refreshPhotos(for doctorId: String) async {
        await cache.invalidate(for: doctorId)
        
        // Re-emit with fresh photo data
        var current = enrichedSubject.value
        guard let idx = current.firstIndex(where: { $0.id == doctorId }) else { return }
        
        let urls  = await resolvePhotoURLs(for: doctorId)
        let fresh = EnrichedDoctor(doctor: current[idx].doctor, photoURLs: urls)
        current[idx] = fresh
        enrichedSubject.send(current)
    }
    
    func fetchEnrichedDoctor(id: String) async throws -> EnrichedDoctor {
        let doctor = try await firestoreService.fetchDoctor(id: id)
        let urls   = await resolvePhotoURLs(for: id)
        return EnrichedDoctor(doctor: doctor, photoURLs: urls)
    }
    
    func prefetchPhotos(for doctorIds: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for id in doctorIds {
                group.addTask { [weak self] in
                    _ = await self?.resolvePhotoURLs(for: id)
                }
            }
        }
    }
}

// MARK: - Photo URL Cache (Actor)

/// Thread-safe in-memory cache scoped to the app session.
private actor PhotoURLCache {
    private var store: [String: [URL]] = [:]
    
    func urls(for doctorId: String) -> [URL]? {
        store[doctorId]
    }
    
    func set(_ urls: [URL], for doctorId: String) {
        store[doctorId] = urls
    }
    
    func invalidate(for doctorId: String) {
        store.removeValue(forKey: doctorId)
    }
    
    func invalidateAll() {
        store.removeAll()
    }
}
