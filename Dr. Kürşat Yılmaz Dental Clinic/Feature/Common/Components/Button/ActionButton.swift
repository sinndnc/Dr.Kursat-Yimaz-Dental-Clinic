//
//  ActionButton.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var style: ButtonStyle2 = .filled
    let action: () -> Void

    enum ButtonStyle2 {
        case filled, outlined
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.kySans(15, weight: .semibold))
            }
            .foregroundColor(style == .filled ? .kyBackground : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style == .filled ? color : color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(style == .outlined ? color.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
