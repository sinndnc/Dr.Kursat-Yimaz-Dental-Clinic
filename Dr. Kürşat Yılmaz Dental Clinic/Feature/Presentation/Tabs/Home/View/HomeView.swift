import SwiftUI
import SwiftUI


struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct Testimonial: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let text: String
    let rating: Int
    let treatment: String
    let avatarColor: Color
}

struct TechItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let badge: String?
}

private let quickActions: [QuickAction] = [
    QuickAction(title: "Randevu\nAl",       icon: "calendar.badge.plus",        color: Color.kyAccent),
    QuickAction(title: "Tedavi\nBilgisi",   icon: "cross.case.fill",             color: Color(red: 0.4, green: 0.75, blue: 0.65)),
    QuickAction(title: "Galeri",            icon: "photo.stack.fill",            color: Color(red: 0.55, green: 0.45, blue: 0.85)),
    QuickAction(title: "İletişim",          icon: "phone.fill",                  color: Color(red: 0.3, green: 0.60, blue: 0.90)),
]

private let techItems: [TechItem] = [
    TechItem(name: "CAD/CAM",        description: "Dijital tarama ile hassas restorasyon",      icon: "cpu.fill",                       badge: nil),
    TechItem(name: "EMS AirFlow",    description: "Biyofilm hedefli konforlu temizlik",         icon: "wind",                           badge: nil),
    TechItem(name: "Straumann",      description: "Dünya standartlarında implant sistemi",      icon: "bolt.shield.fill",               badge: nil),
    TechItem(name: "3D Yazıcı",      description: "Aynı gün kişisel restorasyon üretimi",       icon: "cube.transparent.fill",          badge: "Yakında"),
]

private let featuredServices: [(String, String, Color)] = [
    ("Lamina Kaplama",     "seal.fill",                    Color.kyAccent),
    ("Dental İmplant",     "bolt.shield.fill",             Color(red: 0.3, green: 0.6, blue: 0.9)),
    ("Aligner Tedavisi",   "mouth.fill",                   Color(red: 0.85, green: 0.4, blue: 0.5)),
    ("EMS Temizlik",       "wind",                         Color(red: 0.25, green: 0.7, blue: 0.85)),
    ("Kompozit Tasarım",   "wand.and.stars",               Color(red: 0.4, green: 0.75, blue: 0.65)),
]


struct HomeView: View {
    
    @EnvironmentObject private var appState: AppState
    
    @State private var currentTestimonialIndex = 0
    @State private var greetingOpacity: Double = 0
    @State private var heroScale: CGFloat = 0.97
    @State private var showAppointmentBadge = true
    @State private var isPresented : Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top) {
                Color.kyBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        quickActionsSection
                        appointmentCardSection
                        featuredServicesSection
                        statsSection
                        technologySection
                        testimonialsSection
                        footerCTA
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    greetingOpacity = 1
                    heroScale = 1.0
                }
            }
            .fullScreenCover(isPresented:$isPresented){
                TemyMainView()
            }
        }
        .ignoresSafeArea()
    }
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background mesh gradient
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.18), Color.clear],
                    center: UnitPoint(x: 0.85, y: 0.1),
                    startRadius: 0,
                    endRadius: 300
                )
                .ignoresSafeArea()
             
            }
            .frame(height: 350)
            
            VStack(alignment: .leading, spacing: 0) {
                // Top nav row
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(Color.kyAccent)
                                .frame(width: 5, height: 5)
                            Text("KY CLINIC · ETİLER")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(Color.kyAccent)
                        }
                        Text("İyi Günler 👋")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.kySubtext)
                    }
                    
                    Spacer()
                    
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image("Temy")
                            .resizable()
                            .scaledToFit()
                            .background(Color.kyCard)
                            .frame(width: 50,height: 50)
                            .clipShape(Circle())
                            .overlay(
                                Circle().strokeBorder(Color.kyBorder, lineWidth: 1)
                            )
                    }
                    // Notification bell
