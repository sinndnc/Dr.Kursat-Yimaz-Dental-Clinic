//
//  DoctorCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Top row
            HStack(spacing: 14) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.kyBackground)
                        .strokeBorder(.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 62, height: 62)
                    Text(doctor.avatarInitials)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(doctor.name)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                    HStack{
                        Text(doctor.title)
                            .font(.system(size: 11, weight: .semibold))
                        //                        .foregroundColor(doctor.color)
                        Text(doctor.specialty)
                            .font(.system(size: 12))
                            .foregroundColor(Color.kySubtext)
                    }
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
//                DoctorStat(value: doctor.experience,       label: "Deneyim",    color: doctor.color)
//                Divider().frame(height: 30).background(Color.kyBorder)
//                DoctorStat(value: doctor.patientCount,    label: "Hasta",       color: doctor.color)
//                Divider().frame(height: 30).background(Color.kyBorder)
//                DoctorStat(value: doctor.satisfactionRate, label: "Memnuniyet", color: doctor.color)
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
//                            .foregroundColor(true ? doctor.color : Color.kySubtext.opacity(0.3))
                            .frame(width: 28)
                            .padding(.vertical, 4)
//                            .background(true ? doctor.color.opacity(0.10) : Color.clear)
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
        .buttonStyle(ScaleButtonStyle())
    }
}
