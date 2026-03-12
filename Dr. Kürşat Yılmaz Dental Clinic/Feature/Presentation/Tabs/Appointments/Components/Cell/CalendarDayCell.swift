//
//  CalendarDayCell.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let hasAppointment: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.kyAccent, Color.kyAccentDark],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 30, height: 30)
                    } else if isToday {
                        Circle()
                            .strokeBorder(Color.kyAccent, lineWidth: 1.5)
                            .frame(width: 30, height: 30)
                    }
                    
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 13, weight: isToday || isSelected ? .bold : .regular))
                        .foregroundColor(
                            isSelected ? Color.kyBackground :
                            isToday    ? Color.kyAccent :
                                        Color.kyText
                        )
                }
                
                Circle()
                    .fill(hasAppointment ? Color.kyAccent : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(height: 30)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
