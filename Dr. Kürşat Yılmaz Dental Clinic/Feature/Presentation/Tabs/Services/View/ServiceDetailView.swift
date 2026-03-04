//
//  ServiceDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct ServiceDetailView: View {
    let service: DentalService
    @Environment(\.dismiss) var dismiss
    @State private var showAppointment = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [service.color, service.color.opacity(0.6)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 16) {
                            ZStack {
                                Circle().fill(Color.white.opacity(0.2)).frame(width: 90)
                                Image(systemName: service.icon).font(.system(size: 40)).foregroundColor(.white)
                            }
                            Text(service.name).font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                            Text(service.description).font(.system(size: 15)).foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center).padding(.horizontal, 20)
                        }
                        .padding(.vertical, 36)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        infoCard(label: "Fiyat", value: service.price, icon: "turkishlirasign.circle.fill", color: .green)
                        infoCard(label: "Süre", value: service.duration, icon: "clock.fill", color: .orange)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nasıl Gerçekleşir?").font(.system(size: 18, weight: .bold))
                        ForEach(Array(["Muayene ve değerlendirme yapılır.", "Tedavi planı oluşturulur.", "İşlem uygulanır.", "Kontrol randevusu verilir."].enumerated()), id: \.offset) { idx, s in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(service.color.opacity(0.12)).frame(width: 32)
                                    Text("\(idx+1)").font(.system(size: 13, weight: .bold)).foregroundColor(service.color)
                                }
                                Text(s).font(.system(size: 14)).foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20).background(Color.white).cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 3).padding(.horizontal, 20)
                    
                    Button(action: { showAppointment = true }) {
                        Label("Randevu Al", systemImage: "calendar.badge.plus")
                            .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 17).background(service.color).cornerRadius(17)
                    }
                    .padding(.horizontal, 20).padding(.bottom, 30)
                }
                .padding(.top, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(service.name).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
        }
        .sheet(isPresented: $showAppointment) { NewAppointmentView() }
    }
    
    func infoCard(label: String, value: String, icon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(color: .black.opacity(0.06), radius: 10, y: 3)
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(color)
                Text(value).font(.system(size: 18, weight: .bold, design: .rounded))
                Text(label).font(.system(size: 12)).foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
    }
}
