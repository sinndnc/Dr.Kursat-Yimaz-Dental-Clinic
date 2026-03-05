import SwiftUI

// MARK: - Models

struct UserProfile {
    var fullName: String
    var email: String
    var phone: String
    var birthDate: String
    var bloodType: String
    var memberSince: String
    var avatarInitials: String
    var totalAppointments: Int
    var completedTreatments: Int
    var nextAppointmentDate: String?
}

enum NotificationSetting: String, CaseIterable {
    case appointmentReminder = "Randevu Hatırlatıcısı"
    case treatmentUpdates    = "Tedavi Güncellemeleri"
    case promotions          = "Kampanya & Haberler"
    case smsAlerts           = "SMS Bildirimleri"
}

struct ProfileMenuSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [ProfileMenuItem]
}

struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let trailingText: String?
    let isDestructive: Bool
    let hasChevron: Bool
}

// MARK: - Sample Data

private let sampleUser = UserProfile(
    fullName: "Sinan Dinç",
    email: "sinandinc77@icloud.com",
    phone: "+90 536 636 08 80",
    birthDate: "20 Ocak 2004",
    bloodType: "A Rh+",
    memberSince: "Ocak 2024",
    avatarInitials: "SD",
    totalAppointments: 7,
    completedTreatments: 5,
    nextAppointmentDate: "12 Mart 2026"
)

private let menuSections: [ProfileMenuSection] = [
    ProfileMenuSection(title: "Hesap", items: [
        ProfileMenuItem(title: "Kişisel Bilgiler",    subtitle: "Ad, telefon, doğum tarihi",    icon: "person.fill",            color: Color(red: 0.82, green: 0.72, blue: 0.50), trailingText: nil,       isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Sağlık Bilgileri",   subtitle: "Kan grubu, alerjiler, notlar",  icon: "cross.case.fill",        color: Color(red: 0.38, green: 0.78, blue: 0.50), trailingText: nil,       isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Şifre & Güvenlik",   subtitle: nil,                             icon: "lock.fill",              color: Color(red: 0.30, green: 0.60, blue: 0.90), trailingText: nil,       isDestructive: false, hasChevron: true),
    ]),
    ProfileMenuSection(title: "Klinik", items: [
        ProfileMenuItem(title: "Tedavi Geçmişim",    subtitle: nil,                             icon: "clock.fill",             color: Color(red: 0.55, green: 0.45, blue: 0.85), trailingText: "5 işlem", isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Belgelerim",         subtitle: "Röntgen, raporlar",             icon: "doc.fill",               color: Color(red: 0.90, green: 0.55, blue: 0.30), trailingText: nil,       isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Fatura & Ödemeler",  subtitle: nil,                             icon: "creditcard.fill",        color: Color(red: 0.82, green: 0.72, blue: 0.50), trailingText: nil,       isDestructive: false, hasChevron: true),
    ]),
    ProfileMenuSection(title: "Uygulama", items: [
        ProfileMenuItem(title: "Bildirimler",        subtitle: nil,                             icon: "bell.fill",              color: Color(red: 0.25, green: 0.70, blue: 0.85), trailingText: nil,       isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Dil",                subtitle: nil,                             icon: "globe",                  color: Color(red: 0.40, green: 0.75, blue: 0.65), trailingText: "Türkçe",  isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Tema",               subtitle: nil,                             icon: "moon.fill",              color: Color(red: 0.55, green: 0.45, blue: 0.85), trailingText: "Koyu",    isDestructive: false, hasChevron: true),
        ProfileMenuItem(title: "Gizlilik Politikası",subtitle: nil,                             icon: "hand.raised.fill",       color: Color(red: 0.60, green: 0.58, blue: 0.55), trailingText: nil,       isDestructive: false, hasChevron: true),
    ]),
    ProfileMenuSection(title: "", items: [
        ProfileMenuItem(title: "Çıkış Yap",          subtitle: nil,                             icon: "arrow.right.square.fill",color: Color(red: 0.85, green: 0.35, blue: 0.35), trailingText: nil,       isDestructive: true,  hasChevron: false),
    ]),
]

// MARK: - ProfileView

