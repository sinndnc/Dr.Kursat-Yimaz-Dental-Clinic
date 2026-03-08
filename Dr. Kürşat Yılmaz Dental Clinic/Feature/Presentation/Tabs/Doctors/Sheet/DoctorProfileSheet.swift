//
//  DoctorProfileSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

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
                                    .fill(Color.gray)
                                    .frame(width: 80, height: 80)
                                Text(doctor.avatarInitials)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
//                            .overlay(Circle().strokeBorder(doctor.color.opacity(0.4), lineWidth: 2.5))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doctor.name)
                                    .font(.system(size: 22, weight: .bold, design: .serif))
                                    .foregroundColor(Color.kyText)
                                Text(doctor.title)
                                    .font(.system(size: 12, weight: .semibold))
//                                    .foregroundColor(doctor.color)
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
//                            DoctorStat(value: doctor.experience,        label: "Deneyim",    color: doctor.color)
//                            Divider().frame(height: 36).background(Color.kyBorder)
//                            DoctorStat(value: doctor.patientCount,      label: "Hasta",      color: doctor.color)
//                            Divider().frame(height: 36).background(Color.kyBorder)
//                            DoctorStat(value: doctor.satisfactionRate,  label: "Memnuniyet", color: doctor.color)
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
//                                    EducationRow(edu: edu, accentColor: doctor.color, isLast: i == doctor.education.count - 1)
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
//                                        .foregroundColor(true ? doctor.color : Color.kySubtext.opacity(0.3))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color.kyBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
//                                                .strokeBorder(true ? doctor.color.opacity(0.2) : Color.kyBorder, lineWidth: 1)
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
                                    colors: [/*doctor.color, doctor.color.opacity(0.7)*/],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                            .shadow(color: doctor.color.opacity(0.3), radius: 12, x: 0, y: 5)
                        }
                        .buttonStyle(ScaleButtonStyle())
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
        .padding(.top)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}
