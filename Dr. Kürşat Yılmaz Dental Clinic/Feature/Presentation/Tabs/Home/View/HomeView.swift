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
    
    @EnvironmentObject private var navState: AppNavigationState
    @EnvironmentObject private var appointmentViewModel: AppointmentViewModel
    
    @State private var heroScale: CGFloat = 0.97
    @State private var greetingOpacity: Double = 0
    @State private var currentTestimonialIndex = 0
    
    @State private var showMap: Bool = false
    @State private var showClinicVideo: Bool = false
    @State private var showNotifications: Bool = false
    @State private var showNewAppointment: Bool = false
    @State private var showAppointmentBadge: Bool = true
    @State private var selectedAppointment: Appointment? = nil
    
    let phoneNumber = "905366360880"
    let destinationName = "Dr. Kürşat Yılmaz"
    let message = "Merhaba, bilgi almak istiyorum."
    let destinationCoordinate = CLLocationCoordinate2D(latitude: 41.085185, longitude: 29.027958)
   
    var body: some View {
        NavigationStack(path: $navState.homeNavPath) {
            ZStack(alignment: .top) {
                Color.kyBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection
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
            .sheet(isPresented: $showNotifications){
                NotificationsView()
            }
            .sheet(isPresented: $showNewAppointment){
                BookingView()
            }
            .fullScreenCover(isPresented: $showClinicVideo){
                VideoPlayerView()
            }
            .sheet(item: $selectedAppointment) { appointment in
                AppointmentDetailView(appointment: appointment)
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
                        Button { showNotifications.toggle() } label: {
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
                        if showAppointmentBadge {
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
                        .opacity(greetingOpacity)
                        .scaleEffect(heroScale, anchor: .leading)
                    
                    Text("Dijital planlama · Minimal invaziv · Kişiye özel")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kySubtext)
                        .opacity(greetingOpacity)
                    
                    // CTA Row
                    HStack(spacing: 12) {
                        Button { showNewAppointment.toggle() } label: {
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
                .safeAreaPadding(.top)
            }
        }
    }
    
    
    private var appointmentCardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Yaklaşan Randevu", subtitle: "Takvimde görüntüle →"){
                navState.navigateToTab(.appointments)
            }
            
            if let appointment = fs.appointments.next{
                Button {
                    selectedAppointment = appointment
                } label: {
                    AppointmentCard(appointment: appointment)
                        .padding(.horizontal, 20)
                }
            }else{
                
            }
        }
        .padding(.top, 32)
    }
    
    // MARK: - Featured Services Horizontal Scroll
    
    private var featuredServicesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Öne Çıkan Tedaviler", subtitle: "Tümünü gör →"){
                navState.navigateToTab(.services)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(fs.services, id: \.self) { service in
                        Button {
                            navState.navigateToService(service: service)
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
                    makePhoneCall()
                }
                ContactButton(label: "WhatsApp",  icon: "message.fill",  isPrimary: false){
                    sendWhatsAppMessage()
                }
                ContactButton(label: "Harita",    icon: "map.fill",      isPrimary: false){
                    showMap.toggle()
                }
                .confirmationDialog(
                    "Choose a Map App",
                    isPresented: $showMap,
                    titleVisibility: .visible
                ) {
                    Button("Apple Maps") {
                        openInAppleMaps()
                    }
                    
                    // Google Maps yüklüyse göster
                    if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
                        Button("Google Maps") {
                            openInGoogleMaps()
                        }
                    }
                    
                    // Yandex Maps / Navi yüklüyse göster (Türkiye'de çok yaygın)
                    if UIApplication.shared.canOpenURL(URL(string: "yandexmaps://")!) ||
                        UIApplication.shared.canOpenURL(URL(string: "yandexnavi://")!) {
                        Button("Yandex Maps / Navi") {
                            openInYandex()
                        }
                    }
                    
                    // İsterseniz Waze de eklenebilir
                    if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
                        Button("Waze") {
                            openInWaze()
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
    
    func sendWhatsAppMessage() {
        // Mesajı URL için kodla (boşluklar, Türkçe karakterler)
        let escapedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?phone=\(phoneNumber)&text=\(escapedMessage)"
        
        if let whatsappURL = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL)
            } else {
                // WhatsApp yüklü değilse alternatif işlem (örneğin Safari ile açma)
                let webURLString = "https://wa.me/\(phoneNumber)?text=\(escapedMessage)"
                if let webURL = URL(string: webURLString) {
                    UIApplication.shared.open(webURL)
                }
            }
        }
    }
    
    private func openInAppleMaps() {
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destinationName
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            // isterseniz .Walking, .Transit vs.
        ])
    }
    
    // MARK: - Google Maps
    private func openInGoogleMaps() {
        let urlString = "comgooglemaps://?daddr=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&directionsmode=driving"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Yandex Maps / Navi
    private func openInYandex() {
        // Yandex Navi öncelikli (navigasyon odaklı)
        let naviURL = "yandexnavi://build_route_on_map?lat_to=\(destinationCoordinate.latitude)&lon_to=\(destinationCoordinate.longitude)"
        
        let mapsURL = "yandexmaps://maps.yandex.ru/?pt=\(destinationCoordinate.longitude),\(destinationCoordinate.latitude)&z=16&name=\(destinationName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // Navi yüklüyse Navi'yi tercih et, yoksa Maps
        if UIApplication.shared.canOpenURL(URL(string: "yandexnavi://")!) {
            if let url = URL(string: naviURL) {
                UIApplication.shared.open(url)
            }
        } else if let url = URL(string: mapsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Waze (opsiyonel)
    private func openInWaze() {
        let urlString = "waze://?ll=\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)&navigate=yes"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    func makePhoneCall() {
        if let url = URL(string: "tel://\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}


#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
