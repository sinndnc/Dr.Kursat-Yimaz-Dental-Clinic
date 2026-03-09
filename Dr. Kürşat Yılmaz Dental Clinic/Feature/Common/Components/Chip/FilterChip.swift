//
//  FilterChip.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/9/26.
//

import SwiftUI

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? Color.kyBackground : Color.kySubtext)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [Color.kyAccent, Color.kyAccentDark],
                                startPoint: .leading, endPoint: .trailing
                            )
                        } else {
                            LinearGradient(colors: [Color.kyCard, Color.kyCard],
                                           startPoint: .leading, endPoint: .trailing)
                        }
                    }
                )
                .clipShape(Capsule())
                .overlay( isSelected ? nil : Capsule().strokeBorder(Color.kyBorder, lineWidth: 1))
        }
        .buttonStyle(ScaleButtonStyle()) }
}
