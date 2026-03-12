//
//  DoctorCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct DoctorCard: View {
    let doctor: EnrichedDoctor
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: 14) {
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    doctor.accentColor.opacity(0.85),
                                    doctor.accentColor.opacity(0.40)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                    
                    if let photoURL = doctor.primaryPhotoURL {
                           AsyncImage(url: photoURL) { phase in
                               switch phase {
                               case .success(let image):
                                   image
                                       .resizable()
                                       .scaledToFill()
                                       .frame(width: 58, height: 58)
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
                               .font(.system(size: 20, weight: .bold, design: .rounded))
                               .foregroundColor(.white)
                       }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(doctor.name)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        Text(doctor.title)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Circle()
                            .fill(Color.kyBorder)
                            .frame(width: 3, height: 3)
                        
                        Text(doctor.specialty)
                            .font(.system(size: 10))
                            .foregroundColor(Color.kySubtext)
                    }
                    
                    // Languages
                    if !doctor.languages.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(doctor.languages.prefix(3), id: \.self) { lang in
                                Text(lang)
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(Color.kySubtext)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2.5)
                                    .background(Color.kySurface)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer()
            }
            
            Text(doctor.tagline)
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundColor(Color.kySubtext)
                .lineSpacing(4)
                .lineLimit(2)
                .padding(.top, 12)
            
            HStack(spacing: 0) {
                CardStat(value: doctor.experience,label: "Deneyim")
                CardStatDivider()
                CardStat(value: doctor.patientCount,label: "Hasta")
                CardStatDivider()
                CardStat(value: doctor.satisfactionRate, label: "Memnuniyet")
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .background(Color.kySurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
            .padding(.top, 14)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(doctor.expertise.prefix(5)) { exp in
                        HStack(spacing: 4) {
                            Image(systemName: exp.icon)
                                .font(.system(size: 8, weight: .bold))
                            Text(exp.title)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(exp.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(exp.color.opacity(0.10))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(exp.color.opacity(0.20), lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
            .padding(.top, 12)
            
            HStack(spacing: 5) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(Color.kySubtext)
                
                let allDays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt"]
                ForEach(allDays, id: \.self) { day in
                    let isAvailable = doctor.availableDays.contains(where: {
                        $0.lowercased().hasPrefix(day.lowercased().prefix(3))
                    })
                    Text(day)
                        .font(.system(size: 8.5, weight: isAvailable ? .bold : .medium))
                        .foregroundColor(isAvailable ? Color.white : Color.kySubtext.opacity(0.25))
                        .frame(width: 26)
                        .padding(.vertical, 4)
                        .background(
                            isAvailable ? Color.white.opacity(0.1): Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .strokeBorder(
                                    isAvailable
                                    ? Color.white.opacity(0.2)
                                    : Color.kyBorder.opacity(0.5),
                                    lineWidth: 0.5
                                )
                        )
                }
            }
            .padding(.top, 10)
        }
        .padding(16)
        .background(
            ZStack(alignment: .topTrailing) {
                Color.kyCard

                // Subtle accent glow top-right
                Circle()
                    .fill(doctor.accentColor.opacity(0.04))
                    .frame(width: 120, height: 120)
                    .offset(x: 30, y: -30)
                    .blur(radius: 30)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in isPressed = pressing },
            perform: {}
        )
    }
}

// MARK: - Subviews

private struct CardStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.kySubtext)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct CardStatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.kyBorder)
            .frame(width: 1, height: 28)
    }
}
