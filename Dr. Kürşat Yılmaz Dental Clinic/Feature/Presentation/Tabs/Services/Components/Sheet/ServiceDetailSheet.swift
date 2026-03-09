//
//  ServiceDetailSheet.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct ServiceDetailSheet: View {
    let service: Service
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color.kyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero area
                    ZStack(alignment: .bottomLeading) {
                        // Gradient background
                        service.accentColor
                            .opacity(0.12)
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Color.kyBackground],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            // Icon large
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(service.accentColor.opacity(0.18))
                                    .frame(width: 68, height: 68)
                                Image(systemName: service.sfSymbol)
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(service.accentColor)
                            }

                            Text(service.category.rawValue.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(2.5)
                                .foregroundColor(service.accentColor)

                            Text(service.title)
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(Color.kyText)

                            Text(service.subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.kySubtext)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        // Description
                        Text(service.description)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color.kySubtext)
                            .lineSpacing(5)

                        Divider()
                            .background(Color.kyBorder)

                        // Details
                        ForEach(service.details) { detail in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(detail.heading)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                                    .foregroundColor(service.accentColor)

                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(detail.bullets, id: \.self) { bullet in
                                        HStack(alignment: .top, spacing: 10) {
                                            Circle()
                                                .fill(service.accentColor)
                                                .frame(width: 5, height: 5)
                                                .padding(.top, 6)
                                            Text(bullet)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundColor(Color.kyText.opacity(0.85))
                                                .lineSpacing(3)
                                        }
                                    }
                                }
                            }
                        }

                        // Tags
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Etiketler")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(Color.kySubtext)
                            FlowLayout(tags: service.tags, accentColor: service.accentColor)
                        }

                        // CTA Button
                        Button {
                            // Navigate to appointment
                        } label: {
                            HStack {
                                Spacer()
                                Text("Randevu Al")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.kyBackground)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.kyBackground)
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.kyAccent, Color(red: 0.75, green: 0.6, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }

            // Dismiss handle
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.kySubtext)
                            .padding(10)
                            .background(Color.kySurface)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.kyBackground)
    }
}
