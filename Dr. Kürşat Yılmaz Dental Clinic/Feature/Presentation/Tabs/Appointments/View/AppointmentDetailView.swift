//
//  AppointmentDetailView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct AppointmentDetailView: View {
    let appointment: Appointment
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var isCancelling = false
    @State private var showConfirmCancel = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [appointment.type.color, appointment.type.color.opacity(0.7)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 12) {
                            Image(systemName: appointment.type.icon).font(.system(size: 50)).foregroundColor(.white.opacity(0.9))
                            Text(appointment.type.rawValue).font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                            Text(appointment.doctorName).font(.system(size: 16)).foregroundColor(.white.opacity(0.85))
                        }
                        .padding(32)
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 1) {
                        detailRow(icon: "calendar",    label: "Tarih",    value: formatDate(appointment.date))
                        detailRow(icon: "clock",        label: "Saat",     value: appointment.time)
                        detailRow(icon: "door.left.hand.open", label: "Oda", value: appointment.roomNumber)
                        if !appointment.notes.isEmpty {
                            detailRow(icon: "note.text", label: "Not", value: appointment.notes)
                        }
                    }
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    if appointment.status == .upcoming {
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                Label("Hatırlatıcı Ekle", systemImage: "bell.fill")
                                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                                    .frame(maxWidth: .infinity).padding(.vertical, 16).background(primaryBlue).cornerRadius(16)
                            }
                            Button(action: { showConfirmCancel = true }) {
                                Group {
                                    if isCancelling { ProgressView().tint(.red) }
                                    else { Text("Randevuyu İptal Et").font(.system(size: 16, weight: .semibold)).foregroundColor(.red) }
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 16).background(Color.red.opacity(0.1)).cornerRadius(16)
                            }
                            .disabled(isCancelling)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20).padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Randevu Detayı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Kapat") { dismiss() } } }
            .alert("Randevuyu İptal Et", isPresented: $showConfirmCancel) {
                Button("İptal Et", role: .destructive) { cancelAppointment() }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Bu randevuyu iptal etmek istediğinizden emin misiniz?")
            }
        }
    }
    
    func cancelAppointment() {
        isCancelling = true
        Task {
            await appState.cancelAppointment(appointment)
            await MainActor.run { isCancelling = false; dismiss() }
        }
    }
    
    func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(primaryBlue).frame(width: 22)
            Text(label).font(.system(size: 15)).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.system(size: 15, weight: .semibold))
        }
        .padding(16).background(Color.white)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMMM yyyy, EEEE"; f.locale = Locale(identifier: "tr_TR"); return f.string(from: date)
    }
}
