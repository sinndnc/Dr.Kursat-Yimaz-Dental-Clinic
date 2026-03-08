//
//  SeedResult.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import Foundation
import FirebaseFirestore
import SwiftUI

// MARK: - Seed Result
struct SeedResult {
    var clinicsUploaded:      Int = 0
    var doctorsUploaded:      Int = 0
    var patientsUploaded:     Int = 0
    var servicesUploaded:     Int = 0
    var appointmentsUploaded: Int = 0
    var errors:               [String] = []

    var totalUploaded: Int {
        clinicsUploaded + doctorsUploaded + patientsUploaded +
        servicesUploaded + appointmentsUploaded
    }
    var hasErrors: Bool { !errors.isEmpty }

    var summary: String {
        """
        ✅ Seed tamamlandı!
        • Klinik:     \(clinicsUploaded)
        • Doktor:     \(doctorsUploaded)
        • Hasta:      \(patientsUploaded)
        • Hizmet:     \(servicesUploaded)
        • Randevu:    \(appointmentsUploaded)
        • Toplam:     \(totalUploaded)
        \(hasErrors ? "⛔️ Hatalar:\n" + errors.joined(separator: "\n") : "")
        """
    }
}

// MARK: - Seeder
@MainActor
final class MockDataSeeder: ObservableObject {

    // MARK: State
    @Published private(set) var isSeeding = false
    @Published private(set) var progress: Double = 0        // 0.0 – 1.0
    @Published private(set) var currentStep = ""
    @Published private(set) var lastResult: SeedResult?

    // MARK: Private
    private let db = Firestore.firestore()

    /// Firestore key used to track whether seeding was already done
    private let seedFlagCollection = "app_meta"
    private let seedFlagDocument   = "seed_status"

    // =========================================================================
    // MARK: - Public entry point
    // =========================================================================

    /// Upload all mock data. Pass `force: true` to re-seed even if already done.
    func seedAll(force: Bool = false) async {
        guard !isSeeding else { return }

        isSeeding = true
        progress  = 0
        var result = SeedResult()

        do {
            // Guard: skip if already seeded (unless forced)
            if !force, await isAlreadySeeded() {
                currentStep = "Zaten seed edilmiş. force: true ile zorlayabilirsiniz."
                isSeeding = false
                return
            }

            let totalSteps: Double = 5

            // 1. Clinics (no dependencies)
            currentStep = "Klinikler yükleniyor…"
            result.clinicsUploaded = try await uploadClinics()
            progress = 1 / totalSteps

            // 2. Doctors (reference clinic IDs)
            currentStep = "Doktorlar yükleniyor…"
            result.doctorsUploaded = try await uploadDoctors()
            progress = 2 / totalSteps

            // 3. Patients (independent)
            currentStep = "Hastalar yükleniyor…"
            result.patientsUploaded = try await uploadPatients()
            progress = 3 / totalSteps

            // 4. Services (independent)
            currentStep = "Hizmetler yükleniyor…"
            result.servicesUploaded = try await uploadServices()
            progress = 4 / totalSteps

            // 5. Appointments (reference all above)
            currentStep = "Randevular yükleniyor…"
            result.appointmentsUploaded = try await uploadAppointments()
            progress = 5 / totalSteps

            // Mark seeded
            try await markAsSeeded()
            currentStep = "Tamamlandı 🎉"

        } catch {
            result.errors.append(error.localizedDescription)
            currentStep = "Hata: \(error.localizedDescription)"
        }

        lastResult = result
        isSeeding  = false
        print(result.summary)
    }

    // =========================================================================
    // MARK: - Per-collection upload
    // =========================================================================

    @discardableResult
    func uploadClinics() async throws -> Int {
        try await batchUpload(MockClinics.all,
                              to: "clinics",
                              idKeyPath: \.id)
    }

    @discardableResult
    func uploadDoctors() async throws -> Int {
        try await batchUpload(MockDoctors.all,
                              to: "doctors",
                              idKeyPath: \.id)
    }

