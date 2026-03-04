//
//  AppointmentCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//
import SwiftUI

struct AppointmentCard: View {
    let appointment: Appointment
    @EnvironmentObject var appState: AppState
    @State private var showDetail = false
    private let primaryBlue = Color(red: 0.15, green: 0.45, blue: 0.95)
    
    var body: some View {
        Button(action: { showDetail = true }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(appointment.type.color.opacity(0.12)).frame(width: 52, height: 52)
                        Image(systemName: appointment.type.icon).font(.system(size: 22)).foregroundColor(appointment.type.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appointment.doctorName).font(.system(size: 16, weight: .bold)).foregroundColor(.primary)
                        Text(appointment.type.rawValue).font(.system(size: 13)).foregroundColor(.secondary)
                        HStack(spacing: 12) {
                            Label(formatDate(appointment.date), systemImage: "calendar")
                            Label(appointment.time, systemImage: "clock")
                        }
                        .font(.system(size: 12, weight: .medium)).foregroundColor(primaryBlue).padding(.top, 2)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        statusBadge
                        Text(appointment.roomNumber)
                            .font(.system(size: 11, weight: .medium)).foregroundColor(.secondary)
                            .padding(.horizontal, 8).padding(.vertical, 4).background(Color.gray.opacity(0.1)).cornerRadius(8)
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) { AppointmentDetailView(appointment: appointment) }
    }
    
    var statusBadge: some View {
        let (color, text): (Color, String) = {
            switch appointment.status {
            case .upcoming:    return (.blue, "Yaklaşan")
            case .completed:   return (.green, "Tamamlandı")
            case .cancelled:   return (.red, "İptal")
            case .inProgress:  return (.orange, "Devam")
            }
        }()
        return Text(text)
            .font(.system(size: 10, weight: .bold)).foregroundColor(color)
            .padding(.horizontal, 10).padding(.vertical, 4).background(color.opacity(0.12)).cornerRadius(20)
    }
    
    func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "dd MMM yyyy"; f.locale = Locale(identifier: "tr_TR"); return f.string(from: date)
    }
}
