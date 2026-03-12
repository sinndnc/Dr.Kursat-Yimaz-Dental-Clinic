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
    
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var serVM: ServicesViewModel
    @EnvironmentObject private var authVm: AuthViewModel
    @EnvironmentObject private var apptVM: AppointmentViewModel
    
    @EnvironmentObject private var navState: HomeNavigationState
    
    @State private var heroScale: CGFloat = 0.97
    @State private var greetingOpacity: Double = 0
    @State private var showClinicVideo: Bool = false
    @State private var showAppointment: Bool = false
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            ZStack(alignment: .top) {
                Color.kyBackground.ignoresSafeArea()
                
                BackgroundVideoPlayerView(videoName: "servicesVideo", videoExtension: "mp4")
                    .ignoresSafeArea()
                    .frame(height: 300)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0.0),
                                .init(color: .black, location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
                        appointmentCardSection
                        featuredServicesSection
                        statsSection
                        technologySection
//                        testimonialsSection
                        footerCTA
                    }
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .environmentObject(vm)
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { greetingOpacity = 1 ; heroScale = 1.0 } }
            .navigationDestination(for: HomeDestination.self) { route in
                switch route{
                case .newAppointment:
                    BookingView()
                case .notifications:
                    NotificationsView()
                case .appointmentDetail(let apt):
                    AppointmentDetailView(appointment: apt)
                case .serviceDetail(let service):
                    ServiceDetailView(service: service)
                }
            }
            .fullScreenCover(isPresented: $showClinicVideo) {
                let url = URL(string: "https://framerusercontent.com/assets/abt50i9bj1pkM8Z69REgS1LLCo.mp4")!
                VideoPlayerView(videoURL: url)
            }
            .fullScreenCover(isPresented: $showAppointment) {
                BookingWebView()
            }
        }
    }
    
    private var appointmentCardSection: some View{
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Yaklaşan Randevu", subtitle: "Takvimde görüntüle →"){
                //AppNavState.navigateToTab(.appointments)
            }
            Group{
                switch authVm.authState {
                case .loading:
                    SkeletonAppointmentCard()
                case .unauthenticated , .registrationPending:
                    NoAppointmentCard { navState.navigate(to: .newAppointment) }
                case .authenticated:
                    if let appointment = apptVM.nextAppointment {
                        FeaturedAppointmentCard(appointment: appointment) {
                            navState.navigate(to: .appointmentDetail(apt: appointment))
                        }
                    }else{
                        NoAppointmentCard { navState.navigate(to: .newAppointment) }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.kyAccent.opacity(0.12), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
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
                        Button {  showAppointment = true} label: {
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
                            showClinicVideo.toggle()
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
                    .opacity(greetingOpacity)
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea()
    }
    
    
    private var featuredServicesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Öne Çıkan Tedaviler", subtitle: "Tümünü gör →"){
//                AppNavState.navigateToTab(.services)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(serVM.services, id: \.self) { service in
                        Button {
                            navState.navigate(to: .serviceDetail(service: service))
                        } label: {
                            FeaturedServiceCard(
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
    
    
    private var technologySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Teknoloji Altyapısı", subtitle: nil){}
            VStack(spacing: 10) {
                ForEach(TechItemData.items) { item in
                    TechRow(item: item)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 32)
    }
    
    
    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Hasta Deneyimleri", subtitle: nil){ }
            
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