    @discardableResult
    func uploadPatients() async throws -> Int {
        try await batchUpload(MockPatients.all,
                              to: "patients",
                              idKeyPath: \.id)
    }

    @discardableResult
    func uploadServices() async throws -> Int {
        try await batchUpload(MockServices.all,
                              to: "services",
                              idKeyPath: \.id)
    }

    @discardableResult
    func uploadAppointments() async throws -> Int {
        try await batchUpload(MockAppointments.all,
                              to: "appointments",
                              idKeyPath: \.id)
    }

    // =========================================================================
    // MARK: - Delete all mock data (useful for reset)
    // =========================================================================

    func deleteAllMockData() async throws {
        currentStep = "Mock veriler siliniyor…"
        isSeeding   = true
        defer { isSeeding = false }

        try await deleteDocs(ids: MockClinics.all.compactMap(\.id),      from: "clinics")
        try await deleteDocs(ids: MockDoctors.all.compactMap(\.id),      from: "doctors")
        try await deleteDocs(ids: MockPatients.all.compactMap(\.id),     from: "patients")
        try await deleteDocs(ids: MockServices.all.map(\.id),            from: "services")
        try await deleteDocs(ids: MockAppointments.all.compactMap(\.id), from: "appointments")
        try await clearSeedFlag()

        currentStep = "Mock veriler silindi ✅"
    }

    // =========================================================================
    // MARK: - Private helpers
    // =========================================================================

    /// Generic batch-upload using Firestore batch writes (max 500 per batch).
    /// `idKeyPath` extracts the stable document ID from each model.
    private func batchUpload<T: Encodable>(
        _ items: [T],
        to collection: String,
        idKeyPath: KeyPath<T, String?>
    ) async throws -> Int {
        guard !items.isEmpty else { return 0 }

        // Firestore limit: 500 writes per batch
        let chunks = items.chunked(into: 499)
        var uploaded = 0

        for chunk in chunks {
            let batch = db.batch()
            for item in chunk {
                guard let docId = item[keyPath: idKeyPath] else { continue }
                let ref = db.collection(collection).document(docId)
                try batch.setData(from: item, forDocument: ref, merge: false)
                uploaded += 1
            }
            try await batch.commit()
        }
        return uploaded
    }

    /// Overload for models with non-optional id (e.g. DentalService)
    private func batchUpload<T: Encodable>(
        _ items: [T],
        to collection: String,
        idKeyPath: KeyPath<T, String>
    ) async throws -> Int {
        guard !items.isEmpty else { return 0 }

        let chunks = items.chunked(into: 499)
        var uploaded = 0

        for chunk in chunks {
            let batch = db.batch()
            for item in chunk {
                let docId = item[keyPath: idKeyPath]
                let ref = db.collection(collection).document(docId)
                try batch.setData(from: item, forDocument: ref, merge: false)
                uploaded += 1
            }
            try await batch.commit()
        }
        return uploaded
    }

    private func deleteDocs(ids: [String], from collection: String) async throws {
        guard !ids.isEmpty else { return }
        let chunks = ids.chunked(into: 499)
        for chunk in chunks {
            let batch = db.batch()
            for id in chunk {
                let ref = db.collection(collection).document(id)
                batch.deleteDocument(ref)
            }
            try await batch.commit()
        }
    }

    // MARK: Seed flag

    private func isAlreadySeeded() async -> Bool {
        let doc = try? await db
            .collection(seedFlagCollection)
            .document(seedFlagDocument)
            .getDocument()
        return doc?.exists ?? false
    }

    private func markAsSeeded() async throws {
        try await db
            .collection(seedFlagCollection)
            .document(seedFlagDocument)
            .setData(["seeded_at": Timestamp(date: Date()),
                      "version": "1.0"])
    }

    private func clearSeedFlag() async throws {
        try await db
            .collection(seedFlagCollection)
            .document(seedFlagDocument)
            .delete()
    }
}

// MARK: - Array chunk helper
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
