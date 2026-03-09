//
//  FeaturedServicePill.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct FeaturedServicePill: View {
    let name: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .lineLimit(2)
                    .foregroundColor(Color.kyText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                HStack(spacing: 3) {
                    Text("Detaylar")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(color.opacity(0.85))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(color.opacity(0.85))
                }
            }
        }
        .padding(16)
        .frame(width: 140, alignment: .leading)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
