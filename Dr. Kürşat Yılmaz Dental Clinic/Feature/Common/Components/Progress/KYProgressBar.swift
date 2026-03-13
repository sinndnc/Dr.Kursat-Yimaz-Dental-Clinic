//
//  KYProgressBar.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYProgressBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 6
    var showLabel: Bool = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(.kyMono(10, weight: .semibold))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.kySurface)
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * min(1.0, progress)))
                }
            }
            .frame(height: height)
        }
    }
}
