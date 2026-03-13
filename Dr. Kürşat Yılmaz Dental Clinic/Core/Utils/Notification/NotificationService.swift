//
//  NotificationService.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import Combine
import Foundation
import UserNotifications
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
final class NotificationService: NSObject, ObservableObject {

    static let shared = NotificationService()

    @Published private(set) var isAuthorized = false

    private let center = UNUserNotificationCenter.current()
    private let db     = Firestore.firestore()

    private override init() {
        super.init()
        center.delegate = self
        Task { await refreshStatus() }
    }

    // MARK: - İzin

    func requestPermission() async -> Bool {
        guard let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return false }
        isAuthorized = granted
        return granted
    }

    func refreshStatus() async {
        isAuthorized = await center.notificationSettings().authorizationStatus == .authorized
    }

    // MARK: - Schedule / Cancel

    func schedule(id: String, title: String, body: String, at date: Date) async {
        guard isAuthorized, date > .now else { return }

        let content       = UNMutableNotificationContent()
        content.title     = title
        content.body      = body
        content.sound     = .default
        content.badge     = 1

        let comps   = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func cancel(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        center.removeAllDeliveredNotifications()
    }

    // MARK: - Randevu reminder'ları

    func scheduleReminders(for appointment: Appointment) async {
        guard let id = appointment.id else { return }
        let date      = appointmentDate(appointment)
        let remind24h = UserDefaults.standard.bool(forKey: "pref_reminder_24h", default: true)
        let remind1h  = UserDefaults.standard.bool(forKey: "pref_reminder_1h",  default: true)

        cancel(ids: ["\(id)_24h", "\(id)_1h"])

        if remind24h {
            await schedule(
                id:    "\(id)_24h",
                title: "Randevu Hatırlatması 📅",
                body:  "Yarın \(appointment.time) — \(appointment.doctorName)",
                at:    date.addingTimeInterval(-24 * 3600)
            )
        }
        if remind1h {
            await schedule(
                id:    "\(id)_1h",
                title: "1 Saat Kaldı ⏰",
                body:  "\(appointment.time) randevunuza az kaldı — \(appointment.doctorName)",
                at:    date.addingTimeInterval(-3600)
            )
        }
    }

    func cancelReminders(for appointmentId: String) {
        cancel(ids: ["\(appointmentId)_24h", "\(appointmentId)_1h"])
    }

    // MARK: - Foreground sync (scenePhase .active'de çağrılır)

    func syncReminders() async {
        guard isAuthorized, let uid = Auth.auth().currentUser?.uid else { return }

        guard let snap = try? await db.collection("appointments")
            .whereField("patient_id", isEqualTo: uid)
            .whereField("status", isEqualTo: "confirmed")
            .whereField("date", isGreaterThan: Timestamp(date: .now))
            .getDocuments(),
              let appointments = try? snap.documents.compactMap({ try $0.data(as: Appointment.self) })
        else { return }

        // Pending ID'leri al
        let pending   = Set(await center.pendingNotificationRequests().map(\.identifier))
        let remind24h = UserDefaults.standard.bool(forKey: "pref_reminder_24h", default: true)
        let remind1h  = UserDefaults.standard.bool(forKey: "pref_reminder_1h",  default: true)

        // Eksik olanları zamanla
        for appointment in appointments {
            guard let id = appointment.id else { continue }
            let date = appointmentDate(appointment)

            if remind24h && !pending.contains("\(id)_24h") {
                await schedule(id: "\(id)_24h", title: "Randevu Hatırlatması 📅",
                               body: "Yarın \(appointment.time) — \(appointment.doctorName)",
                               at: date.addingTimeInterval(-24 * 3600))
            }
            if remind1h && !pending.contains("\(id)_1h") {
                await schedule(id: "\(id)_1h", title: "1 Saat Kaldı ⏰",
                               body: "\(appointment.time) randevunuza az kaldı — \(appointment.doctorName)",
                               at: date.addingTimeInterval(-3600))
            }
        }

        // Artık olmayan randevuların reminder'larını sil
        let activeIds = Set(appointments.compactMap(\.id))
        for id in pending {
            for suffix in ["_24h", "_1h"] where id.hasSuffix(suffix) {
                let base = String(id.dropLast(suffix.count))
                if !activeIds.contains(base) { cancel(ids: [id]) }
            }
        }
    }

    // MARK: - Tüm reminder'ları tercihlere göre yenile

    func refreshReminders() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        center.removeAllPendingNotificationRequests()

        guard let snap = try? await db.collection("appointments")
            .whereField("patient_id", isEqualTo: uid)
            .whereField("status", isEqualTo: "confirmed")
            .whereField("date", isGreaterThan: Timestamp(date: .now))
            .getDocuments(),
              let appointments = try? snap.documents.compactMap({ try $0.data(as: Appointment.self) })
        else { return }

        for appointment in appointments {
            await scheduleReminders(for: appointment)
        }
    }

    // MARK: - Yardımcı

    private func appointmentDate(_ appointment: Appointment) -> Date {
        let parts = appointment.time.split(separator: ":").compactMap { Int($0) }
        guard parts.count >= 2 else { return appointment.date }
        var comps    = Calendar.current.dateComponents([.year, .month, .day], from: appointment.date)
        comps.hour   = parts[0]
        comps.minute = parts[1]
        comps.second = 0
        return Calendar.current.date(from: comps) ?? appointment.date
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handler([.banner, .sound, .badge])
    }
}

// MARK: - UserDefaults helper

private extension UserDefaults {
    func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        object(forKey: key) as? Bool ?? defaultValue
    }
}
