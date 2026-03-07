//
//  AppointmentRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Date Badge
            VStack(spacing: 1) {
//                Text(appointment.)
//                    .font(.system(size: 9, weight: .bold, design: .monospaced))
//                    .tracking(1)
                Text(appointment.roomNumber)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(appointment.time)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
            }
            .frame(width: 52)
            .padding(.vertical, 12)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            // Info
            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.type.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                    .lineLimit(2)
                
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color.kySubtext)
                    Text(appointment.doctorName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 9))
                            .foregroundColor(Color.kySubtext.opacity(0.7))
                        Text(appointment.notes)
                            .font(.system(size: 11))
                            .foregroundColor(Color.kySubtext.opacity(0.7))
                    }
                    
                    // Status pill
                    HStack(spacing: 4) {
                        Text(appointment.status.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .clipShape(Capsule())
                }
            }
            
            Spacer(minLength: 0)
            
            // Chevron + icon
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(width: 34, height: 34)
                    Image(systemName: appointment.type.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(appointment.type.color)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext.opacity(0.5))
            }
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
