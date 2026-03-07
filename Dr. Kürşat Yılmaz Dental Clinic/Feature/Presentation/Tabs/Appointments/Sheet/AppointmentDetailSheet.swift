//
//  AppointmentDetailSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI
import EventKit

struct AppointmentDetailSheet: View {
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Hero
                    ZStack(alignment: .bottomLeading) {
                      
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .frame(width: 60, height: 60)
                                Image(systemName: appointment.type.icon)
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(appointment.type.color)
                            }
                            Text(appointment.type.rawValue.capitalized)
                                .font(.system(size: 24, weight: .bold, design: .serif))
                                .foregroundColor(Color.kyText)
                            Text(appointment.doctorSpecialty)
                                .font(.system(size: 13))
                                .foregroundColor(Color.kySubtext)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Status
                        HStack(spacing: 8) {
                            
                            Text(appointment.status.rawValue)
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .clipShape(Capsule())
                        
                        // Detail rows
                        VStack(spacing: 12) {
                            DetailRow(
                                icon: "calendar",
                                label: "Tarih",
                                value: appointment.date.description,
                                color: appointment.type.color
                            )
                            DetailRow(icon: "clock.fill",label: "Saat",value: appointment.time,color: appointment.type.color)
                            DetailRow(
                                icon: "timer",
                                label: "Süre",
                                value: appointment.notes,
                                color: appointment.type.color
                            )
                            DetailRow(icon: "person.fill",label: "Doktor",value: appointment.doctorName,color: appointment.type.color)
                            DetailRow(icon: "mappin.circle.fill", label: "Klinik", value: "KY Clinic · Etiler, Beşiktaş", color: appointment.type.color)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("NOT")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(Color.kySubtext)
                            Text(appointment.notes)
                                .font(.system(size: 14))
                                .foregroundColor(Color.kyText.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(14)
                        .background(Color.kyAccent.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.kyAccent.opacity(0.15), lineWidth: 1)
                        )
                        // Actions
                        if appointment.status == .upcoming {
                            VStack(spacing: 10) {
                                ActionButton(label: "Takvime Ekle",   icon: "calendar.badge.plus",  isPrimary: true,  color: appointment.type.color){
                                    requestCalendarAccess(appointment)
                                }
                                ActionButton(label: "Randevuyu İptal Et", icon: "xmark.circle",   isPrimary: false, color: Color(red: 0.85, green: 0.38, blue: 0.38)){
                                    
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            
            // Dismiss
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
    
    
    
    private func requestCalendarAccess(_ appointment: Appointment) {
        let eventStore = EKEventStore()
        
        eventStore.requestWriteOnlyAccessToEvents() { (granted, error) in
            if granted && error == nil {
                let calendarEvent = EKEvent(eventStore: eventStore)
                calendarEvent.title = appointment.type.rawValue
                calendarEvent.startDate = appointment.date
                calendarEvent.endDate = appointment.date.addingTimeInterval(3600)
                calendarEvent.notes = appointment.notes
                calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(calendarEvent, span: .thisEvent)
                   
                } catch {
                    
                }
            } else {
            }
        }
    }
}
