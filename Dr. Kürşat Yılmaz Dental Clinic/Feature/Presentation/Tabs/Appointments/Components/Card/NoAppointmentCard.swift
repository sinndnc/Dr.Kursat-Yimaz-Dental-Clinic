//
//  NoAppointmentCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import SwiftUI

struct NoAppointmentCard: View {
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Empty date badge
            VStack(spacing: 2) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(Color.kyAccent.opacity(0.4))
            }
            .frame(width: 58)
            .frame(maxHeight: .infinity)
            .padding(.vertical, 14)
            .background(Color.kyAccent.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Randevu Bulunamadı")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundColor(Color.kyText.opacity(0.5))
                Text("Henüz planlanmış bir randevunuz yok.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.kySubtext.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Button(action: action) {
                    VStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.kyAccent)
                    }
                    .frame(width: 30, height: 30)
                    .background(Color.kyAccent.opacity(0.1))
                    .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyAccent.opacity(0.08),lineWidth: 1)
        )
    }
}
