//
//  AppointmentDetailSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI
import EventKit

struct AppointmentDetailView: View {
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @State private var calendarSuccess: Bool? = nil
    @State private var showCancelConfirm = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    heroSection
                    
                    VStack(alignment: .leading, spacing: 24) {
                        statusSection
                        detailsSection
                        if !appointment.notes.isEmpty {
                            notesSection
                        }
                        if appointment.status == .upcoming {
                            actionsSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 56)
                }
            }
            .ignoresSafeArea()
            
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.kySubtext)
                        .frame(width: 32, height: 32)
                        .background(Color.kySurface)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                }
                .padding(.trailing, 20)
            }
        }
        .confirmationDialog(
            "Randevuyu iptal etmek istediğinize emin misiniz?",
            isPresented: $showCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("İptal Et", role: .destructive) { /* cancel logic */ }
            Button("Vazgeç", role: .cancel) {}
        }
    }
    
    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            appointment.type.color.opacity(0.18),
                            appointment.type.color.opacity(0.04),
                            Color.kyBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            
            // Decorative circle
            Circle()
                .fill(appointment.type.color.opacity(0.07))
                .frame(width: 220, height: 200)
                .offset(x: 140, y: -60)
                .blur(radius: 2)
            
            VStack(alignment: .leading, spacing: 10) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [appointment.type.color.opacity(0.3), appointment.type.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(appointment.type.color.opacity(0.35), lineWidth: 1)
                        )
                    Image(systemName: appointment.type.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(appointment.type.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(appointment.type.rawValue)
                        .font(.system(size: 26, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)

                    Text(appointment.doctorSpecialty)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
    
    private var statusSection: some View {
        HStack(spacing: 10) {
            Image(systemName: appointment.status.icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(appointment.status.color)
            Text(appointment.status.rawValue)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(appointment.status.color)
            Spacer()
            Text(appointment.date.formatted(.dateTime.weekday(.wide)))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.kySubtext)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(appointment.status.color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(appointment.status.color.opacity(0.22), lineWidth: 1)
        )
    }
    
    private var detailsSection: some View {
        VStack(spacing: 1) {
            Group {
                DetailRow2(
                    icon: "calendar",
                    label: "Tarih",
                    value: appointment.date.formatted(.dateTime.day().month(.wide).year()),
                    accent: appointment.type.color,
                    isFirst: true
                )
                DetailRow2(
                    icon: "clock.fill",
                    label: "Saat",
                    value: appointment.time,
                    accent: appointment.type.color
                )
                DetailRow2(
                    icon: "timer",
                    label: "Süre",
                    value: "\(appointment.durationMinutes) dakika",
                    accent: appointment.type.color
                )
                DetailRow2(
                    icon: "person.fill",
                    label: "Doktor",
                    value: appointment.doctorName,
                    accent: appointment.type.color
                )
                if !appointment.roomNumber.isEmpty {
                    DetailRow2(
                        icon: "door.left.hand.open",
                        label: "Oda",
                        value: "No: \(appointment.roomNumber)",
                        accent: appointment.type.color
                    )
                }
                DetailRow2(
                    icon: "mappin.circle.fill",
                    label: "Klinik",
                    value: "KY Clinic · Etiler, Beşiktaş",
                    accent: appointment.type.color,
                    isLast: true
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("NOT", systemImage: "note.text")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(Color.kySubtext)

            Text(appointment.notes)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.kyText.opacity(0.8))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kyAccent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.14), lineWidth: 1)
        )
    }
    
    private var actionsSection: some View {
        VStack(spacing: 10) {
            // Calendar button
            Button {
                requestCalendarAccess(appointment)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: calendarSuccess == true ? "checkmark.circle.fill" : "calendar.badge.plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text(calendarSuccess == true ? "Takvime Eklendi" : "Takvime Ekle")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(calendarSuccess == true ? Color.kyGreen : Color.kyBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    Group {
                        if calendarSuccess == true {
                            Color.kyGreen.opacity(0.18)
                        } else {
                            LinearGradient(
                                colors: [Color.kyAccent, Color.kyAccentDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            // Cancel button
            Button {
                showCancelConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Randevuyu İptal Et")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(Color.kyDanger)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.kyDanger.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.kyDanger.opacity(0.25), lineWidth: 1)
                )
            }
        }
    }
    
    private func requestCalendarAccess(_ appointment: Appointment) {
        let eventStore = EKEventStore()
        eventStore.requestWriteOnlyAccessToEvents { granted, error in
            guard granted, error == nil else { return }
            let event = EKEvent(eventStore: eventStore)
            event.title = "\(appointment.type.rawValue) – Dr. \(appointment.doctorName)"
            event.startDate = appointment.date
            event.endDate = appointment.date.addingTimeInterval(TimeInterval(appointment.durationMinutes * 60))
            event.notes = appointment.notes
            event.calendar = eventStore.defaultCalendarForNewEvents
            try? eventStore.save(event, span: .thisEvent)
            DispatchQueue.main.async { calendarSuccess = true }
        }
    }
}

private struct DetailRow2: View {
    let icon: String
    let label: String
    let value: String
    let accent: Color
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext.opacity(0.6))
                    .tracking(0.5)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.kyText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.kyCard)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(Color.kyBorder)
                    .frame(height: 0.5)
                    .padding(.leading, 60)
            }
        }
    }
}
