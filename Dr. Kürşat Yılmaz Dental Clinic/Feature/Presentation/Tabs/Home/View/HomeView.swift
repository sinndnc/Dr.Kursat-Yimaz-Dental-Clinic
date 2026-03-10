//
//  HomeView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI
import AVKit
import MapKit

struct HomeView: View {
    
    @Injected private var fs: FirestoreServiceProtocol
    
    @EnvironmentObject private var vm: HomeViewModel
    @EnvironmentObject private var authVm: AuthViewModel
    @EnvironmentObject private var navState: HomeNavigationState
    
    @Environment(AppNavigationState.self) private var AppNavState: AppNavigationState
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            ZStack(alignment: .top) {
                Color.kyBackground.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        if authVm.authState == .authenticated {
                            appointmentCardSection
                        }
                        featuredServicesSection
                        statsSection
                        technologySection
                        testimonialsSection
                        footerCTA
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { vm.greetingOpacity = 1 ; vm.heroScale = 1.0 } }
            .navigationDestination(for: HomeDestination.self) { route in
                switch route{
                case .newAppointment:
                    BookingView()
                case .clinicVideo:
                    VideoPlayerView()
                case .notifications:
                    NotificationsView()
                case .appointmentDetail(let apt):
                    AppointmentDetailView(appointment: apt)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.18), Color.kyBackground],
                    center: UnitPoint(x: 0.85, y: 0.1),
                    startRadius: 0,
                    endRadius: 275
                )
                .ignoresSafeArea()
            }
            .frame(height: 300)
            
            VStack(alignment: .leading, spacing: 0) {
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
                    
                    //                     Notification bell
                    ZStack(alignment: .topTrailing) {
                        Button { navState.navigate(to: .notifications) } label: {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.kySubtext)
                                .padding(12)
                                .background(Color.kyCard)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().strokeBorder(Color.kyBorder, lineWidth: 1)
                                )
                        }
                        if vm.showAppointmentBadge {
                            Circle()
                                .fill(Color.kyAccent)
                                .frame(width: 9, height: 9)
                                .offset(x: 2, y: -1)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                // Hero text
                VStack(alignment: .leading, spacing: 10) {
                    Text("Yeni Nesil\nGülüş Tasarımı")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                        .lineSpacing(3)
                        .opacity(vm.greetingOpacity)
                        .scaleEffect(vm.heroScale, anchor: .leading)
                    
                    Text("Dijital planlama · Minimal invaziv · Kişiye özel")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kySubtext)
                        .opacity(vm.greetingOpacity)
                    
                    // CTA Row
                    HStack(spacing: 12) {
                        Button { navState.navigate(to: .newAppointment) } label: {
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
                        
                        Button {
                            navState.navigate(to: .clinicVideo)
                        } label: {
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
                    .opacity(vm.greetingOpacity)
                }
                .padding(.bottom)
                .padding(.horizontal)
                .safeAreaPadding(.top)
            }
        }
    }
    
    
    private var appointmentCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Yaklaşan Randevu", subtitle: "Takvimde görüntüle →"){
                AppNavState.navigateToTab(.appointments)
            }
            
            if let appointment = fs.appointments.next {
                AppointmentCard(appointment: appointment){
                    navState.navigate(to: .appointmentDetail(apt: appointment))
                }
                .padding(.horizontal)
            }else{
                NoAppointmentCard{
                    navState.navigate(to: .newAppointment)
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 32)
    }
    
    
    private var featuredServicesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Öne Çıkan Tedaviler", subtitle: "Tümünü gör →"){
                AppNavState.navigateToTab(.services)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(fs.services, id: \.self) { service in
                        Button {
//                            AppNavState.navigateToService(service: service)
                        } label: {
                            FeaturedServicePill(
                                name: service.title,
                                icon: service.sfSymbol,
                                color: service.accentColor
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
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
            sectionHeader(title: "Rakamlarla KY Clinic", subtitle: nil){}
            
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
            sectionHeader(title: "Teknoloji Altyapısı", subtitle: nil){
                
            }
            
            VStack(spacing: 10) {
                ForEach(TechItemData.items) { item in
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
            sectionHeader(title: "Hasta Deneyimleri", subtitle: nil){
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 14) {
//                    ForEach(FirestoreMockService.testimonials) { item in
//                        TestimonialCard(testimonial: item)
//                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
        .padding(.top, 32)
    }
    
    
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
                ContactButton(label: "Ara",       icon: "phone.fill",    isPrimary: true){
                    vm.makePhoneCall()
                }
                ContactButton(label: "WhatsApp",  icon: "message.fill",  isPrimary: false){
                    vm.sendWhatsAppMessage()
                }
                ContactButton(label: "Harita",    icon: "map.fill",      isPrimary: false){
                    vm.showMap.toggle()
                }
                .confirmationDialog(
                    "Choose a Map App",
                    isPresented: $vm.showMap,
                    titleVisibility: .visible
                ) {
                    Button("Apple Maps") {
                        vm.openInAppleMaps()
                    }
                    
                    // Google Maps yüklüyse göster
                    if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                        Button("Google Maps") {
                            vm.openInGoogleMaps()
                        }
                    }
                    
                    // Yandex Maps / Navi yüklüyse göster (Türkiye'de çok yaygın)
                    if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) ||
                        UIApplication.shared.canOpenURL(URL(string: "yandexnavi://")!) {
                        Button("Yandex Maps / Navi") {
                            vm.openInYandex()
                        }
                    }
                    
                    // İsterseniz Waze de eklenebilir
                    if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
                        Button("Waze") {
                            vm.openInWaze()
                        }
                    }
                    
                    Button("İptal", role: .cancel) {}
                }
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
    
    private func sectionHeader(title: String, subtitle: String?,action: @escaping () -> Void) -> some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
            Spacer()
            if let sub = subtitle {
                Button(action: action){
                    Text(sub)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kyAccent)
                }
            }
        }
        .padding(.horizontal, 20)
    }
  
    
}


#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
