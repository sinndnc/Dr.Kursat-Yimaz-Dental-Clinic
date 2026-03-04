//
//  DoctorDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct DoctorDetailView: View {
    let doctor: Doctor
    @State private var showAppointment = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle().fill(primaryBlue.opacity(0.1)).frame(width: 110)
                        Image(systemName: doctor.image).font(.system(size: 50)).foregroundColor(primaryBlue)
                        Circle().fill(doctor.isAvailable ? Color.green : Color.gray).frame(width: 20)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3)).offset(x: 6, y: 6)
                    }
                    VStack(spacing: 6) {
                        Text(doctor.name).font(.system(size: 24, weight: .bold, design: .rounded))
                        Text(doctor.specialty).font(.system(size: 16)).foregroundColor(.secondary)
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill").font(.system(size: 14)).foregroundColor(.yellow)
                            Text(String(format: "%.1f", doctor.rating)).font(.system(size: 16, weight: .bold))
                            Text("(\(doctor.reviewCount) değerlendirme)").font(.system(size: 14)).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 20)
                
                HStack(spacing: 0) {
                    statCard(value: "\(doctor.experience)+", label: "Yıl Deneyim")
                    Divider().frame(height: 50)
                    statCard(value: "\(doctor.reviewCount)", label: "Değerlendirme")
                    Divider().frame(height: 50)
                    statCard(value: doctor.isAvailable ? "Müsait" : "Meşgul", label: "Durum")
                }
                .padding(20).background(Color.white).cornerRadius(20)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3).padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hakkında").font(.system(size: 18, weight: .bold))
                    Text(doctor.bio).font(.system(size: 15)).foregroundColor(.secondary).lineSpacing(4)
                }
                .padding(20).background(Color.white).cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 3).padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Çalışma Günleri").font(.system(size: 18, weight: .bold))
                    HStack(spacing: 10) {
                        ForEach(["Pzt","Sal","Çar","Per","Cum"], id: \.self) { day in
                            let avail = doctor.availableDays.contains(day)
                            Text(day).font(.system(size: 13, weight: .semibold))
                                .foregroundColor(avail ? .white : .secondary)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(avail ? primaryBlue : Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(20).background(Color.white).cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 3).padding(.horizontal, 20)
                
                Button(action: { showAppointment = true }) {
                    Label("Randevu Al", systemImage: "calendar.badge.plus")
                        .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(doctor.isAvailable ? primaryBlue : Color.gray)
                        .cornerRadius(17)
                }
                .disabled(!doctor.isAvailable)
                .padding(.horizontal, 20).padding(.bottom, 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAppointment) { NewAppointmentView() }
    }
    
    func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded))
            Text(label).font(.system(size: 11)).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
