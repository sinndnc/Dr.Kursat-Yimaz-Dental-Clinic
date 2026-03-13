//
//  KYFilterChip.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYFilterChip: View {
    let label: String; let icon: String; let color: Color
    let isSelected: Bool; let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 11, weight: .semibold))
                Text(label).font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(isSelected ? Color.kyBackground : Color.kySubtext)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(Capsule().fill(isSelected ? color : Color.kyCard))
            .overlay(Capsule().strokeBorder(isSelected ? Color.clear : Color.kyBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22), value: isSelected)
    }
}
