//
//  ProfileView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject private var vm: ProfileViewModel
    @EnvironmentObject private var apptvm: AppointmentViewModel
    @EnvironmentObject private var navState: ProfileNavigationState
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            ZStack {
                Color.kyBackground.ignoresSafeArea()
                
                Group{
                    if let patient = vm.patient{
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                headerSection(patient: patient)
                                nextAppointmentBanner
                                    .padding(.top, 14)
                                allSectionsStack(patient: patient)
                                    .padding(.top, 28)
                                footerNote(patient: patient)
                                    .padding(.top, 32)
                            }
                        }
                        .task {
                            await vm.loadPatientImage(id: patient.id!)
                        }
                        .ignoresSafeArea(edges: .top)
                    }else{
                        GuestProfileView()
                    }
                }
            }
            .onAppear { withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) { vm.appeared = true } }
            .navigationDestination(for: ProfileDestination.self) { route in
                destinationView(for: route)
            }
        }
        .environmentObject(vm)
    }
    
    @ViewBuilder
    func allSectionsStack(patient: Patient) -> some View{
        VStack(spacing: 24) {
            profileSectionBlock(title: "Genel") {
                ProfileCard(
                    icon: "person.circle.fill",
                    title: "Bilgilerim",
                    subtitle: "Ad, iletişim bilgileri",
                ) { navState.navigate(to: .editProfile) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "bell.badge.fill",
                    title: "Bildirimler",
                    subtitle: "Push, SMS, WhatsApp tercihleri",
                ) { navState.navigate(to: .notifications) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "star.circle.fill",
                    title: "Sadakat Puanları",
                    subtitle: "1250 puan",
                ) { navState.navigate(to: .loyaltyPoints) }
                
            }
            
            profileSectionBlock(title: "Sağlık") {
                
                ProfileCard(
                    icon: "calendar",
                    title: "Randevular",
                    subtitle: "\(vm.appointments.count) randevu · \(apptvm.upcoming.count) yaklaşan",
                    badge: apptvm.upcoming.isEmpty ? nil : "\(apptvm.upcoming.count)"
                ) { navState.navigate(to: .appointments) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "cross.case.fill",
                    title: "Tedaviler",
                    subtitle: "\(vm.treatments.count) tedavi",
                ) { navState.navigate(to: .treatments) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "heart.text.square.fill",
                    title: "Sağlık Özeti",
                    subtitle: "Kan grubu, cinsiyet, yaş",
                ) { navState.navigate(to: .healthInfo) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "folder.fill",
                    title: "Belgeler",
                    subtitle: "\(vm.documents.count) belge",
                ) { navState.navigate(to: .documents) }
                
            }
            
            profileSectionBlock(title: "Yardım & Gizlilik") {
                ProfileCard(
                    icon: "doc.text.fill",
                    title: "Gizlilik Politikası",
                    subtitle: "KVKK",
                ) { navState.navigate(to: .privacyPolicy) }
                
                KYDivider()
                
                ProfileCard(
                    icon: "questionmark.circle.fill",
                    title: "Yardım & Destek",
                    subtitle: nil,
                ) { navState.navigate(to: .helpSupport) }
                
                KYDivider()
                
                
                Button {
                    AlertManager.shared.confirmDestructive(
                        title: "Çıkış Yapmak İstediğinize Emin Misiniz?",
                        message: "Oturumunuz kapatılacak. Tekrar giriş yapmanız gerekecek.",
                        confirmLabel: "Evet, Çıkış Yap"
                    ) {
                        vm.signOut()
                    }
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.kyDanger.opacity(0.14))
                                .frame(width: 40, height: 40)
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16))
                                .foregroundColor(.kyDanger)
                        }
                        Text("Çıkış Yap")
                            .font(.kySans(15, weight: .semibold))
                            .foregroundColor(.kyDanger)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private func profileSectionBlock<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.kyMono(10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.kySubtext)
            }
            .padding(.horizontal, 4)
            
            // Kart
            VStack(spacing: 0) {
                content()
            }
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func headerSection(patient: Patient) -> some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.18), Color.clear],
                    center: UnitPoint(x: 0.5, y: 0.0),
                    startRadius: 10,
                    endRadius: 280
                )
                .ignoresSafeArea()
            }
            .frame(height: 280)
            
            VStack(spacing: 0) {
                // Top bar
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 5) {
                            Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                            Text("KY CLINIC")
                                .font(.kyMono(10, weight: .semibold))
                                .tracking(3)
                                .foregroundColor(.kyAccent)
                        }
                        Text("Profilim")
                            .font(.kySerif(28, weight: .bold))
                            .foregroundColor(.kyText)
                    }
                    Spacer()
                    
                    // Loyalty badge
                    Button {
                        navState.navigate(to: .loyaltyPoints)
                    } label: {
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.kyAccent)
                                Text("\(patient.loyaltyPoints)")
                                    .font(.kyMono(13, weight: .bold))
                                    .foregroundColor(.kyAccent)
                            }
                            Text("puan")
                                .font(.kyMono(9))
                                .foregroundColor(.kySubtext)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.kyAccent.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                
                // Avatar + info
                HStack(spacing: 18) {
                    // Avatar
                    Button {
                        navState.navigate(to: .editProfile)
                    } label: {
                        EditablePatientAvatar(patient: patient)
                    }
                    .scaleEffect(vm.appeared ? 1 : 0.85)
                    .opacity(vm.appeared ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.fullName)
                            .font(.kySerif(20, weight: .bold))
                            .foregroundColor(.kyText)
                        
                        HStack(spacing: 6) {
                            KYBadge(
                                text: patient.bloodType?.rawValue ?? "",
                                color: .kyBlue,
                                icon: "drop.degreesign.fill"
                            )
                            KYBadge(
                                text: "\(patient.age) yaş",
                                color: .kySubtext
                            )
                        }
                        
                        HStack(spacing: 5) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.kySubtext)
                            Text(patient.email ?? "")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.kySubtext)
                            Text(patient.phone ?? "")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
    
    @ViewBuilder
    private var nextAppointmentBanner: some View {
        if let next = apptvm.nextAppointment {
            Button {
                navState.navigate(to: .appointmentDetail(appointment: next))
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.kyGreen.opacity(0.15))
                            .frame(width: 50, height: 50)
                        Image(systemName: "clock.badge.checkmark.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.kyGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("YAKLAŞAN RANDEVU")
                            .font(.kyMono(10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(.kyGreen)
                        Text(next.type.rawValue)
                            .font(.kySerif(16, weight: .bold))
                            .foregroundColor(.kyText)
                        HStack(spacing: 8) {
                            Label(next.date.kyRelative, systemImage: "calendar")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                            Text("·")
                                .foregroundColor(.kySubtext.opacity(0.4))
                            Label(next.date.kyFormattedWithTime.components(separatedBy: ",").last?.trimmingCharacters(in: .whitespaces) ?? "", systemImage: "clock")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.kySubtext.opacity(0.4))
                }
                .padding(16)
                .background(Color.kyCard)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.kyGreen.opacity(0.2), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func footerNote(patient: Patient) -> some View {
        VStack(spacing: 6) {
            Text("KY Clinic v1.0.0")
                .font(.kyMono(11))
                .foregroundColor(.kySubtext.opacity(0.4))
            Text("© 2025 Dr. Kürşat Yılmaz Klinik")
                .font(.kyMono(11))
                .foregroundColor(.kySubtext.opacity(0.3))
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ProfileDestination) -> some View {
        switch route {
        case .appointments:
            AppointmentListView()
        case .treatments:
            TreatmentsView()
        case .healthInfo:
            HealthInfoDetailView(patient: vm.patient!)
        case .documents:
            DocumentsView()
        case .appointmentDetail(let appointment):
            AppointmentDetailView(appointment: appointment)
        case .treatmentDetail(let id):
            TreatmentDetailView(treatmentId: id)
        case .documentDetail(let id):
            DocumentDetailView(documentId: id)
        case .editProfile:
            EditProfileView(patient: vm.patient!)
        case .notifications:
            NotificationSettingsView()
        case .allergiesDetail:
            AllergiesDetailView(patient: vm.patient!)
        case .medicationsDetail:
            MedicationsDetailView(patient: vm.patient!)
        case .emergencyContacts:
            EmergencyContactsView(patient: vm.patient!)
        case .loyaltyPoints:
            LoyaltyPointsView(patient: vm.patient!)
        case .privacyPolicy:
            PrivacyPolicyView()
        case .helpSupport:
            HelpSupportView()
        }
    }
}
