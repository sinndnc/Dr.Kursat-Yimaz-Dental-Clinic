//
//  GuestProfileView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/10/26.
//

import SwiftUI

struct GuestProfileView: View {
    
    @State private var appeared: Bool = false
    @Environment(AppNavigationState.self) private var appNav
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    guestHeaderSection
                    
                    GuestAppointmentRow()
                        .padding(.top, 14)
                        .padding(.horizontal)
                    
                    guestSectionsStack
                        .padding(.top, 28)
                    
                    footerNote
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .onAppear {
            withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }
    
    @ViewBuilder
    private var guestHeaderSection: some View {
        ZStack(alignment: .bottom) {
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
                    
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.kySubtext)
                            Text("— puan")
                                .font(.kyMono(13, weight: .bold))
                                .foregroundColor(.kySubtext.opacity(0.4))
                        }
                        Text("puan")
                            .font(.kyMono(9))
                            .foregroundColor(.kySubtext.opacity(0.3))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.kyCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.kyBorder, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                
                HStack(spacing: 18) {
                    
                    Button {
                        appNav.presentAuth()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.kyCard)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle().strokeBorder(
                                        Color.kyBorder, lineWidth: 2
                                    )
                                )
                            Image(systemName: "person.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.kySubtext.opacity(0.35))
                        }
                    }
                    .scaleEffect(appeared ? 1 : 0.85)
                    .opacity(appeared ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Giriş yapılmadı")
                                .font(.kySerif(18, weight: .bold))
                                .foregroundColor(.kyText)
                            Text("Tüm özellikler için hesabınıza giriş yapın.")
                                .font(.kySans(12))
                                .foregroundColor(.kySubtext)
                                .lineLimit(2)
                        }
                        
                        HStack(spacing: 8) {
                            Button {
                                appNav.presentAuth()
                            } label: {
                                Text("Giriş Yap")
                                    .font(.kySans(13, weight: .semibold))
                                    .foregroundColor(.kyBackground)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.kyAccent, Color.kyAccentDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(10)
                            }
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
    private var guestSectionsStack: some View {
        VStack(spacing: 24) {
            
            guestSectionBlock(title: "Genel", icon: "gearshape.fill") {
                GuestProfileCard(icon: "person.circle.fill", title: "Bilgilerim",       subtitle: "Ad, iletişim bilgileri",         iconColor: .kyAccent)
                KYDivider()
                GuestProfileCard(icon: "bell.badge.fill",    title: "Bildirimler",      subtitle: "Push, SMS, WhatsApp tercihleri", iconColor: .kyBlue)
                KYDivider()
                GuestProfileCard(icon: "creditcard.fill",    title: "Ödeme Geçmişi",    subtitle: "İşlem geçmişiniz burada görünür",iconColor: .kyBlue)
                KYDivider()
                GuestProfileCard(icon: "star.circle.fill",   title: "Sadakat Puanları", subtitle: "Puan kazanmaya başlayın",        iconColor: .kyAccent)
            }
            
            guestSectionBlock(title: "Sağlık", icon: "stethoscope") {
                GuestProfileCard(icon: "calendar",              title: "Randevular",   subtitle: "Randevularınızı görüntüleyin", iconColor: .kyBlue)
                KYDivider()
                GuestProfileCard(icon: "cross.case.fill",       title: "Tedaviler",    subtitle: "Tedavi geçmişiniz",            iconColor: .kyBlue)
                KYDivider()
                GuestProfileCard(icon: "heart.text.square.fill",title: "Sağlık Özeti", subtitle: "Kan grubu, cinsiyet, yaş",     iconColor: .kyDanger)
                KYDivider()
                GuestProfileCard(icon: "folder.fill",           title: "Belgeler",     subtitle: "Röntgen, rapor ve reçeteler",  iconColor: .kyAccent)
            }
            
            guestLoginCTACard
            
            guestSectionBlock(title: "Yardım & Gizlilik", icon: "hand.raised.fill") {
                ProfileCard(
                    icon: "doc.text.fill",
                    title: "Gizlilik Politikası",
                    subtitle: "KVKK"
                ) { /* privacyPolicy */ }
                
                KYDivider()
                
                ProfileCard(
                    icon: "questionmark.circle.fill",
                    title: "Yardım & Destek",
                    subtitle: nil
                ) { /* helpSupport */ }
            }
        }
    }
    
    @ViewBuilder
    private var guestLoginCTACard: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.kyAccent)
                Text("Tüm özelliklere erişin")
                    .font(.kySerif(18, weight: .semibold))
                    .foregroundColor(.kyText)
                Text("Randevu, tedavi geçmişi, belgeler ve\ndaha fazlası için giriş yapın.")
                    .font(.kySans(13))
                    .foregroundColor(.kySubtext)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 10) {
                Button {
                    appNav.presentAuth()
                } label: {
                    Text("Giriş Yap")
                        .font(.kySans(15, weight: .semibold))
                        .foregroundColor(.kyBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.kyAccent, Color.kyAccentDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(13)
                        .shadow(color: Color.kyAccent.opacity(0.3), radius: 12, y: 5)
                }
            }
        }
        .padding(20)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func guestSectionBlock<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.kyAccent)
                Text(title.uppercased())
                    .font(.kyMono(10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.kySubtext)
            }
            .padding(.horizontal, 4)
            
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
    private var footerNote: some View {
        VStack(spacing: 6) {
            Text("KY Clinic v1.0.0")
                .font(.kyMono(11))
                .foregroundColor(.kySubtext.opacity(0.4))
            Text("© 2025 Dr. Kürşat Yılmaz Klinik")
                .font(.kyMono(11))
                .foregroundColor(.kySubtext.opacity(0.3))
        }
    }
}

