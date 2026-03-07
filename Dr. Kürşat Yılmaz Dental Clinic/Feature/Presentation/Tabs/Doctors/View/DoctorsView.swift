//
//  DoctorExpertise.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct DoctorsView: View {
    
    @EnvironmentObject private var navState: AppNavigationState
    
    @State private var selectedDoctor: Doctor? = nil
    @State private var headerAppeared = false
    
    var body: some View {
        NavigationStack(path: $navState.doctorsNavPath){
            ZStack {
                Color.kyBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        teamIntroSection
                            .padding(.top, 28)
                        doctorCardsSection
                            .padding(.top, 24)
                        credentialsStrip
                            .padding(.top, 32)
                        bottomCTA
                            .padding(.top, 32)
                            .padding(.bottom, 100)
                    }
                }
                .ignoresSafeArea()
            }
            .sheet(item: $selectedDoctor) { doc in
                DoctorProfileSheet(doctor: doc)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) { headerAppeared = true }
            }
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Color.kyBackground
                RadialGradient(
                    colors: [Color.kyAccent.opacity(0.14), Color.clear],
                    center: UnitPoint(x: 0.9, y: 0.1),
                    startRadius: 0, endRadius: 180
                )
            }
            .ignoresSafeArea()
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Circle().fill(Color.kyAccent).frame(width: 5, height: 5)
                    Text("KY CLINIC")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(3).foregroundColor(Color.kyAccent)
                }
                Text("Ekibimiz")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .opacity(headerAppeared ? 1 : 0)
                    .offset(y: headerAppeared ? 0 : 10)
                Text("Uzman kadromuzla tanışın")
                    .font(.system(size: 14)).foregroundColor(Color.kySubtext)
            }
            .padding(.top, 25)
            .padding(.horizontal)
        }
    }
    
    private var teamIntroSection: some View {
        HStack() {
            // Overlapping avatars
            ZStack(alignment: .leading) {
                ForEach(Array(Doctor.all.prefix(3).enumerated()), id: \.element.id) { i, doc in
                    Circle()
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(doc.avatarInitials)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .overlay(Circle().strokeBorder(Color.kyBackground, lineWidth: 2.5))
                        .offset(x: CGFloat(i) * 28)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("3 Uzman Hekim")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text("Dijital diş hekimliğinde öncü ekip")
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
            }
            
            Spacer()
            
            Text("Etiler, İstanbul")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.kySubtext.opacity(0.6))
        }
        .padding(16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    // MARK: Doctor Cards

    private var doctorCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(Doctor.all) { doc in
                DoctorCard(doctor: doc)
                    .onTapGesture { selectedDoctor = doc }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: Credentials Strip

    private var credentialsStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Akreditasyonlar")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Spacer()
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach([
                        ("Straumann", "bolt.shield.fill",         Color(red: 0.3,  green: 0.6,  blue: 0.9)),
                        ("EMS",       "wind",                     Color(red: 0.25, green: 0.7,  blue: 0.85)),
                        ("DSD",       "sparkles",                 Color.kyAccent),
                        ("E.max",     "seal.fill",                Color.kyAccent),
                        ("Invisalign","mouth.fill",               Color(red: 0.55, green: 0.45, blue: 0.85)),
                    ], id: \.0) { name, icon, color in
                        CredentialPill(name: name, icon: icon, color: color)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: Bottom CTA

    private var bottomCTA: some View {
        VStack(spacing: 14) {
            Text("Hangi hekim size uygun?")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
                .multilineTextAlignment(.center)
            Text("Ücretsiz konsültasyon için hemen ulaşın.")
                .font(.system(size: 14))
                .foregroundColor(Color.kySubtext)

            Button {} label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Konsültasyon Randevusu")
                        .font(.system(size: 15, weight: .bold))
                    Spacer()
                }
                .foregroundColor(Color.kyBackground)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.kyAccent, Color.kyAccentDark],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.kyAccent.opacity(0.3), radius: 12, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}

struct ProfileSectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(2.5)
            .foregroundColor(Color.kySubtext)
    }
}

// MARK: - Preview

#Preview {
    DoctorsView()
        .preferredColorScheme(.dark)
}
