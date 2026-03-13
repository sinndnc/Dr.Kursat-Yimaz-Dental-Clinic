//
//  KYNavigationRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYNavigationRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconBg: Color = .kyAccent
    var badge: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconBg.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconBg)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.kySans(15, weight: .semibold))
                        .foregroundColor(.kyText)
                    if let subtitle {
                        Text(subtitle)
                            .font(.kySans(12))
                            .foregroundColor(.kySubtext)
                    }
                }

                Spacer()

                if let badge {
                    KYBadge(text: badge, color: .kyDanger)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.kySubtext.opacity(0.4))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
        }
        .buttonStyle(.plain)
    }
}