struct ProfileView: View {
    @State private var user = sampleUser
    @State private var showEditProfile   = false
    @State private var showNotifications = false
    @State private var showHealthInfo    = false
    @State private var showLogoutAlert   = false
    @State private var appeared          = false

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    statsRow
                        .padding(.top, 20)
                    nextAppointmentBanner
                        .padding(.top, 16)
                    notificationTogglesSection
                        .padding(.top, 28)
                    menuSectionsView
                        .padding(.top, 8)
                    footerNote
                        .padding(.top, 32)
                        .padding(.bottom, 52)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                appeared = true
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(user: $user)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSheet()
        }
        .alert("Çıkış Yap", isPresented: $showLogoutAlert) {
            Button("Çıkış Yap", role: .destructive) { }
            Button("İptal", role: .cancel) { }
        } message: {
            Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.16), Color.clear],
                    center: UnitPoint(x: 0.5, y: 0.0),
                    startRadius: 20,
                    endRadius: 260
                ).ignoresSafeArea()
            }
            .frame(height: 260)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 5) {
                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                            Text("KY CLINIC")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .tracking(3)
                                .foregroundColor(Color.kyAccent)
                        }
                        Text("Profilim")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                    }
                    Spacer()
                    // Edit button
                    Button { showEditProfile = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Düzenle")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color.kyAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.kyAccent.opacity(0.10))
                        .clipShape(Capsule())
                        .overlay(Capsule().strokeBorder(Color.kyAccent.opacity(0.2), lineWidth: 1))
                    }
                    .buttonStyle(ProfileScaleStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                
                // Avatar + info
                HStack(spacing: 18) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.kyAccent, Color.kyAccentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 76, height: 76)
                        Text(user.avatarInitials)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.kyBackground)
                    }
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.kyAccent.opacity(0.6), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    )
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(user.fullName)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)

                        HStack(spacing: 5) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.kySubtext)
                            Text(user.email)
                                .font(.system(size: 12))
                                .foregroundColor(Color.kySubtext)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.kySubtext)
                            Text(user.phone)
                                .font(.system(size: 12))
                                .foregroundColor(Color.kySubtext)
                        }

                        // Member badge
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color.kyAccent)
                            Text("Üye: \(user.memberSince)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color.kyAccent)
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.kyAccent.opacity(0.10))
                        .clipShape(Capsule())
                        .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var statsRow: some View {
        HStack(spacing: 10) {
            ProfileStatCard(
                value: "\(user.totalAppointments)",
                label: "Toplam Randevu",
                icon: "calendar",
                color: Color(red: 0.30, green: 0.60, blue: 0.90)
            )
            ProfileStatCard(
                value: "\(user.completedTreatments)",
                label: "Tamamlanan",
                icon: "checkmark.circle.fill",
                color: Color.kyGreen
            )
            ProfileStatCard(
                value: user.bloodType,
                label: "Kan Grubu",
                icon: "drop.fill",
                color: Color.kyDanger
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Next Appointment Banner
    
    @ViewBuilder
    private var nextAppointmentBanner: some View {
        if let next = user.nextAppointmentDate {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.kyGreen.opacity(0.15))
                        .frame(width: 46, height: 46)
                    Image(systemName: "clock.badge.checkmark.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.kyGreen)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Yaklaşan Randevu")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(0.5)
                        .foregroundColor(Color.kyGreen)
                    Text(next)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                    Text("Dr. Kürşat Yılmaz · KY Clinic")
                        .font(.system(size: 11))
                        .foregroundColor(Color.kySubtext)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.kySubtext.opacity(0.5))
            }
            .padding(16)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.kyGreen.opacity(0.18), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Notification Toggles

    private var notificationTogglesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bildirim Tercihleri")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Spacer()
            }
            .padding(.horizontal, 20)

            NotificationTogglesCard()
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Menu Sections

    private var menuSectionsView: some View {
        VStack(spacing: 28) {
            ForEach(menuSections) { section in
                VStack(alignment: .leading, spacing: 10) {
                    if !section.title.isEmpty {
                        Text(section.title.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(2.5)
                            .foregroundColor(Color.kySubtext)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 2) {
                        ForEach(section.items) { item in
                            ProfileMenuRow(item: item) {
                                handleTap(item: item)
                            }
                        }
                    }
                    .background(Color.kyCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.kyBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 16)
    }

    private func handleTap(item: ProfileMenuItem) {
        if item.isDestructive {
            showLogoutAlert = true
        } else if item.title == "Bildirimler" {
            showNotifications = true
        } else if item.title == "Kişisel Bilgiler" {
            showEditProfile = true
        }
    }

    // MARK: - Footer

    private var footerNote: some View {
        VStack(spacing: 6) {
            Text("KY Clinic v1.0.0")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.kySubtext.opacity(0.4))
            Text("© 2025 Dr. Kürşat Yılmaz Klinik")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.kySubtext.opacity(0.3))
        }
    }
}

// MARK: - Profile Stat Card

struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.13))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.kySubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Notification Toggles Card

