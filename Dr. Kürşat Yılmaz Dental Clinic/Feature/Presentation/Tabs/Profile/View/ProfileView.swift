import SwiftUI


private let menuSections: [ProfileMenuSection] = [
    ProfileMenuSection(
title: "Hesap",
 items: [
    ProfileMenuItem(
        title: "Kişisel Bilgiler",
        route: .editProfile,
        subtitle: "Ad, telefon, doğum tarihi",
        icon: "person.fill",
        color: Color(red: 0.82, green: 0.72, blue: 0.50),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Sağlık Bilgileri",
        route: .healthHistory,
        subtitle: "Kan grubu, alerjiler, notlar",
        icon: "cross.case.fill",
        color: Color(red: 0.38, green: 0.78, blue: 0.50),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Şifre & Güvenlik",
        route: .editProfile,
        subtitle: nil,
        icon: "lock.fill",
        color: Color(red: 0.30, green: 0.60, blue: 0.90),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ]
),
    ProfileMenuSection(
title: "Klinik",
items: [
    ProfileMenuItem(
        title: "Tedavi Geçmişim",
        route: .healthHistory,
        subtitle: nil,
        icon: "clock.fill",
        color: Color(red: 0.55, green: 0.45, blue: 0.85),
        trailingText: "5 işlem",
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Belgelerim",
        route: .paymentMethods,
        subtitle: "Röntgen, raporlar",
        icon: "doc.fill",
        color: Color(red: 0.90, green: 0.55, blue: 0.30),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Fatura & Ödemeler",
        route: .paymentMethods,
        subtitle: nil,
        icon: "creditcard.fill",
        color: Color(red: 0.82, green: 0.72, blue: 0.50),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ]
),
    ProfileMenuSection(
title: "Uygulama",
items: [
    ProfileMenuItem(
        title: "Bildirimler",
        route: .notifications,
        subtitle: nil,
        icon: "bell.fill",
        color: Color(red: 0.25, green: 0.70, blue: 0.85),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Dil",
        route: .editProfile,
        subtitle: nil,
        icon: "globe",
        color: Color(red: 0.40, green: 0.75, blue: 0.65),
        trailingText: "Türkçe",
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Tema",
        route: .privacyPolicy,
        subtitle: nil,
        icon: "moon.fill",
        color: Color(red: 0.55, green: 0.45, blue: 0.85),
        trailingText: "Koyu",
        isDestructive: false,
        hasChevron: true
    ),
    ProfileMenuItem(
        title: "Gizlilik Politikası",
        route: .privacyPolicy,
        subtitle: nil,
        icon: "hand.raised.fill",
        color: Color(red: 0.60, green: 0.58, blue: 0.55),
        trailingText: nil,
        isDestructive: false,
        hasChevron: true
    ),
    ]
),
    ProfileMenuSection(
title: "",
items: [
    ProfileMenuItem(
        title: "Çıkış Yap",
        route: .logout,
        subtitle: nil,
        icon: "arrow.right.square.fill",
        color: Color(red: 0.85, green: 0.35, blue: 0.35),
        trailingText: nil,
        isDestructive: true,
        hasChevron: false
    ),
    ]
),
]


struct ProfileView: View {
    
    @EnvironmentObject private var fs: FirestoreService
    @EnvironmentObject private var currentUser: CurrentUser
    @EnvironmentObject private var navState: AppNavigationState
    
    @State private var appeared = false
    
    var body: some View {
        NavigationStack(path: $navState.profileNavPath){
            ZStack {
                Color.kyBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        statsRow
                            .padding(.top, 20)
                        nextAppointmentBanner
                            .padding(.top, 16)
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
            .navigationDestination(for: ProfileDestination.self) { route in
                switch route {
                case .editProfile:
                    EditProfileView()
                case .healthHistory:
                    EmptyView()
                case .helpSupport:
                    EmptyView()
                case .logout:
                    EmptyView()
                case .notifications:
                    NotificationsSettingsView()
                case .paymentMethods:
                    EmptyView()
                case .privacyPolicy:
                    EmptyView()
                case .settings:
                    EmptyView()
                }
            }
        }
    }
    
    
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
                        Text(currentUser.avatarLetter)
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
                        Text(currentUser.fullName)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Color.kyText)

                        HStack(spacing: 5) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.kySubtext)
                            Text(currentUser.patient?.email ?? "Not found")
                                .font(.system(size: 12))
                                .foregroundColor(Color.kySubtext)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.kySubtext)
                            Text(currentUser.patient?.phone ?? "Not found")
                                .font(.system(size: 12))
                                .foregroundColor(Color.kySubtext)
                        }

                        // Member badge
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color.kyAccent)
                            Text("Üye: \(currentUser.patient?.createdAt.formatted() ?? "")")
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
                value: "\("user.totalAppointments")",
                label: "Toplam Randevu",
                icon: "calendar",
                color: Color(red: 0.30, green: 0.60, blue: 0.90)
            )
            ProfileStatCard(
                value: "\("user.completedTreatments")",
                label: "Tamamlanan",
                icon: "checkmark.circle.fill",
                color: Color.kyGreen
            )
            ProfileStatCard(
                value: currentUser.patient?.bloodType?.rawValue ?? "Not found",
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
        if let next = currentUser.patient {
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
//                    Text("Test")
//                        .font(.system(size: 15, weight: .bold, design: .serif))
//                        .foregroundColor(Color.kyText)
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
                                navState
                                    .navigateToSectionFromProfile(
                                        destination: item.route
                                    )
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


// MARK: - Preview

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
