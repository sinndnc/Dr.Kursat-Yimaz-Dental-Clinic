//
//  DoctorExpertise.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct DoctorsView: View {
    @State private var selectedDoctor: Doctor? = nil
    @State private var headerAppeared = false
    
    var body: some View {
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
            .buttonStyle(DScaleButtonStyle())
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Doctor Card

struct DoctorCard: View {
    let doctor: Doctor

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top row
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .frame(width: 62, height: 62)
                    Text(doctor.avatarInitials)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .strokeBorder(doctor.color.opacity(0.3), lineWidth: 2)
                )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(doctor.name)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                    Text(doctor.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(doctor.color)
                    Text(doctor.specialty)
                        .font(.system(size: 12))
                        .foregroundColor(Color.kySubtext)
                }
                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.kySubtext.opacity(0.4))
            }

            // Tagline
            Text("\(doctor.tagline)")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundColor(Color.kySubtext)
                .lineSpacing(3)
                .padding(.top, 12)

            // Divider
            Rectangle()
                .fill(Color.kyBorder)
                .frame(height: 1)
                .padding(.vertical, 14)

            // Stats
            HStack(spacing: 0) {
                DoctorStat(value: doctor.experience,       label: "Deneyim",    color: doctor.color)
                Divider().frame(height: 30).background(Color.kyBorder)
                DoctorStat(value: doctor.patientCount,    label: "Hasta",       color: doctor.color)
                Divider().frame(height: 30).background(Color.kyBorder)
                DoctorStat(value: doctor.satisfactionRate, label: "Memnuniyet", color: doctor.color)
            }

            // Expertise pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(doctor.expertise.prefix(4)) { exp in
                        HStack(spacing: 4) {
                            Image(systemName: exp.icon)
                                .font(.system(size: 9, weight: .semibold))
                            Text(exp.title)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(exp.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(exp.color.opacity(0.10))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.top, 12)
            
            // Available days
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(Color.kySubtext)
                HStack(spacing: 4) {
                    let days: [String] = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"]
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(true ? doctor.color : Color.kySubtext.opacity(0.3))
                            .frame(width: 28)
                            .padding(.vertical, 4)
                            .background(true ? doctor.color.opacity(0.10) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    }
                }
            }
            .padding(.top, 10)
        }
        .padding(18)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
        .buttonStyle(DScaleButtonStyle())
    }
}

// MARK: - Doctor Stat

struct DoctorStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(Color.kyText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.kySubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Credential Pill

struct CredentialPill: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
            Text(name)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.kyText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Doctor Profile Sheet

struct DoctorProfileSheet: View {
    let doctor: Doctor
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Hero
                    ZStack(alignment: .bottomLeading) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                Text(doctor.avatarInitials)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .overlay(Circle().strokeBorder(doctor.color.opacity(0.4), lineWidth: 2.5))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(doctor.name)
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                    .foregroundColor(Color.kyText)
                                Text(doctor.title)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(doctor.color)
                                Text(doctor.specialty)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.kySubtext)
                                HStack(spacing: 5) {
                                    ForEach(doctor.languages, id: \.self) { lang in
                                        Text(lang)
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(Color.kySubtext)
                                            .padding(.horizontal, 7)
                                            .padding(.vertical, 3)
                                            .background(Color.kySurface)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }

                    VStack(alignment: .leading, spacing: 24) {

                        // Stats row
                        HStack(spacing: 0) {
                            DoctorStat(value: doctor.experience,        label: "Deneyim",    color: doctor.color)
                            Divider().frame(height: 36).background(Color.kyBorder)
                            DoctorStat(value: doctor.patientCount,      label: "Hasta",      color: doctor.color)
                            Divider().frame(height: 36).background(Color.kyBorder)
                            DoctorStat(value: doctor.satisfactionRate,  label: "Memnuniyet", color: doctor.color)
                        }
                        .padding(16)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.kyBorder, lineWidth: 1))

                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            ProfileSectionTitle(text: "HAKKINDA")
                            Text(doctor.bio)
                                .font(.system(size: 14))
                                .foregroundColor(Color.kySubtext)
                                .lineSpacing(5)
                        }

                        // Expertise
                        VStack(alignment: .leading, spacing: 12) {
                            ProfileSectionTitle(text: "UZMANLIK ALANLARI")
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(doctor.expertise) { exp in
                                    HStack(spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(exp.color.opacity(0.12))
                                                .frame(width: 30, height: 30)
                                            Image(systemName: exp.icon)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(exp.color)
                                        }
                                        Text(exp.title)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color.kyText)
                                            .lineLimit(2)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(Color.kyCard)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.kyBorder, lineWidth: 1))
                                }
                            }
                        }

                        // Education
                        VStack(alignment: .leading, spacing: 12) {
                            ProfileSectionTitle(text: "EĞİTİM")
                            VStack(spacing: 0) {
                                ForEach(Array(doctor.education.enumerated()), id: \.element.id) { i, edu in
                                    EducationRow(edu: edu, accentColor: doctor.color, isLast: i == doctor.education.count - 1)
                                }
                            }
                        }
                        
                        // Available days
                        VStack(alignment: .leading, spacing: 10) {
                            ProfileSectionTitle(text: "ÇALIŞMA GÜNLERİ")
                            HStack(spacing: 8) {
                                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"], id: \.self) { day in
                                    Text(day)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(true ? doctor.color : Color.kySubtext.opacity(0.3))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(true ? doctor.color.opacity(0.10) : Color.kyCard)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .strokeBorder(true ? doctor.color.opacity(0.2) : Color.kyBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }

                        // CTA
                        Button {} label: {
                            HStack(spacing: 8) {
                                Spacer()
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("\(doctor.name.components(separatedBy: " ").last ?? "Doktor") ile Randevu Al")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                            }
                            .foregroundColor(Color.kyBackground)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [doctor.color, doctor.color.opacity(0.7)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: doctor.color.opacity(0.3), radius: 12, x: 0, y: 5)
                        }
                        .buttonStyle(DScaleButtonStyle())
                        .padding(.bottom, 48)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }

            // Dismiss button
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
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Education Row

struct EducationRow: View {
    let edu: DoctorEducation
    let accentColor: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle()
                        .fill(Color.kyBorder)
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .padding(.top, 4)
                }
            }
            .frame(width: 8)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(edu.degree)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.kyText)
                    Spacer()
                    Text(edu.year)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(accentColor)
                }
                Text(edu.institution)
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }
}

// MARK: - Profile Section Title

struct ProfileSectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .tracking(2.5)
            .foregroundColor(Color.kySubtext)
    }
}

// MARK: - Scale Button Style (local)

private struct DScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    DoctorsView()
        .preferredColorScheme(.dark)
}
