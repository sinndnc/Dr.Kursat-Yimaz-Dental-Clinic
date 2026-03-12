//
//  FlaeshBannerCompact.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct FlaeshBannerCompact: View {
    @State private var showSafari = false
    @State private var appeared = false
    
    var body: some View {
        Button { showSafari = true } label: {
            HStack(spacing: 16) {
                // Icon
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 52, height: 52)
                    .overlay(Text("🦷").font(.system(size: 26)))
 
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text("Beyaz gülüşünü gör")
                        .font(.system(size: 17, weight: .light, design: .serif))
                        .foregroundStyle(.white)
                    Text("AI ile saniyeler içinde · Ücretsiz")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.white.opacity(0.35))
                }
 
                Spacer()
 
                // Arrow
                Circle()
                    .fill(.white.opacity(0.07))
                    .overlay(
                        Circle().strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(red: 0.07, green: 0.1, blue: 0.13))
                    // right glow
                    Ellipse()
                        .fill(RadialGradient(
                            colors: [Color.white.opacity(0.08), .clear],
                            center: .center, startRadius: 0, endRadius: 100
                        ))
                        .frame(width: 200, height: 120)
                        .offset(x: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .fullScreenCover(isPresented: $showSafari) {
            SafariView(url: flaeshURL).ignoresSafeArea()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }
}
 
