//
//  AppointmentRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct AppointmentRow: View {
    let appointment: Appointment
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [appointment.type.color.opacity(0.25), appointment.type.color.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60)
                
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(appointment.type.color.opacity(0.18))
                            .frame(width: 34, height: 34)
                        Image(systemName: appointment.type.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(appointment.type.color)
                    }
                    
                    Text(appointment.roomNumber.isEmpty ? "–" : appointment.roomNumber)
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(appointment.type.color)
                    
                    Text(appointment.time)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color.kySubtext)
                }
            }
            .frame(width: 60)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(alignment: .center, spacing: 8) {
                    Text(appointment.type.rawValue)
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)
                        .lineLimit(1)
                    
                    Spacer(minLength: 4)
                    
                    StatusBadge(status: appointment.status)
                }
                
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.kySubtext.opacity(0.6))
                    Text(appointment.doctorName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                        .lineLimit(1)
                }
                
                if !appointment.notes.isEmpty {
                    Text(appointment.notes)
                        .font(.system(size: 11))
                        .foregroundColor(Color.kySubtext.opacity(0.55))
                        .lineLimit(1)
                }
                
                HStack(spacing: 6) {
                    Label(
                        appointment.date.formatted(.dateTime.day().month(.abbreviated).year()),
                        systemImage: "calendar"
                    )
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.kySubtext.opacity(0.7))

                    Spacer(minLength: 0)

                    HStack(spacing: 3) {
                        Image(systemName: "timer")
                            .font(.system(size: 9))
                        Text("\(appointment.durationMinutes) dk")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(appointment.type.color.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(appointment.type.color.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // ── Chevron ──────────────────────────────────────────────────
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.kySubtext.opacity(0.35))
                .padding(.trailing, 14)
        }
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.09), Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.982 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity,
            pressing: { pressing in isPressed = pressing },
            perform: {}
        )
    }
}


private struct StatusBadge: View {
    let status: AppointmentStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 5, height: 5)
            Text(status.rawValue)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(status.color.opacity(0.25), lineWidth: 0.5)
        )
        
    }
}


struct GuestAppointmentRow: View {
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.kySubtext.opacity(0.08))
                    .frame(width: 50, height: 50)
                Image(systemName: "clock.badge.questionmark.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.kySubtext.opacity(0.4))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("YAKLAŞAN RANDEVU")
                    .font(.kyMono(10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.kySubtext.opacity(0.4))
                Text("Randevunuz yok")
                    .font(.kySerif(16, weight: .bold))
                    .foregroundColor(.kySubtext.opacity(0.5))
                Text("Randevu almak için giriş yapın")
                    .font(.kySans(12))
                    .foregroundColor(.kySubtext.opacity(0.4))
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 13))
                .foregroundColor(.kySubtext.opacity(0.25))
        }
        .padding(16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
