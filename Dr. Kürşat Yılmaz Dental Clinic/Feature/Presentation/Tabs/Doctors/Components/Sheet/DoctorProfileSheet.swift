//
//  DoctorProfileSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//
import SwiftUI


struct DoctorProfileSheet: View {
    let doctor: EnrichedDoctor
    @Environment(\.dismiss) private var dismiss
    @State private var headerVisible = false
    @State private var showAppointment = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    ZStack(alignment: .bottomLeading) {
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        doctor.accentColor.opacity(0.18),
                                        Color.kyBackground
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 250)
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .fill(doctor.accentColor.opacity(0.08))
                                    .frame(width: 140, height: 140)
                                    .offset(x: 60, y: -40)
                                    .blur(radius: 40)
                            }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            HStack(alignment: .bottom, spacing: 18) {
                                
                                if let photoURL = doctor.primaryPhotoURL {
                                    AsyncImage(url: photoURL) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 86, height: 86)
                                                .clipShape(Circle())
                                        case .failure, .empty:
                                            // Yüklenemezse initials fallback
                                            Text(doctor.avatarInitials)
                                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                        @unknown default:
                                            ProgressView()
                                        }
                                    }
                                } else {
                                    Text(doctor.avatarInitials)
                                        .frame(width: 86, height: 86)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .background(doctor.accentColor)
                                        .clipShape(Circle())
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(doctor.name)
                                        .font(.system(size: 22, weight: .bold, design: .serif))
                                        .foregroundColor(Color.kyText)
                                    
                                    HStack(spacing: 6) {
                                        Text(doctor.title)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Circle()
                                            .fill(Color.kyBorder)
                                            .frame(width: 3, height: 3)
                                        
                                        Text(doctor.specialty)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.kySubtext)
                                    }
                                    
                                    HStack(spacing: 5) {
                                        ForEach(doctor.languages, id: \.self) { lang in
                                            Text(lang)
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(Color.kySubtext)
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 3)
                                                .background(Color.kyCard)
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule()
                                                        .strokeBorder(Color.kyBorder, lineWidth: 0.5)
                                                )
                                        }
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(.top,50)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        HStack(spacing: 0) {
                            ProfileStat(value: doctor.experience,label: "Deneyim")
                            Rectangle().fill(Color.kyBorder).frame(width: 1, height: 40)
                            ProfileStat(value: doctor.patientCount,     label: "Hasta")
                            Rectangle().fill(Color.kyBorder).frame(width: 1, height: 40)
                            ProfileStat(value: doctor.satisfactionRate, label: "Memnuniyet")
                        }
                        .padding(.vertical, 14)
                        .background(Color.kyCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.kyBorder, lineWidth: 1)
                        )
                        
                        ProfileSection(title: "HAKKINDA") {
                            Text(doctor.bio)
                                .font(.system(size: 13.5))
                                .foregroundColor(Color.kySubtext)
                                .lineSpacing(6)
                        }
                        
                        ProfileSection(title: "UZMANLIK ALANLARI") {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 8
                            ) {
                                ForEach(doctor.expertise) { exp in
                                    ExpertiseCell(exp: exp)
                                }
                            }
                        }
                        
                        // Education timeline
                        if !doctor.education.isEmpty {
                            ProfileSection(title: "EĞİTİM") {
                                VStack(spacing: 0) {
                                    ForEach(Array(doctor.education.enumerated()), id: \.element.id) { i, edu in
                                        EducationRow(edu: edu,isLast: i == doctor.education.count - 1)
                                    }
                                }
                            }
                        }
                        
                        // Available days
                        ProfileSection(title: "ÇALIŞMA GÜNLERİ") {
                            HStack(spacing: 6) {
                                ForEach(["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"], id: \.self) { day in
                                    let isAvailable = doctor.availableDays.contains(where: {
                                        $0.lowercased().hasPrefix(day.lowercased().prefix(3))
                                    })
                                    VStack(spacing: 4) {
                                        Text(day)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(isAvailable ? Color.white: Color.kySubtext.opacity(0.25))
                                        Circle()
                                            .fill(isAvailable ? Color.white : Color.clear)
                                            .frame(width: 4, height: 4)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(isAvailable ? Color.white.opacity(0.09) : Color.kyCard.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .strokeBorder(isAvailable ? Color.white.opacity(0.25): Color.kyBorder,lineWidth: 1))
                                }
                            }
                        }
                        
                        Button(action: { showAppointment.toggle() }) {
                            HStack(spacing: 10) {
                                Spacer()
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 15, weight: .bold))
                                Text("\(doctor.name.components(separatedBy: " ").last ?? "Doktor") ile Randevu Al")
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                            }
                            .foregroundColor(Color.kyBackground)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [doctor.accentColor, doctor.accentColor.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: doctor.accentColor.opacity(0.35), radius: 16, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.bottom, 52)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color.kyBorder, lineWidth: 1)
                        )
                }
                .padding(.trailing, 20)
                .padding(.top, 14)
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showAppointment){
            BookingView()
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}

// MARK: - Reusable section wrapper

private struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.kySubtext.opacity(0.6))
                .kerning(1.5)
            content()
        }
    }
}

// MARK: - Stat cell

private struct ProfileStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color.kySubtext)
        }
        .frame(maxWidth: .infinity)
    }
}


private struct ExpertiseCell: View {
    let exp: DoctorExpertise
    
    var body: some View {
        HStack(spacing: 9) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(exp.color.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: exp.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(exp.color)
            }
            Text(exp.title)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(Color.kyText)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Spacer()
        }
        .padding(10)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}

