//
//  ContactButton.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ContactButton: View {
    let label: String
    let icon: String
    let isPrimary: Bool
    var action: () -> Void = { }

    var body: some View {
        Button(action: action){
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(isPrimary ? Color.kyBackground : Color.kyText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isPrimary
                ? AnyView(LinearGradient(colors: [Color.kyAccent, Color.kyAccentDark], startPoint: .leading, endPoint: .trailing))
                : AnyView(Color.kyCard)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                isPrimary ? nil :
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