//                    ZStack(alignment: .topTrailing) {
//                        Button {} label: {
//                            Image(systemName: "bell.fill")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(Color.kySubtext)
//                                .padding(12)
//                                .background(Color.kyCard)
//                                .clipShape(Circle())
//                                .overlay(
//                                    Circle().strokeBorder(Color.kyBorder, lineWidth: 1)
//                                )
//                        }
//                        if showAppointmentBadge {
//                            Circle()
//                                .fill(Color.kyAccent)
//                                .frame(width: 9, height: 9)
//                                .offset(x: 2, y: -1)
//                        }
//                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                // Hero text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Yeni Nesil\nGülüş Tasarımı")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                        .lineSpacing(3)
                        .opacity(greetingOpacity)
                        .scaleEffect(heroScale, anchor: .leading)

                    Text("Dijital planlama · Minimal invaziv · Kişiye özel")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kySubtext)
                        .opacity(greetingOpacity)

                    // CTA Row
                    HStack(spacing: 12) {
                        Button {} label: {
                            HStack(spacing: 8) {
                                Text("Randevu Al")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(Color.kyBackground)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 13)
                            .background(
                                LinearGradient(
                                    colors: [Color.kyAccent, Color.kyAccentDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }

                        Button {} label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 14))
                                Text("Kliniği Gör")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(Color.kyText)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 13)
                            .background(Color.kyCard)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(Color.kyBorder, lineWidth: 1))
                        }
                    }
                    .padding(.top, 4)
                    .opacity(greetingOpacity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Hızlı Erişim", subtitle: nil)

            HStack(spacing: 12) {
                ForEach(quickActions) { action in
                    QuickActionButton(action: action)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 28)
    }

    // MARK: - Upcoming Appointment Card

    private var appointmentCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Yaklaşan Randevu", subtitle: "Takvimde görüntüle →")
            
            if let appointment = appState.nextAppointment{
                AppointmentCard(appointment: appointment)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 32)
    }
    
    // MARK: - Featured Services Horizontal Scroll
    
    private var featuredServicesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Öne Çıkan Tedaviler", subtitle: "Tümünü gör →")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featuredServices, id: \.0) { name, icon, color in
                        FeaturedServicePill(name: name, icon: icon, color: color)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Rakamlarla KY Clinic", subtitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(value: "2.500+", label: "Mutlu Hasta",      icon: "person.2.fill",        color: Color.kyAccent)
                StatCard(value: "8+",     label: "Yıl Deneyim",      icon: "clock.fill",           color: Color(red: 0.4, green: 0.75, blue: 0.65))
                StatCard(value: "99%",    label: "Memnuniyet",       icon: "star.fill",            color: Color(red: 0.85, green: 0.4, blue: 0.5))
                StatCard(value: "12",     label: "Tedavi Türü",      icon: "cross.case.fill",      color: Color(red: 0.3, green: 0.6, blue: 0.9))
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 32)
    }

    // MARK: - Technology Section

    private var technologySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Teknoloji Altyapısı", subtitle: nil)

            VStack(spacing: 10) {
                ForEach(techItems) { item in
                    TechRow(item: item)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 32)
    }

    // MARK: - Testimonials

    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Hasta Deneyimleri", subtitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
                    ForEach(FirestoreMockService.testimonials) { item in
                        TestimonialCard(testimonial: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Footer CTA

    private var footerCTA: some View {
        VStack(spacing: 20) {
            // Divider line
            Rectangle()
                .fill(Color.kyBorder)
                .frame(height: 1)
                .padding(.horizontal, 20)

            VStack(spacing: 6) {
                Text("Dönüşümünüz Bir Adım Uzağınızda")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .multilineTextAlignment(.center)
                Text("Kişiye özel muayene için formu doldurun,\nhızlıca sizi arayalım.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.kySubtext)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 32)

            // Contact buttons
            HStack(spacing: 12) {
                ContactButton(label: "Ara",       icon: "phone.fill",    isPrimary: true)
                ContactButton(label: "WhatsApp",  icon: "message.fill",  isPrimary: false)
                ContactButton(label: "Harita",    icon: "map.fill",      isPrimary: false)
            }
            .padding(.horizontal, 20)

            // Footer note
            VStack(spacing: 4) {
                Text("Etiler, Çamlık Yolu Sk. No: 1/2  ·  Beşiktaş, İstanbul")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.kySubtext.opacity(0.6))
                Text("info@drkursatyilmaz.com  ·  +90 538 795 31 53")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.kySubtext.opacity(0.6))
            }
            .padding(.bottom, 48)
        }
        .padding(.top, 36)
        .padding(.bottom,50)
    }
    
    // MARK: - Section Header Helper

    private func sectionHeader(title: String, subtitle: String?) -> some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
            Spacer()
            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.kyAccent)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let action: QuickAction
    @State private var pressed = false

    var body: some View {
        Button {} label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(action.color.opacity(0.14))
                        .frame(width: 50, height: 50)
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(action.color)
                }
                Text(action.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Appointment Card

struct AppointmentCard: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 16) {
            // Date badge
            VStack(spacing: 2) {
                Text("MAR")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Color.kyAccent)
                Text("12")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(appointment.time)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
            }
            .frame(width: 58)
            .padding(.vertical, 14)
            .background(Color.kyAccent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.type.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kySubtext)
                    Text(appointment.doctorName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kyAccent.opacity(0.7))
                    Text("KY Clinic · Etiler")
                        .font(.system(size: 11))
                        .foregroundColor(Color.kySubtext.opacity(0.7))
                }
            }

            Spacer()

            VStack(spacing: 8) {
                // Status dot
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0.4, green: 0.78, blue: 0.5))
                        .frame(width: 6, height: 6)
                    Text("Onaylı")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.78, blue: 0.5))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.4, green: 0.78, blue: 0.5).opacity(0.1))
                .clipShape(Capsule())

                Button {} label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.kySubtext)
                }
            }
        }
        .padding(16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Featured Service Pill

struct FeaturedServicePill: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 28) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 13, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 3) {
                        Text("Detaylar")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(color.opacity(0.85))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(color.opacity(0.85))
                    }
                }
            }
            .padding(16)
            .frame(width: 140, alignment: .leading)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.kySubtext)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Tech Row

struct TechRow: View {
    let item: TechItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.kyAccent.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.kyAccent)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.kyText)
                    if let badge = item.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.3)
                            .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.85))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.55, green: 0.45, blue: 0.85).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color.kyAccent.opacity(item.badge == nil ? 0.8 : 0.25))
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Testimonial Card

struct TestimonialCard: View {
    let testimonial: Testimonial

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Stars
            HStack(spacing: 3) {
                ForEach(0..<testimonial.rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kyAccent)
                }
            }
            Text("\(testimonial.text)")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundColor(Color.kyText.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // Footer
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(testimonial.avatarColor.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Text(testimonial.initials)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(testimonial.avatarColor)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(testimonial.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kyText)
                    Text(testimonial.treatment)
                        .font(.system(size: 10))
                        .foregroundColor(Color.kySubtext)
                }
            }
        }
        .padding(18)
        .frame(width: 240, alignment: .leading)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

// MARK: - Contact Button

struct ContactButton: View {
    let label: String
    let icon: String
    let isPrimary: Bool

    var body: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(isPrimary ? Color.kyBackground : Color.kyText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isPrimary
                ? AnyView(LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing))
                : AnyView(Color.kyCard)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                isPrimary ? nil :
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
