//
//  NotificationsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct NotificationsSheet: View {
    @EnvironmentObject var appState: AppState
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        ZStack{
            Color.kyBackground.ignoresSafeArea()
            Group {
                if appState.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bell.slash").font(.system(size: 50)).foregroundColor(.secondary.opacity(0.4))
                        Text("Bildirim yok").font(.system(size: 18, weight: .semibold)).foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(appState.notifications) { notif in
                            notificationRow(notif: notif)
                                .listRowBackground(notif.isRead ? Color.white : primaryBlue.opacity(0.04))
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .onTapGesture {
                                    if !notif.isRead { Task { await appState.markNotificationRead(notif) } }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Bildirimler").navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if appState.unreadNotificationCount > 0 {
                    Button("Tümünü Okundu Yap") {
                        Task {
                            if let uid = appState.authService.uid {
                                try? await appState.firestoreService.markAllNotificationsRead(uid: uid)
                            }
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(primaryBlue)
                }
            }
        }
    }
    
    func notificationRow(notif: NotificationItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(notif.notifType.color.opacity(0.12)).frame(width: 46)
                    Image(systemName: notif.notifType.icon).font(.system(size: 18)).foregroundColor(notif.notifType.color)
                }
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(notif.title).font(.system(size: 14, weight: .bold))
                        Spacer()
                        if !notif.isRead { Circle().fill(primaryBlue).frame(width: 8) }
                    }
                    Text(notif.message).font(.system(size: 13)).foregroundColor(.secondary).lineLimit(2)
                    Text(notif.timeAgo).font(.system(size: 11)).foregroundColor(.secondary.opacity(0.7))
                }
            }
            .padding(14)
        }
    }
}
