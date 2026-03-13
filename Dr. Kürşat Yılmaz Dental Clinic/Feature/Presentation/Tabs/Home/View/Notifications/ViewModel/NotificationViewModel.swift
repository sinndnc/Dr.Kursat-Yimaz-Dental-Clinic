//
//  DentalNotificationCategory.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class NotificationViewModel: ObservableObject {
    
    // MARK: Published — veri
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var unreadCount   = 0
    @Published private(set) var isLoading     = false
    
    // MARK: Published — UI filtre (adapter görevi)
    @Published var selectedFilter: DentalNotificationCategory? = nil
    
    var isAuthorized: Bool { NotificationService.shared.isAuthorized }
    
    // MARK: Private
    @Injected private var authService: AuthServiceProtocol
    private let db          = Firestore.firestore()
    private var listener:    ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    init() {
        authService.currentPatientPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] patient in
                if let uid = patient?.id { self?.startListener(uid) }
                else                     { self?.stopListener() }
            }
            .store(in: &cancellables)
        
        NotificationService.shared.$isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
    deinit { listener?.remove() }
    
    // MARK: - Filtered & Grouped (adapter mantığı)
    
    var filtered: [DentalNotification] {
        let all = notifications.map(DentalNotification.init)
        guard let f = selectedFilter else { return all }
        return all.filter { $0.category == f }
    }
    
    var grouped: [(group: NotificationTimeGroup, items: [DentalNotification])] {
        let now        = Date.now
        let todayStart = Calendar.current.startOfDay(for: now)
        let weekStart  = Calendar.current.date(byAdding: .day, value: -7, to: todayStart)!
        
        return [
            (.today,    filtered.filter { $0.date >= todayStart }),
            (.thisWeek, filtered.filter { $0.date >= weekStart && $0.date < todayStart }),
            (.older,    filtered.filter { $0.date < weekStart }),
        ].filter { !$0.items.isEmpty }
    }
    
    // MARK: - İzin
    
    func requestPermission() async {
        _ = await NotificationService.shared.requestPermission()
    }
    
    // MARK: - Firestore listener
    
    private func startListener(_ uid: String) {
        listener?.remove()
        isLoading = true
        listener = db.collection("notifications")
            .whereField("recipient_id", isEqualTo: uid)
            .order(by: "created_at", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                self.isLoading    = false
                self.notifications = (try? snap.documents.compactMap { try $0.data(as: AppNotification.self) }) ?? []
                self.unreadCount   = self.notifications.filter { !$0.isRead }.count
            }
    }
    
    private func stopListener() {
        listener?.remove()
        listener      = nil
        notifications = []
        unreadCount   = 0
        NotificationService.shared.cancelAll()
    }
    
    // MARK: - Randevu olayları
    
    func onAppointmentConfirmed(_ appointment: Appointment, patientId: String) async {
        await NotificationService.shared.scheduleReminders(for: appointment)
        await write(.appointmentConfirmed(for: appointment, patientId: patientId))
    }
    
    func onAppointmentCancelled(_ appointment: Appointment, patientId: String) async {
        if let id = appointment.id { NotificationService.shared.cancelReminders(for: id) }
        await write(.appointmentCancelled(for: appointment, patientId: patientId))
    }
    
    func onAppointmentRescheduled(old: Appointment, new: Appointment, patientId: String) async {
        if let id = old.id { NotificationService.shared.cancelReminders(for: id) }
        await NotificationService.shared.scheduleReminders(for: new)
        await write(AppNotification(
            recipientId: patientId,
            title: "Randevunuz Değiştirildi",
            body:  "Yeni randevunuz: \(new.date.formatted(date: .long, time: .omitted)) — \(new.time)",
            type:  .appointmentRescheduled,
            relatedId: new.id
        ))
    }
    
    func onReminderPrefsChanged() async {
        await NotificationService.shared.refreshReminders()
    }
    
    // MARK: - Okundu / Sil
    
    func markAsRead(_ notification: AppNotification) async {
        guard let id = notification.id, !notification.isRead else { return }
        try? await db.collection("notifications").document(id).updateData(["is_read": true])
    }
    
    func markAllAsRead() async {
        let batch = db.batch()
        notifications.filter { !$0.isRead }.compactMap(\.id).forEach {
            batch.updateData(["is_read": true], forDocument: db.collection("notifications").document($0))
        }
        try? await batch.commit()
    }
    
    func delete(_ notification: AppNotification) async {
        guard let id = notification.id else { return }
        try? await db.collection("notifications").document(id).delete()
    }
    
    func deleteAll() async {
        for n in notifications { await delete(n) }
    }
    
    func clearBadge() { NotificationService.shared.clearBadge() }
    
    
    private func write(_ notification: AppNotification) async {
        try? db.collection("notifications").addDocument(from: notification)
    }
}
