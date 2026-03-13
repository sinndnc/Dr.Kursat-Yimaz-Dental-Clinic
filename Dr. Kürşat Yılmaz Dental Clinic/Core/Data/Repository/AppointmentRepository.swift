//
//  AppointmentRepository.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Foundation
import FirebaseFirestore
import Combine


protocol AppointmentRepositoryProtocol {
    
    func create(_ appointment: Appointment) async throws -> Appointment
    func update(_ appointment: Appointment) async throws
    func updateStatus(id: String, status: AppointmentStatus) async throws
    func updateFields(id: String, fields: [String: Any]) async throws
    func delete(id: String) async throws
    
    func fetch(id: String) async throws -> Appointment
    
    func fetchAll() async throws -> [Appointment]
    func fetchByPatient(patientId: String) async throws -> [Appointment]
    func fetchByDoctor(doctorId: String) async throws -> [Appointment]
    func fetchByDoctor(doctorId: String, on date: Date) async throws -> [Appointment]
    func fetchByClinic(clinicId: String) async throws -> [Appointment]
    func fetchByStatus(_ status: AppointmentStatus) async throws -> [Appointment]
    func fetchUpcoming(for patientId: String) async throws -> [Appointment]
    func fetchByDateRange(from: Date, to: Date) async throws -> [Appointment]
    
    func fetchPage(limit: Int, after cursor: DocumentSnapshot?) async throws -> AppointmentPage
    
    func observeByPatient(patientId: String) -> AnyPublisher<[Appointment], AppointmentRepositoryError>
    func observeByDoctor(doctorId: String) -> AnyPublisher<[Appointment], AppointmentRepositoryError>
    func observe(id: String) -> AnyPublisher<Appointment, AppointmentRepositoryError>
}


struct AppointmentPage {
    public let items: [Appointment]
    public let lastSnapshot: DocumentSnapshot?
    public var hasMore: Bool { lastSnapshot != nil && !items.isEmpty }
}


public enum AppointmentRepositoryError: LocalizedError {
    case notFound(id: String)
    case missingDocumentID
    case encodingFailed(Error)
    case decodingFailed(Error)
    case networkError(Error)
    case permissionDenied
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .notFound(let id):       return "Randevu bulunamadı: \(id)"
        case .missingDocumentID:      return "Doküman ID'si eksik."
        case .encodingFailed(let e):  return "Kodlama hatası: \(e.localizedDescription)"
        case .decodingFailed(let e):  return "Çözümleme hatası: \(e.localizedDescription)"
        case .networkError(let e):    return "Ağ hatası: \(e.localizedDescription)"
        case .permissionDenied:       return "Erişim reddedildi. Firestore kurallarını kontrol edin."
        case .unknown(let e):         return "Bilinmeyen hata: \(e.localizedDescription)"
        }
    }
}


final class AppointmentRepository: AppointmentRepositoryProtocol {
    
    private let db: Firestore
    private let collection: CollectionReference
    private var listeners: [ListenerRegistration] = []
    
