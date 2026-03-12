//
//  GuestLockedNavItem.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct GuestProfileCard: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconColor: Color = .kyAccent
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.07))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.kySans(15, weight: .semibold))
                    .foregroundColor(.kyText.opacity(0.35))
                if let subtitle {
                    Text(subtitle)
                        .font(.kySans(12))
                        .foregroundColor(.kySubtext.opacity(0.3))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.system(size: 11))
                .foregroundColor(.kySubtext.opacity(0.2))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}
