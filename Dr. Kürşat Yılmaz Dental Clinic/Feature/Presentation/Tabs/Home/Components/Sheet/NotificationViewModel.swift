//
//  NotificationViewModel.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class NotificationViewModel: ObservableObject {
    
    @Injected private var authService: AuthServiceProtocol
    
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var unreadCount: Int = 0
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        authService.currentPatientPublisher
            .compactMap { $0?.id }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uid in self?.startListener(for: uid) }
            .store(in: &cancellables)
    }

    deinit { listener?.remove() }

    // MARK: Computed
    var unreadNotifications: [AppNotification] { notifications.filter { !$0.isRead } }
    var hasUnread: Bool { unreadCount > 0 }

    // MARK: Listener
    private func startListener(for uid: String) {
        listener?.remove()
        isLoading = true
        listener = db.collection("notifications")
            .whereField("recipient_id", isEqualTo: uid)
            .order(by: "created_at", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                self.isLoading = false
                if let error { self.errorMessage = error.localizedDescription; return }
                do {
                    self.notifications = try snapshot?.documents
                        .compactMap { try $0.data(as: AppNotification.self) } ?? []
                    self.unreadCount = self.notifications.filter { !$0.isRead }.count
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
    }

    // MARK: Mark read
    func markAsRead(_ notification: AppNotification) async {
        guard let id = notification.id, !notification.isRead else { return }
        try? await db.collection("notifications").document(id)
            .updateData(["is_read": true])
    }

    func markAllAsRead() async {
        let unread = notifications.filter { !$0.isRead }
        guard !unread.isEmpty else { return }
        let batch = db.batch()
        unread.compactMap(\.id).forEach {
            batch.updateData(["is_read": true], forDocument: db.collection("notifications").document($0))
        }
        try? await batch.commit()
    }

    // MARK: Delete
    func delete(_ notification: AppNotification) async {
        guard let id = notification.id else { return }
        try? await db.collection("notifications").document(id).delete()
    }
}
