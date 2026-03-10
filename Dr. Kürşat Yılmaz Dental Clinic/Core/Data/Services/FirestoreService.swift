//
//  FirestoreService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//
//  Registered as a .singleton in DIContainer.
//
//  Responsibilities:
//  - Real-time listeners for doctors, clinics, services, appointments
//  - One-time fetch helpers for all collections
//  - CRUD + batch operations
//
//  NOTE: `currentPatient` is NOT managed here.
//  AuthService owns the authenticated user's Patient document via UID.

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class FirestoreService: FirestoreServiceProtocol {
    
    @Published private(set) var doctors: [Doctor] = []
    @Published private(set) var clinics: [Clinic] = []
    @Published private(set) var services: [Service] = []
    @Published private(set) var appointments: [Appointment] = []
    
    var clinicsPublisher: AnyPublisher<[Clinic], Never> { $clinics.eraseToAnyPublisher() }
    var servicesPublisher: AnyPublisher<[Service], Never> { $services.eraseToAnyPublisher() }
    var doctorsStatePublisher: AnyPublisher<[Doctor], Never> { $doctors.eraseToAnyPublisher() }
    var appointmentsPublisher: AnyPublisher<[Appointment], Never> { $appointments.eraseToAnyPublisher() }
    
    private let db: Firestore
    private var publicListeners: [ListenerRegistration] = []
    private var authenticatedListeners: [ListenerRegistration] = []
    
    init(firestore: Firestore) {
        self.db = firestore
    }
    
    func removeAuthenticatedListeners() {
        authenticatedListeners.forEach { $0.remove() }
        authenticatedListeners.removeAll()
    }
    
    func removeAllListeners() {
        publicListeners.forEach { $0.remove() }
        authenticatedListeners.forEach { $0.remove() }
        publicListeners.removeAll()
        authenticatedListeners.removeAll()
    }
    
    func startPublicListeners(clinicId: String? = nil) {
        listenToClinics()
        listenToServices()
        listenToDoctors(clinicId: clinicId)
    }
    
    func startAuthenticatedListeners(patientId: String, clinicId: String? = nil) {
        listenToAppointments(clinicId: clinicId, patientId: patientId)
    }
    
    func startListeners(patientId: String?, clinicId: String?) {
        startPublicListeners(clinicId: clinicId)
        if let patientId {
            startAuthenticatedListeners(patientId: patientId, clinicId: clinicId)
        }
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
                self?.handleSnapshot(snapshot: snapshot, error: error) { self?.doctors = $0 }
            }
        publicListeners.append(listener)
    }
    
    private func listenToClinics() {
        let listener = db.collection(FSCollection.clinics)
            .whereField("is_active", isEqualTo: true)
            .order(by: "name")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error) { self?.clinics = $0 }
            }
        publicListeners.append(listener)
    }
    
    private func listenToServices() {
        let listener = db.collection(FSCollection.services)
            .whereField("is_active", isEqualTo: true)
            .order(by: "title")
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error) { self?.services = $0 }
            }
        publicListeners.append(listener)
    }
    
    func listenToAppointments(
        clinicId:  String? = nil,
        doctorId:  String? = nil,
        patientId: String? = nil
    ) {
        var query: Query = db.collection(FSCollection.appointments)
        
        if let clinicId  { query = query.whereField("clinic_id",  isEqualTo: clinicId)  }
        if let doctorId  { query = query.whereField("doctor_id",  isEqualTo: doctorId)  }
        if let patientId { query = query.whereField("patient_id", isEqualTo: patientId) }
        
        let listener = query
            .order(by: "date", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                self?.handleSnapshot(snapshot: snapshot, error: error) { self?.appointments = $0 }
            }
        authenticatedListeners.append(listener)
    }
    
    func fetchPatient(id: String)     async throws -> Patient     { try await fetchDocument(collection: FSCollection.patients,     id: id) }
    func fetchDoctor(id: String)      async throws -> Doctor      { try await fetchDocument(collection: FSCollection.doctors,      id: id) }
    func fetchClinic(id: String)      async throws -> Clinic      { try await fetchDocument(collection: FSCollection.clinics,      id: id) }
    func fetchService(id: String)     async throws -> Service     { try await fetchDocument(collection: FSCollection.services,     id: id) }
    func fetchAppointment(id: String) async throws -> Appointment { try await fetchDocument(collection: FSCollection.appointments, id: id) }
    
    func fetchAppointments(forPatientId patientId: String) async throws -> [Appointment] {
        let snapshot = try await db.collection(FSCollection.appointments)
            .whereField("patient_id", isEqualTo: patientId)
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Appointment.self) }
    }
    
    func fetchAppointments(
        from startDate: Date,
        to   endDate:   Date,
        clinicId: String? = nil
    ) async throws -> [Appointment] {
        var query: Query = db.collection(FSCollection.appointments)
            .whereField("date", isGreaterThanOrEqualTo: startDate)
            .whereField("date", isLessThanOrEqualTo:   endDate)
        
        if let clinicId { query = query.whereField("clinic_id", isEqualTo: clinicId) }
        
        let snapshot = try await query.order(by: "date").getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Appointment.self) }
    }
    
    @discardableResult func createPatient(_ patient: Patient)      async throws -> String { try await createDocument(patient,  collection: FSCollection.patients)     }
    @discardableResult func createDoctor(_ doctor: Doctor)         async throws -> String { try await createDocument(doctor,   collection: FSCollection.doctors)      }
    @discardableResult func createClinic(_ clinic: Clinic)         async throws -> String { try await createDocument(clinic,   collection: FSCollection.clinics)      }
    @discardableResult func createService(_ service: Service)      async throws -> String { try await createDocument(service,  collection: FSCollection.services)     }
    @discardableResult func createAppointment(_ appt: Appointment) async throws -> String { try await createDocument(appt,     collection: FSCollection.appointments) }
    
    func updatePatient(_ patient: Patient) async throws {
        guard let id = patient.id else { throw FirestoreError.missingId }
        var updated = patient; updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.patients, id: id)
    }
    
    func updateDoctor(_ doctor: Doctor) async throws {
        guard let id = doctor.id else { throw FirestoreError.missingId }
        try await updateDocument(doctor, collection: FSCollection.doctors, id: id)
    }
    
    func updateClinic(_ clinic: Clinic) async throws {
        guard let id = clinic.id else { throw FirestoreError.missingId }
        var updated = clinic; updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.clinics, id: id)
    }
    
    func updateService(_ service: Service) async throws {
        try await updateDocument(service, collection: FSCollection.services, id: service.id)
    }
    
    func updateAppointment(_ appointment: Appointment) async throws {
        guard let id = appointment.id else { throw FirestoreError.missingId }
        var updated = appointment; updated.updatedAt = Date()
        try await updateDocument(updated, collection: FSCollection.appointments, id: id)
    }
    
    func updateAppointmentStatus(_ id: String, status: AppointmentStatus) async throws {
        try await db.collection(FSCollection.appointments).document(id)
            .updateData(["status": status.rawValue, "updated_at": Timestamp(date: Date())])
    }
    
    func deletePatient(id: String)     async throws { try await db.collection(FSCollection.patients).document(id).delete() }
    func deleteDoctor(id: String)      async throws { try await db.collection(FSCollection.doctors).document(id).updateData(["is_active": false]) }
    func deleteClinic(id: String)      async throws { try await db.collection(FSCollection.clinics).document(id).updateData(["is_active": false]) }
    func deleteService(id: String)     async throws { try await db.collection(FSCollection.services).document(id).updateData(["is_active": false]) }
    func cancelAppointment(id: String) async throws { try await updateAppointmentStatus(id, status: .cancelled) }
    
    
    func batchUpdateAppointmentStatuses(
        _ updates: [(id: String, status: AppointmentStatus)]
    ) async throws {
        let batch = db.batch()
        let now   = Timestamp(date: Date())
        for update in updates {
            let ref = db.collection(FSCollection.appointments).document(update.id)
            batch.updateData(["status": update.status.rawValue, "updated_at": now], forDocument: ref)
        }
        try await batch.commit()
    }
    
    private func handleSnapshot<T: Codable>(
        snapshot: QuerySnapshot?,
        error:    Error?,
        update:   @escaping ([T]) -> Void
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
        let snapshot = try await db.collection(collection).document(id).getDocument()
        guard snapshot.exists else { throw FirestoreError.documentNotFound(id) }
        do    { return try snapshot.data(as: T.self) }
        catch { throw FirestoreError.firestoreError(error) }
    }

    @discardableResult
    private func createDocument<T: Encodable>(_ value: T, collection: String) async throws -> String {
        let ref = db.collection(collection).document()
        do    { try ref.setData(from: value); return ref.documentID }
        catch { throw FirestoreError.encodingFailed(error) }
    }

    private func updateDocument<T: Encodable>(_ value: T, collection: String, id: String) async throws {
        do    { try db.collection(collection).document(id).setData(from: value, merge: true) }
        catch { throw FirestoreError.encodingFailed(error) }
    }
}
