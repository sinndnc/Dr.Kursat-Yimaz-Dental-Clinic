//
//  FSCollection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreService: ObservableObject {
    
    static let shared = FirestoreService()
    
    private let db: Firestore
    
    // MARK: Published collections (real-time)
    @Published private(set) var patients:       [Patient]       = []
    @Published private(set) var doctors:        [Doctor]        = []
    @Published private(set) var clinics:        [Clinic]        = []
    @Published private(set) var services:       [Service]       = []
    @Published private(set) var appointments:   [Appointment]   = []
    @Published private(set) var currentPatient: Patient?        = nil

    // MARK: Active Firestore listeners
    private var listeners: [ListenerRegistration] = []
    
    // MARK: Init
    init(firestore: Firestore = Firestore.firestore()) {
        self.db = firestore
        configureFirestore()
    }
    
    deinit {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    // MARK: - Configuration
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    // MARK: - Listener management
    func removeAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }
    // =========================================================================
    // MARK: - REAL-TIME LISTENERS
    // =========================================================================
    
    /// Start listening to all collections. Call once on app launch / login.
    func startListeners(forClinicId clinicId: String) {
        listenToPatients()
        listenToDoctors(clinicId: clinicId)
        listenToClinics()
        listenToServices()
        listenToAppointments(clinicId: clinicId)
    }
    
    private func listenToPatients() {
        let listener = db.collection(FSCollection.patients)
            .order(by: "last_name")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error, update: { self?.patients = $0 })
            }
        listeners.append(listener)
    }

    private func listenToDoctors(clinicId: String?) {
        var query: Query = db.collection(FSCollection.doctors)
            .whereField("is_active", isEqualTo: true)
        
        if let clinicId {
            query = query.whereField("clinic_ids", arrayContains: clinicId)
        }
        
        let listener = query
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error, update: { self?.doctors = $0 })
            }
        listeners.append(listener)
    }

    private func listenToClinics() {
        let listener = db.collection(FSCollection.clinics)
            .whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error, update: { self?.clinics = $0 })
            }
        listeners.append(listener)
    }

    private func listenToServices() {
        let listener = db.collection(FSCollection.services)
            .whereField("is_active", isEqualTo: true)
            .order(by: "title")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error, update: { self?.services = $0 })
            }
        listeners.append(listener)
    }

    func listenToAppointments(clinicId: String? = nil,
                              doctorId: String? = nil,
                              patientId: String? = nil) {
        var query: Query = db.collection(FSCollection.appointments)

        if let clinicId  { query = query.whereField("clinic_id",  isEqualTo: clinicId) }
        if let doctorId  { query = query.whereField("doctor_id",  isEqualTo: doctorId) }
        if let patientId { query = query.whereField("patient_id", isEqualTo: patientId) }

        let listener = query
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error, update: { self?.appointments = $0 })
            }
        listeners.append(listener)
    }

    // =========================================================================
    // MARK: - FETCH (one-time)
    // =========================================================================

    func fetchPatient(id: String) async throws -> Patient {
        try await fetchDocument(collection: FSCollection.patients, id: id)
    }

    func fetchDoctor(id: String) async throws -> Doctor {
        try await fetchDocument(collection: FSCollection.doctors, id: id)
    }

    func fetchClinic(id: String) async throws -> Clinic {
        try await fetchDocument(collection: FSCollection.clinics, id: id)
    }

    func fetchService(id: String) async throws -> Service {
        try await fetchDocument(collection: FSCollection.services, id: id)
    }

    func fetchAppointment(id: String) async throws -> Appointment {
        try await fetchDocument(collection: FSCollection.appointments, id: id)
    }

    /// Fetch all appointments for a specific patient
    func fetchAppointments(forPatientId patientId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(FSCollection.appointments)
            .whereField("patient_id", isEqualTo: patientId)
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Appointment.self) }
    }

    /// Fetch appointments in a date range
    func fetchAppointments(from startDate: Date,
                           to endDate: Date,
                           clinicId: String? = nil) async throws -> [Appointment] {
        var query: Query = db.collection(FSCollection.appointments)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo: endDate)

        if let clinicId { query = query.whereField("clinic_id", isEqualTo: clinicId) }

        let snapshot = try await query.order(by: "date").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Appointment.self) }
    }

    /// Search patients by name (prefix search)
    func searchPatients(query: String) async throws -> [Patient] {
        guard !query.isEmpty else { return patients }
        let end = query + "\u{f8ff}"
        let snapshot = try await db.collection(FSCollection.patients)
            .whereField("last_name", isGreaterThanOrEqualTo: query)
            .whereField("last_name", isLessThan: end)
            .limit(to: 20)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Patient.self) }
    }

    // =========================================================================
    // MARK: - CREATE
    // =========================================================================

    @discardableResult
    func createPatient(_ patient: Patient) async throws -> String {
        try await createDocument(patient, collection: FSCollection.patients)
    }

    @discardableResult
    func createDoctor(_ doctor: Doctor) async throws -> String {
        try await createDocument(doctor, collection: FSCollection.doctors)
    }

    @discardableResult
    func createClinic(_ clinic: Clinic) async throws -> String {
        try await createDocument(clinic, collection: FSCollection.clinics)
    }

    @discardableResult
    func createService(_ service: Service) async throws -> String {
        try await createDocument(service, collection: FSCollection.services)
    }

    @discardableResult
    func createAppointment(_ appointment: Appointment) async throws -> String {
        try await createDocument(appointment, collection: FSCollection.appointments)
    }

    // =========================================================================
    // MARK: - UPDATE
    // =========================================================================

    func updatePatient(_ patient: Patient) async throws {
        guard let id = patient.id else { throw FirestoreError.missingId }
        var updated = patient
        updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.patients, id: id)
    }

    func updateDoctor(_ doctor: Doctor) async throws {
        guard let id = doctor.id else { throw FirestoreError.missingId }
        try await updateDocument(doctor, collection: FSCollection.doctors, id: id)
    }

    func updateClinic(_ clinic: Clinic) async throws {
        guard let id = clinic.id else { throw FirestoreError.missingId }
        var updated = clinic
        updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.clinics, id: id)
    }

    func updateService(_ service: Service) async throws {
        try await updateDocument(service, collection: FSCollection.services, id: service.id)
    }

    func updateAppointment(_ appointment: Appointment) async throws {
        guard let id = appointment.id else { throw FirestoreError.missingId }
        var updated = appointment
        updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.appointments, id: id)
    }

    func updateAppointmentStatus(_ id: String, status: Appointment.AppointmentStatus) async throws {
        try await db.collection(FSCollection.appointments).document(id)
            .updateData(["status": status.rawValue,
                         "updated_at": Timestamp(date: Date())])
    }

    // =========================================================================
    // MARK: - DELETE
    // =========================================================================

    func deletePatient(id: String) async throws {
        try await db.collection(FSCollection.patients).document(id).delete()
    }

    func deleteDoctor(id: String) async throws {
        // Soft delete – keep data, mark inactive
        try await db.collection(FSCollection.doctors).document(id)
            .updateData(["is_active": false])
    }

    func deleteClinic(id: String) async throws {
        try await db.collection(FSCollection.clinics).document(id)
            .updateData(["is_active": false])
    }

    func deleteService(id: String) async throws {
        try await db.collection(FSCollection.services).document(id)
            .updateData(["is_active": false])
    }

    func cancelAppointment(id: String) async throws {
        try await updateAppointmentStatus(id, status: .cancelled)
    }

    // =========================================================================
    // MARK: - BATCH WRITE
    // =========================================================================

    /// Batch-update multiple appointments' statuses in one Firestore write.
    func batchUpdateAppointmentStatuses(
        _ updates: [(id: String, status: Appointment.AppointmentStatus)]
    ) async throws {
        let batch = db.batch()
        let now = Timestamp(date: Date())
        for update in updates {
            let ref = db.collection(FSCollection.appointments).document(update.id)
            batch.updateData(["status": update.status.rawValue, "updated_at": now], forDocument: ref)
        }
        try await batch.commit()
    }

    // =========================================================================
    // MARK: - PRIVATE HELPERS
    // =========================================================================

    private func handleSnapshot<T: Codable>(
        snapshot: QuerySnapshot?,
        error: Error?,
        update: @escaping ([T]) -> Void
    ) {
        if let error {
            print("⛔️ Firestore listener error: \(error.localizedDescription)")
            return
        }
        guard let snapshot else { return }
        do {
            let items: [T] = try snapshot.documents.compactMap { try $0.data(as: T.self) }
            update(items)
        } catch {
            print("⛔️ Decoding error: \(error.localizedDescription)")
        }
    }

    private func fetchDocument<T: Codable>(collection: String, id: String) async throws -> T {
        let docRef = db.collection(collection).document(id)
        do {
            let snapshot = try await docRef.getDocument()
            guard snapshot.exists else { throw FirestoreError.documentNotFound(id) }
            return try snapshot.data(as: T.self)
        } catch let error as FirestoreError {
            throw error
        } catch {
            throw FirestoreError.firestoreError(error)
        }
    }

    @discardableResult
    private func createDocument<T: Encodable>(_ value: T, collection: String) async throws -> String {
        let ref = db.collection(collection).document()
        do {
            try ref.setData(from: value)
            return ref.documentID
        } catch {
            throw FirestoreError.encodingFailed(error)
        }
    }

    private func updateDocument<T: Encodable>(_ value: T, collection: String, id: String) async throws {
        let ref = db.collection(collection).document(id)
        do {
            try ref.setData(from: value, merge: true)
        } catch {
            throw FirestoreError.encodingFailed(error)
        }
    }
}
