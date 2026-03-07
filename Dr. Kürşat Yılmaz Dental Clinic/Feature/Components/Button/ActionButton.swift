//
//  ActionButton.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ActionButton: View {
    let label: String
    let icon: String
    let isPrimary: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            HStack(spacing: 8) {
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .bold))
                Spacer()
            }
            .foregroundColor(isPrimary ? Color.kyBackground : color)
            .padding(.vertical, 15)
            .background(
                isPrimary
                ? AnyView(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                : AnyView(color.opacity(0.08))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                isPrimary ? nil :
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(color.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
