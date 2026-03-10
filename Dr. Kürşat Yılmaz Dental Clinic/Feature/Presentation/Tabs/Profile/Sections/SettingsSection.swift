//
//  SettingsSection.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct NotificationsDetailView: View {
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


struct EditProfileView: View {
    @State var patient: Patient
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Profili Düzenle")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Avatar
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color.kyAccent, Color.kyAccentDark],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 90, height: 90)
                                Text(patient.avatarLetter)
                                    .font(.kySerif(34, weight: .bold))
                                    .foregroundColor(.kyBackground)
                            }
                            Button {
                                // Change photo
                            } label: {
                                KYBadge(text: "Fotoğrafı Değiştir", color: .kyAccent, icon: "camera.fill")
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Form fields
                        KYCard {
                            VStack(spacing: 16) {
                                ProfileTextField(label: "Ad", placeholder: patient.firstName, text: $firstName, icon: "person.fill")
                                KYDivider()
                                ProfileTextField(label: "Soyad", placeholder: patient.lastName, text: $lastName, icon: "person.fill")
                                KYDivider()
                                ProfileTextField(label: "Telefon", placeholder: patient.phone ?? "", text: $phone, icon: "phone.fill")
                                KYDivider()
                                ProfileTextField(label: "E-posta", placeholder: patient.email ?? "", text: $email, icon: "envelope.fill")
                            }
                        }

                        // Non-editable info
                        KYCard {
                            VStack(spacing: 14) {
                                KYDetailRow(icon: "number", label: "TC Kimlik No", value: patient.tcKimlikNo ?? "", iconColor: .kySubtext)
                                KYDivider()
                                KYDetailRow(icon: "calendar", label: "Doğum Tarihi", value: patient.birthDate.kyFormatted, iconColor: .kySubtext)
                                KYDivider()
                                KYDetailRow(icon: "person.2.fill", label: "Cinsiyet", value: patient.gender.rawValue, iconColor: .kySubtext)
                            }
                        }

                        ActionButton(title: "Değişiklikleri Kaydet", icon: "checkmark.circle.fill", color: .kyAccent, style: .filled) {}
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            firstName = patient.firstName
            lastName = patient.lastName
            phone = patient.phone ?? ""
            email = patient.email ?? ""
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Profile Text Field

struct ProfileTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.kyAccent.opacity(0.10))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.kyAccent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.kyMono(10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(.kySubtext)
                TextField(placeholder, text: $text)
                    .font(.kySans(15))
                    .foregroundColor(.kyText)
                    .tint(.kyAccent)
            }
        }
    }
}

// MARK: - Loyalty Points

struct LoyaltyPointsView: View {
    @State var patient: Patient

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Sadakat Puanları")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Points hero
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.kyAccent.opacity(0.12))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "star.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.kyAccent)
                            }
                            Text("\(patient.loyaltyPoints)")
                                .font(.kySerif(48, weight: .bold))
                                .foregroundColor(.kyText)
                            Text("Sadakat Puanı")
                                .font(.kyMono(13, weight: .semibold))
                                .tracking(1)
                                .foregroundColor(.kySubtext)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(28)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1)
                        )

                        KYCard {
                            VStack(spacing: 12) {
                                Text("Puan Kazanma")
                                    .font(.kySans(15, weight: .bold))
                                    .foregroundColor(.kyText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                VStack(spacing: 8) {
                                    LoyaltyRow(icon: "calendar.badge.checkmark", text: "Her randevu: +50 puan", color: .kyBlue)
                                    LoyaltyRow(icon: "heart.text.square.fill", text: "Tedavi tamamlama: +200 puan", color: .kyGreen)
                                    LoyaltyRow(icon: "star.fill", text: "Değerlendirme bırakma: +30 puan", color: .kyAccent)
                                    LoyaltyRow(icon: "person.badge.plus.fill", text: "Arkadaş davet: +100 puan", color: .kyPurple)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct LoyaltyRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(width: 22)
            Text(text)
                .font(.kySans(14))
                .foregroundColor(.kyText)
            Spacer()
        }
    }
}

// MARK: - Help & Support

struct HelpSupportView: View {
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Yardım & Destek")
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        KYCard {
                            VStack(spacing: 2) {
                                KYNavigationRow(icon: "phone.fill", title: "Kliniği Ara", subtitle: "+90 (232) 000 00 00", iconBg: .kyGreen) {}
                                KYDivider()
                                KYNavigationRow(icon: "message.fill", title: "WhatsApp", subtitle: "Hızlı mesaj gönder", iconBg: Color(red: 0.24, green: 0.72, blue: 0.44)) {}
                                KYDivider()
                                KYNavigationRow(icon: "envelope.fill", title: "E-posta", subtitle: "info@kyclinic.com", iconBg: .kyBlue) {}
                            }
                        }

                        KYCard {
                            VStack(spacing: 2) {
                                KYNavigationRow(icon: "questionmark.circle.fill", title: "Sık Sorulan Sorular", iconBg: .kyAccent) {}
                                KYDivider()
                                KYNavigationRow(icon: "bubble.left.and.exclamationmark.bubble.right.fill", title: "Geri Bildirim Gönder", iconBg: .kyPurple) {}
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Privacy Policy

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                KYDetailHeader(title: "Gizlilik Politikası")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        KYBadge(text: "KVKK Uyumlu", color: .kyGreen, icon: "checkmark.shield.fill")

                        VStack(alignment: .leading, spacing: 12) {
                            policySection(title: "Kişisel Verilerin Korunması",
                                body: "KY Klinik olarak 6698 sayılı KVKK kapsamında kişisel verileriniz güvence altındadır. Sağlık verileriniz yalnızca tedavi amaçlı kullanılmaktadır.")
                            policySection(title: "Veri Saklama",
                                body: "Hasta kayıtları yasal süre olan 5 yıl boyunca güvenli sunucularda saklanmaktadır.")
                            policySection(title: "Veri Haklarınız",
                                body: "Verilerinize erişme, düzeltme ve silme hakkına sahipsiniz. Talep için info@kyclinic.com adresine başvurabilirsiniz.")
                        }
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
    func policySection(title: String, body: String) -> some View {
        KYCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.kySans(15, weight: .bold))
                    .foregroundColor(.kyText)
                Text(body)
                    .font(.kySans(13))
                    .foregroundColor(.kySubtext)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
