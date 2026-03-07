//
//  QuickActionButton.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct QuickActionButton: View {
    let action: QuickAction
    @State private var pressed = false

    var body: some View {
        Button {} label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(action.color.opacity(0.14))
                        .frame(width: 50, height: 50)
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(action.color)
                }
                Text(action.title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.kySubtext)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
