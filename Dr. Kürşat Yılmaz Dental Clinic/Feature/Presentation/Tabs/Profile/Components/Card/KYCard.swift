//
//  KYCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYCard<Content: View>: View {
    let content: () -> Content
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 18
    var glowColor: Color? = nil

    init(padding: CGFloat = 16, cornerRadius: CGFloat = 18, glowColor: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(Color.kyCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        glowColor != nil ? glowColor!.opacity(0.25) : Color.kyBorder,
                        lineWidth: 1
                    )
            )
    }
}
