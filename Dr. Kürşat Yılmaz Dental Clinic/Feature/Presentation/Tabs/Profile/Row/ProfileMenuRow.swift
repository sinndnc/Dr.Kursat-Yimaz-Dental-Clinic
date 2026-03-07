//
//  ProfileMenuRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ProfileMenuRow: View {
    let item: ProfileMenuItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(item.isDestructive ? Color.kyDanger.opacity(0.12) : item.color.opacity(0.12))
                        .frame(width: 34, height: 34)
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(item.isDestructive ? Color.kyDanger : item.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(item.isDestructive ? Color.kyDanger : Color.kyText)
                    if let sub = item.subtitle {
                        Text(sub)
                            .font(.system(size: 11))
                            .foregroundColor(Color.kySubtext)
                    }
                }

                Spacer()

                if let trailing = item.trailingText {
                    Text(trailing)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.kySubtext)
                }

                if item.hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.kySubtext.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
