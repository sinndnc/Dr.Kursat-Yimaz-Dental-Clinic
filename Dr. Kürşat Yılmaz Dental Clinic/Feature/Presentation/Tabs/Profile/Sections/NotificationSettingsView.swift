//
//  NotificationSettingsView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//

import SwiftUI

struct NotificationSettingsView: View {
    
//    @EnvironmentObject private var notificationVM: NotificationViewModel
    
    @AppStorage("pref_sms_enabled")         private var smsEnabled             = true
    @AppStorage("pref_whatsapp_enabled")    private var whatsappEnabled        = false
    @AppStorage("pref_email_notifications") private var emailNotifications     = true
    @AppStorage("pref_reminder_24h")        private var appointmentReminder24h = true
    @AppStorage("pref_reminder_1h")         private var appointmentReminder1h  = true
    @AppStorage("pref_campaigns")           private var campaignNotifications  = true
    @AppStorage("pref_birthday_messages")   private var birthdayMessages       = true
    
    @State private var showSettingsAlert = false
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Bildirim Ayarları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
//                        if !notificationVM.isPushAuthorized {
//                            permissionBanner
//                                .padding(.horizontal, 20)
//                                .padding(.top, 8)
//                        }
                        
//                        channelsGroup
//                        remindersGroup
                        otherGroup
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("iOS Bildirimleri", isPresented: $showSettingsAlert) {
            Button("Ayarları Aç") {
                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Push bildirimleri iOS Ayarlar uygulamasından yönetilir.")
        }
    }
    
    
//    private var channelsGroup: some View {
//        NotifGroupView(title: "Kanallar") {
//            NotifRowView(
//                icon: "bell.badge.fill",
//                label: "Push Bildirimleri",
//                subtitle: notificationVM.isPushAuthorized ? "Açık" : "Kapalı — Ayarlardan açın",
//                isOn: pushBinding
//            )
//            KYDivider()
//            NotifRowView(icon: "message.fill",label: "SMS Bildirimleri",isOn: $smsEnabled)
//            KYDivider()
//            NotifRowView(icon: "bubble.left.and.bubble.right.fill", label: "WhatsApp",isOn: $whatsappEnabled)
//            KYDivider()
//            NotifRowView(icon: "envelope.fill",label: "E-posta", isOn: $emailNotifications)
//        }
//        .disabled(!notificationVM.isPushAuthorized)
//    }
    
//    private var remindersGroup: some View {
//        NotifGroupView(title: "Randevu Hatırlatıcılar") {
//            NotifRowView(icon: "clock.badge.fill", label: "24 Saat Önce",isOn: reminder24hBinding)
//            KYDivider()
//            NotifRowView(icon: "clock.badge.fill", label: "1 Saat Önce",isOn: reminder1hBinding)
//        }
//        .disabled(!notificationVM.isPushAuthorized)
//    }
    
    private var otherGroup: some View {
        NotifGroupView(title: "Diğer") {
            NotifRowView(icon: "gift.fill",label: "Kampanyalar",isOn: $campaignNotifications)
            KYDivider()
            NotifRowView(icon: "birthday.cake.fill", label: "Doğum Günü Mesajı", isOn: $birthdayMessages)
        }
//        .disabled(!notificationVM.isPushAuthorized)
    }
    
    // MARK: - Bindings
//    
//    private var pushBinding: Binding<Bool> {
//        Binding(
//            get: { notificationVM.isPushAuthorized },
//            set: { newValue in
//                if newValue { Task { await notificationVM.requestPermission() } }
//                else        { showSettingsAlert = true }
//            }
//        )
//    }
//    
//    private var reminder24hBinding: Binding<Bool> {
//        Binding(
//            get: { appointmentReminder24h },
//            set: {
//                appointmentReminder24h = $0
//                Task { await notificationVM.onReminderPreferencesChanged() }
//            }
//        )
//    }
//    
//    private var reminder1hBinding: Binding<Bool> {
//        Binding(
//            get: { appointmentReminder1h },
//            set: {
//                appointmentReminder1h = $0
//                Task { await notificationVM.onReminderPreferencesChanged() }
//            }
//        )
//    }
//    
    
    private var permissionBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.kyOrange.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.kyOrange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Push bildirimleri kapalı")
                    .font(.kySans(13, weight: .semibold))
                    .foregroundColor(.kyText)
                Text("Randevu hatırlatmaları almak için izin verin.")
                    .font(.kySans(12))
                    .foregroundColor(.kySubtext)
            }
            Spacer()
            Button("Aç") {
                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.kySans(12, weight: .semibold))
            .foregroundColor(.kyBackground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.kyOrange)
            .clipShape(Capsule())
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.kyOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - NotifGroupView
// ForEach + Binding sorununu tamamen ortadan kaldırmak için
// grup içeriği @ViewBuilder ile doğrudan geçiliyor.

private struct NotifGroupView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.kyMono(9, weight: .bold))
                .tracking(2)
                .foregroundColor(.kySubtext)

            VStack(spacing: 0) {
                content
            }
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
    }
}


private struct NotifRowView: View {
    let icon: String
    let label: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.kyBlue.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(Color.kyBlue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.kySans(15))
                    .foregroundColor(.kyText)
                if let subtitle {
                    Text(subtitle)
                        .font(.kySans(11))
                        .foregroundColor(.kySubtext)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.kyBlue))
                .labelsHidden()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
    }
}
