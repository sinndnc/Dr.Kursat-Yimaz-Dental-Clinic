//
//  TechRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//
import SwiftUI

struct TechRow: View {
    let item: TechItem
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.kyAccent.opacity(0.10))
                    .frame(width: 44, height: 44)
                Image(systemName: item.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.kyAccent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.kyText)
                    if let badge = item.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.3)
                            .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.85))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color(red: 0.55, green: 0.45, blue: 0.85).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                Text(item.description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.kySubtext)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(Color.kyAccent.opacity(item.badge == nil ? 0.8 : 0.25))
        }
        .padding(14)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
