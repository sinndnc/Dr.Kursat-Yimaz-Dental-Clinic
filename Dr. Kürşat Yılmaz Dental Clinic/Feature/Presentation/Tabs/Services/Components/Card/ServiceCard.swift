//
//  ServiceCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ServiceCard: View {
    let service: Service
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(service.accentColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: service.sfSymbol)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(service.accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(service.title)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.kyText)

                    Text(service.subtitle)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(service.accentColor)

                    Text(service.description)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.kySubtext)
                        .lineSpacing(3)
                        .lineLimit(3)
                        .padding(.top, 2)

                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(service.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(0.3)
                                    .foregroundColor(service.accentColor.opacity(0.9))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(service.accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.kyBorder, lineWidth: 1)
            )
            // Badge
            if let badge = service.badgeText {
                Text(badge)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(service.accentColor)
                    .clipShape(Capsule())
                    .padding(.top, 14)
                    .padding(.trailing, 14)
            }
        }
    }
}
