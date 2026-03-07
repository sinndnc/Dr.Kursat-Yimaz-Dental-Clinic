//
//  AppointmentCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        HStack(spacing: 16) {
            // Date badge
            VStack(spacing: 2) {
                Text("MAR")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(Color.kyAccent)
                Text("12")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                Text(appointment.time)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
            }
            .frame(width: 58)
            .padding(.vertical, 14)
            .background(Color.kyAccent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(appointment.type.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText)
                HStack(spacing: 5) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kySubtext)
                    Text(appointment.doctorName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kyAccent.opacity(0.7))
                    Text("KY Clinic · Etiler")
                        .font(.system(size: 11))
                        .foregroundColor(Color.kySubtext.opacity(0.7))
                }
            }

            Spacer()

            VStack(spacing: 8) {
                // Status dot
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0.4, green: 0.78, blue: 0.5))
                        .frame(width: 6, height: 6)
                    Text("Onaylı")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(red: 0.4, green: 0.78, blue: 0.5))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.4, green: 0.78, blue: 0.5).opacity(0.1))
                .clipShape(Capsule())

                Button {} label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.kySubtext)
                }
            }
        }
        .padding(16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.15), lineWidth: 1)
        )
    }
}
