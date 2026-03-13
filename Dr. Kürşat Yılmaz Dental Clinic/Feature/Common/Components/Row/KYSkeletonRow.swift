//
//  KYSkeletonRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYSkeletonRow: View {
    @State private var phase: CGFloat = 0

    private var shimmer: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color.kyCard,         location: phase - 0.3),
                .init(color: Color.kyCardElevated,  location: phase),
                .init(color: Color.kyCard,          location: phase + 0.3),
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().frame(width: 7, height: 7).padding(.top, 7)
            RoundedRectangle(cornerRadius: 12).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4).frame(height: 12)
                RoundedRectangle(cornerRadius: 4).frame(height: 11).padding(.trailing, 60)
                RoundedRectangle(cornerRadius: 4).frame(height: 11).padding(.trailing, 110)
            }
        }
        .padding(12).foregroundStyle(shimmer)
        .background(
            RoundedRectangle(cornerRadius: 16).fill(Color.kyCard)
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.kyBorderSubtle, lineWidth: 1))
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { phase = 1.6 }
        }
    }
}
