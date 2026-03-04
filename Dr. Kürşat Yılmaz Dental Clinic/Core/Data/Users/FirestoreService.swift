import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FirestoreService: ObservableObject {
    
    private let db = Firestore.firestore()
    
    // MARK: ─── USER ───────────────────────────────────────
    
    func fetchUser(uid: String) async throws -> User {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let user = try? doc.data(as: User.self) else {
            throw FSError.decodingFailed("User")
        }
        return user
    }
    
    func updateUser(_ user: User) async throws {
        guard let uid = user.id else { throw FSError.missingID }
        try db.collection("users").document(uid).setData(from: user, merge: true)
    }
    
    func incrementVisit(uid: String) async throws {
        try await db.collection("users").document(uid).updateData([
            "totalVisits": FieldValue.increment(Int64(1))
        ])
    }
    
    func addLoyaltyPoints(uid: String, points: Int) async throws {
        try await db.collection("users").document(uid).updateData([
            "loyaltyPoints": FieldValue.increment(Int64(points))
        ])
    }
    
    // MARK: ─── APPOINTMENTS ──────────────────────────────
    
    /// Kullanıcının tüm randevularını gerçek zamanlı dinle
    func listenAppointments(uid: String, onChange: @escaping ([Appointment]) -> Void) -> ListenerRegistration {
        db.collection("appointments")
            .whereField("userId", isEqualTo: uid)
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, _ in
                let items = snapshot?.documents.compactMap {
                    try? $0.data(as: Appointment.self)
                } ?? []
                onChange(items)
            }
    }
    
    func createAppointment(_ appointment: Appointment) async throws -> String {
        let ref = try db.collection("appointments").addDocument(from: appointment)
        return ref.documentID
    }
    
    func updateAppointmentStatus(id: String, status: Appointment.AppointmentStatus) async throws {
        try await db.collection("appointments").document(id).updateData([
            "status": status.rawValue
        ])
    }
    
    func cancelAppointment(id: String) async throws {
        try await updateAppointmentStatus(id: id, status: .cancelled)
    }
    
    func deleteAppointment(id: String) async throws {
        try await db.collection("appointments").document(id).delete()
    }
    
    // MARK: ─── DOCTORS ───────────────────────────────────
    
    func fetchDoctors() async throws -> [Doctor] {
        let snapshot = try await db.collection("doctors").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Doctor.self) }
    }
    
    /// Gerçek zamanlı doktor listesi
    func listenDoctors(onChange: @escaping ([Doctor]) -> Void) -> ListenerRegistration {
        db.collection("doctors")
            .addSnapshotListener { snapshot, _ in
                let items = snapshot?.documents.compactMap {
                    try? $0.data(as: Doctor.self)
                } ?? []
                onChange(items)
            }
    }
    
    // MARK: ─── SERVICES ──────────────────────────────────
    
    func fetchServices() async throws -> [DentalService] {
        let snapshot = try await db.collection("services").getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: DentalService.self) }
    }
    
    // MARK: ─── NOTIFICATIONS ─────────────────────────────
    
    func listenNotifications(uid: String, onChange: @escaping ([NotificationItem]) -> Void) -> ListenerRegistration {
        db.collection("notifications")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, _ in
                let items = snapshot?.documents.compactMap {
                    try? $0.data(as: NotificationItem.self)
                } ?? []
                onChange(items)
            }
    }
    
    func markNotificationRead(id: String) async throws {
        try await db.collection("notifications").document(id).updateData(["isRead": true])
    }
    
    func markAllNotificationsRead(uid: String) async throws {
        let snapshot = try await db.collection("notifications")
            .whereField("userId", isEqualTo: uid)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        let batch = db.batch()
        snapshot.documents.forEach { doc in
            batch.updateData(["isRead": true], forDocument: doc.reference)
        }
        try await batch.commit()
    }
    
    // MARK: ─── SEED (İlk kurulum için) ───────────────────
    
    /// Firestore'a başlangıç verilerini yükler (bir kez çalıştır)
    func seedDoctorsIfNeeded() async throws {
        let snapshot = try await db.collection("doctors").limit(to: 1).getDocuments()
        guard snapshot.isEmpty else { return }   // Zaten var, tekrar ekleme
        
        for doctor in Doctor.sampleData {
            try db.collection("doctors").addDocument(from: doctor)
        }
        for service in DentalService.sampleData {
            try db.collection("services").addDocument(from: service)
        }
    }
}

// MARK: - Custom Errors
enum FSError: LocalizedError {
    case decodingFailed(String)
    case missingID
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .decodingFailed(let name): return "\(name) verisi okunamadı."
        case .missingID:                return "Doküman ID bulunamadı."
        case .notFound:                 return "Veri bulunamadı."
        }
    }
}