    private static let collectionPath = "appointments"
    
    
    public init(db: Firestore = Firestore.firestore()) {
        self.db = db
        self.collection = db.collection(Self.collectionPath)
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    
    public func create(_ appointment: Appointment) async throws -> Appointment {
        let docRef = appointment.id.flatMap { $0.isEmpty ? nil : collection.document($0) }
        ?? collection.document()
        
        var mutable = appointment
        mutable = Appointment(
            id: docRef.documentID,
            patientId: appointment.patientId,
            patientName: appointment.patientName,
            doctorId: appointment.doctorId,
            doctorName: appointment.doctorName,
            doctorSpecialty: appointment.doctorSpecialty,
            clinicId: appointment.clinicId,
            date: appointment.date,
            time: appointment.time,
            durationMinutes: appointment.durationMinutes,
            type: appointment.type,
            notes: appointment.notes,
            roomNumber: appointment.roomNumber,
            serviceId: appointment.serviceId,
            createdAt: appointment.createdAt,
            updatedAt: Date()
        )
        
        try await encode(mutable, into: docRef)
        return mutable
    }
    
    public func update(_ appointment: Appointment) async throws {
        guard let id = appointment.id, !id.isEmpty else {
            throw AppointmentRepositoryError.missingDocumentID
        }
        var mutable = appointment
        mutable = Appointment(
            id: id,
            patientId: appointment.patientId,
            patientName: appointment.patientName,
            doctorId: appointment.doctorId,
            doctorName: appointment.doctorName,
            doctorSpecialty: appointment.doctorSpecialty,
            clinicId: appointment.clinicId,
            date: appointment.date,
            time: appointment.time,
            durationMinutes: appointment.durationMinutes,
            type: appointment.type,
            notes: appointment.notes,
            roomNumber: appointment.roomNumber,
            serviceId: appointment.serviceId,
            createdAt: appointment.createdAt,
            updatedAt: Date()
        )
        try await encode(mutable, into: collection.document(id))
    }
    
    /// Sadece status alanını günceller — tüm dokümanı yazmaktan daha verimli.
    public func updateStatus(id: String, status: AppointmentStatus) async throws {
        try await updateFields(id: id, fields: [
            "status": status.rawValue,
            "updated_at": FieldValue.serverTimestamp()
        ])
    }
    
    public func updateFields(id: String, fields: [String: Any]) async throws {
        do {
            try await collection.document(id).updateData(fields)
        } catch {
            throw map(error)
        }
    }
    
    public func delete(id: String) async throws {
        do {
            try await collection.document(id).delete()
        } catch {
            throw map(error)
        }
    }
    
    
    public func fetch(id: String) async throws -> Appointment {
        do {
            let snapshot = try await collection.document(id).getDocument()
            guard snapshot.exists else { throw AppointmentRepositoryError.notFound(id: id) }
            return try decode(snapshot)
        } catch let e as AppointmentRepositoryError { throw e }
        catch { throw map(error) }
    }
    
    
    public func fetchAll() async throws -> [Appointment] {
        try await run(collection)
    }
    
    public func fetchByPatient(patientId: String) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("patient_id", isEqualTo: patientId)
                .order(by: "date", descending: true)
        )
    }
    
    public func fetchByDoctor(doctorId: String) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("doctor_id", isEqualTo: doctorId)
                .order(by: "date", descending: true)
        )
    }
    
    public func fetchByDoctor(doctorId: String, on date: Date) async throws -> [Appointment] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end   = calendar.date(byAdding: .day, value: 1, to: start) ?? start
        
        return try await run(
            collection
                .whereField("doctor_id", isEqualTo: doctorId)
                .whereField("date", isGreaterThanOrEqualTo: start)
                .whereField("date", isLessThan: end)
                .order(by: "date")
        )
    }
    
    public func fetchByClinic(clinicId: String) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("clinic_id", isEqualTo: clinicId)
                .order(by: "date", descending: true)
        )
    }
    
    public func fetchByStatus(_ status: AppointmentStatus) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("status", isEqualTo: status.rawValue)
                .order(by: "date", descending: true)
        )
    }
    
    public func fetchUpcoming(for patientId: String) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("patient_id", isEqualTo: patientId)
                .whereField("status", isEqualTo: AppointmentStatus.upcoming.rawValue)
                .whereField("date", isGreaterThanOrEqualTo: Date())
                .order(by: "date")
        )
    }
    
    public func fetchByDateRange(from: Date, to: Date) async throws -> [Appointment] {
        try await run(
            collection
                .whereField("date", isGreaterThanOrEqualTo: from)
                .whereField("date", isLessThanOrEqualTo: to)
                .order(by: "date")
        )
    }
    
    
    public func fetchPage(limit: Int, after cursor: DocumentSnapshot? = nil) async throws -> AppointmentPage {
        do {
            var query: Query = collection.order(by: "date", descending: true).limit(to: limit)
            if let cursor { query = query.start(afterDocument: cursor) }
            let snapshot = try await query.getDocuments()
            let items = try snapshot.documents.map { try decode($0) }
            let lastSnapshot = snapshot.documents.count == limit ? snapshot.documents.last : nil
            return AppointmentPage(items: items, lastSnapshot: lastSnapshot)
        } catch let e as AppointmentRepositoryError { throw e }
        catch { throw map(error) }
    }
    
    
    public func observe(id: String) -> AnyPublisher<Appointment, AppointmentRepositoryError> {
        let subject = PassthroughSubject<Appointment, AppointmentRepositoryError>()
        let listener = collection.document(id).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error { subject.send(completion: .failure(self.map(error))); return }
            guard let snapshot, snapshot.exists else {
                subject.send(completion: .failure(.notFound(id: id))); return
            }
            do { subject.send(try self.decode(snapshot)) }
            catch { subject.send(completion: .failure(self.map(error))) }
        }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    public func observeByPatient(patientId: String) -> AnyPublisher<[Appointment], AppointmentRepositoryError> {
        observe(
            collection
                .whereField("patient_id", isEqualTo: patientId)
                .order(by: "date", descending: true)
        )
    }
    
    public func observeByDoctor(doctorId: String) -> AnyPublisher<[Appointment], AppointmentRepositoryError> {
        observe(
            collection
                .whereField("doctor_id", isEqualTo: doctorId)
                .order(by: "date", descending: true)
        )
    }
    
    
    private func encode(_ appointment: Appointment, into ref: DocumentReference) async throws {
        do {
            let data = try Firestore.Encoder().encode(appointment)
            try await ref.setData(data)
        } catch { throw AppointmentRepositoryError.encodingFailed(error) }
    }
    
    private func decode(_ snapshot: DocumentSnapshot) throws -> Appointment {
        do {
            return try snapshot.data(as: Appointment.self)
        } catch { throw AppointmentRepositoryError.decodingFailed(error) }
    }
    
    /// Herhangi bir `Query`'yi çalıştırıp `[Appointment]` döner.
    private func run(_ query: Query) async throws -> [Appointment] {
        do {
            let snapshot = try await query.getDocuments()
            return try snapshot.documents.map { try decode($0) }
        } catch let e as AppointmentRepositoryError { throw e }
        catch { throw map(error) }
    }
    
    /// Koleksiyonu da `Query` olarak kullanabilmek için overload.
    private func run(_ ref: CollectionReference) async throws -> [Appointment] {
        try await run(ref as Query)
    }
    
    /// Belirli bir `Query` üzerinde realtime listener kurar.
    private func observe(_ query: Query) -> AnyPublisher<[Appointment], AppointmentRepositoryError> {
        let subject = PassthroughSubject<[Appointment], AppointmentRepositoryError>()
        let listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error { subject.send(completion: .failure(self.map(error))); return }
            guard let snapshot else { return }
            do { subject.send(try snapshot.documents.map { try self.decode($0) }) }
            catch { subject.send(completion: .failure(self.map(error))) }
        }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    private func map(_ error: Error) -> AppointmentRepositoryError {
        if let e = error as? AppointmentRepositoryError { return e }
        let ns = error as NSError
        guard ns.domain == FirestoreErrorDomain else { return .unknown(error) }
        return .notFound(id: "")
    }
}

// MARK: - Usage Example

/*
 let repo = AppointmentRepository()

 // Oluştur
 let appt = try await repo.create(
     Appointment(
         patientId: "p1", patientName: "Ali Veli",
         doctorId: "d1", doctorName: "Dr. Kürşat Yılmaz",
         doctorSpecialty: "Ortodonti",
         date: Date(), time: "09:30", type: .checkup
     )
 )

 // Güncelle — sadece status
 try await repo.updateStatus(id: appt.id!, status: .completed)

 // Doktora göre bugünkü randevular
 let todayAppts = try await repo.fetchByDoctor(doctorId: "d1", on: Date())

 // Hastanın yaklaşan randevuları
 let upcoming = try await repo.fetchUpcoming(for: "p1")

 // Tarih aralığına göre
 let range = try await repo.fetchByDateRange(from: startDate, to: endDate)

 // Realtime — hasta bazlı
 repo.observeByPatient(patientId: "p1")
     .sink(receiveCompletion: { _ in },
           receiveValue: { appointments in print(appointments) })
     .store(in: &cancellables)

 // Sayfalama
 var page = try await repo.fetchPage(limit: 20)
 if page.hasMore {
     page = try await repo.fetchPage(limit: 20, after: page.lastSnapshot)
 }
 */