struct NotificationTogglesCard: View {
    @State private var toggleStates: [NotificationSetting: Bool] = [
        .appointmentReminder: true,
        .treatmentUpdates:    true,
        .promotions:          false,
        .smsAlerts:           true,
    ]

    private let icons: [NotificationSetting: (String, Color)] = [
        .appointmentReminder: ("bell.badge.fill",       Color(red: 0.25, green: 0.70, blue: 0.85)),
        .treatmentUpdates:    ("cross.case.fill",       Color(red: 0.38, green: 0.78, blue: 0.50)),
        .promotions:          ("tag.fill",              Color(red: 0.82, green: 0.72, blue: 0.50)),
        .smsAlerts:           ("message.fill",          Color(red: 0.55, green: 0.45, blue: 0.85)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(NotificationSetting.allCases.enumerated()), id: \.element) { i, setting in
                HStack(spacing: 12) {
                    let iconData = icons[setting]!
                    ZStack {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(iconData.1.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Image(systemName: iconData.0)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(iconData.1)
                    }

                    Text(setting.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.kyText)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { toggleStates[setting] ?? false },
                        set: { toggleStates[setting] = $0 }
                    ))
                    .labelsHidden()
                    .tint(Color.kyAccent)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if i < NotificationSetting.allCases.count - 1 {
                    Rectangle()
                        .fill(Color.kyBorder)
                        .frame(height: 1)
                        .padding(.leading, 62)
                }
            }
        }
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Profile Menu Row

struct ProfileMenuRow: View {
    let item: ProfileMenuItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(item.isDestructive ? Color.kyDanger.opacity(0.12) : item.color.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(item.isDestructive ? Color.kyDanger : item.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(item.isDestructive ? Color.kyDanger : Color.kyText)
                    if let sub = item.subtitle {
                        Text(sub)
                            .font(.system(size: 11))
                            .foregroundColor(Color.kySubtext)
                    }
                }

                Spacer()

                if let trailing = item.trailingText {
                    Text(trailing)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }

                if item.hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.kySubtext.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(ProfileScaleStyle())
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Binding var user: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var name:  String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var birth: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                            Text("PROFİL DÜZENLE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(3).foregroundColor(Color.kyAccent)
                        }
                        Text("Bilgilerini Güncelle")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                    }
                    .padding(.top, 8)

                    // Avatar editor
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color.kyAccent, Color.kyAccentDark],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ))
                                .frame(width: 72, height: 72)
                            Text(user.avatarInitials)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color.kyBackground)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Profil Fotoğrafı")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.kyText)
                            Button {} label: {
                                Text("Fotoğraf Değiştir")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.kyAccent)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.kyCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.kyBorder, lineWidth: 1))

                    // Fields
                    VStack(spacing: 14) {
                        EditField(label: "AD SOYAD",      placeholder: user.fullName, icon: "person.fill",    color: Color.kyAccent,                             text: $name)
                        EditField(label: "E-POSTA",       placeholder: user.email,    icon: "envelope.fill",  color: Color(red: 0.30, green: 0.60, blue: 0.90),  text: $email)
                        EditField(label: "TELEFON",       placeholder: user.phone,    icon: "phone.fill",     color: Color(red: 0.38, green: 0.78, blue: 0.50),  text: $phone)
                        EditField(label: "DOĞUM TARİHİ", placeholder: user.birthDate, icon: "calendar",      color: Color(red: 0.55, green: 0.45, blue: 0.85),  text: $birth)
                    }

                    // Save
                    Button {
                        if !name.isEmpty  { user.fullName = name }
                        if !email.isEmpty { user.email = email }
                        if !phone.isEmpty { user.phone = phone }
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Kaydet")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                        }
                        .foregroundColor(Color.kyBackground)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(ProfileScaleStyle())
                    .padding(.bottom, 48)
                }
                .padding(.horizontal, 24)
            }

            // Dismiss
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .padding(10)
                        .background(Color.kySurface)
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Edit Field

struct EditField: View {
    let label: String
    let placeholder: String
    let icon: String
    let color: Color
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(Color.kySubtext)

            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.10))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(color)
                }
                TextField(placeholder, text: $text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.kyText)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BİLDİRİMLER")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(3).foregroundColor(Color.kyAccent)
                        Text("Tercihler")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.kySubtext)
                            .padding(10)
                            .background(Color.kySurface)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 8)

                NotificationTogglesCard()
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Button Style

private struct ProfileScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
