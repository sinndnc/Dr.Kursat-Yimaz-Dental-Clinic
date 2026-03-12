//
//  ProfileCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct ProfileCard: View {
    let icon: String
    let title: String
    var subtitle: String?
    var badge: String? = nil
    var progress: Double? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.kyBlue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.kySans(15, weight: .semibold))
                        .foregroundColor(.kyText)
                    if let subtitle {
                        Text(subtitle)
                            .font(.kySans(12))
                            .foregroundColor(.kySubtext)
                            .lineLimit(1)
                    }
                    if let progress {
                        KYProgressBar(
                            progress: progress,
                            color: Color.kyBlue,
                            height: 4
                        ).padding(.top, 2)
                    }
                }
                
                Spacer()
                
                if let badge {
                    KYBadge(text: badge, color: Color.kyBlue)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.kySubtext.opacity(0.35))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
