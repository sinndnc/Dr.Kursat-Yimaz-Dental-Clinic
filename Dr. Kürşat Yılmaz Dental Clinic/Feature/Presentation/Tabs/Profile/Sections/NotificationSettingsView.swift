//
//  SettingsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

//TODO: make here
struct NotificationSettingsView: View {
    @EnvironmentObject private var vm: ProfileViewModel
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Bildirim Ayarları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        notifGroup(title: "Kanallar", items: [
                            ("bell.badge.fill", "Push Bildirimleri", $vm.pushEnabled, Color.kyBlue),
                            ("message.fill", "SMS Bildirimleri", $vm.smsEnabled, Color.kyGreen),
                            ("bubble.left.and.bubble.right.fill", "WhatsApp", $vm.whatsappEnabled, Color(red: 0.24, green: 0.72, blue: 0.44)),
                            ("envelope.fill", "E-posta", $vm.emailNotifications, Color.kyAccent),
                        ])
                        
                        notifGroup(title: "Randevu Hatırlatıcılar", items: [
                            ("clock.badge.fill", "24 Saat Önce", $vm.appointmentReminder24h, Color.kyBlue),
                            ("clock.badge.fill", "1 Saat Önce", $vm.appointmentReminder1h, Color.kyOrange),
                        ])
                        
                        notifGroup(title: "Diğer", items: [
                            ("gift.fill", "Kampanyalar", $vm.campaignNotifications, Color.kyPurple),
                            ("birthday.cake.fill", "Doğum Günü Mesajı", $vm.birthdayMessages, Color.kyAccent),
                        ])
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    func notifGroup(title: String, items: [(String, String, Binding<Bool>, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.kyMono(9, weight: .bold))
                .tracking(2)
                .foregroundColor(.kySubtext)
            
            VStack(spacing: 2) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(item.3.opacity(0.15))
                                .frame(width: 38, height: 38)
                            Image(systemName: item.0)
                                .font(.system(size: 15))
                                .foregroundColor(item.3)
                        }
                        Text(item.1)
                            .font(.kySans(15))
                            .foregroundColor(.kyText)
                        Spacer()
                        Toggle("", isOn: item.2)
                            .toggleStyle(SwitchToggleStyle(tint: item.3))
                            .labelsHidden()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    
                    if index < items.count - 1 {
                        KYDivider()
                    }
                }
            }
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.kyBorder, lineWidth: 1))
        }
    }
}
