//
//  DoctorListCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct DoctorListCard: View {
    let doctor: Doctor
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            HStack(spacing: 16) {
                ZStack(alignment: .bottomTrailing) {
                    Circle().fill(primaryBlue.opacity(0.1)).frame(width: 70)
                    Image(systemName: doctor.image).font(.system(size: 30)).foregroundColor(primaryBlue)
                    Circle().fill(doctor.isAvailable ? Color.green : Color.gray).frame(width: 14)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2)).offset(x: 4, y: 4)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(doctor.name).font(.system(size: 16, weight: .bold))
                    Text(doctor.specialty).font(.system(size: 13)).foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.yellow)
                            Text(String(format: "%.1f", doctor.rating)).font(.system(size: 13, weight: .semibold))
                            Text("(\(doctor.reviewCount))").font(.system(size: 12)).foregroundColor(.secondary)
                        }
                        Text("\(doctor.experience) yıl").font(.system(size: 12)).foregroundColor(.secondary)
                            .padding(.horizontal, 8).padding(.vertical, 3).background(Color.gray.opacity(0.1)).cornerRadius(8)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
            }
            .padding(18)
        }
    }
}
