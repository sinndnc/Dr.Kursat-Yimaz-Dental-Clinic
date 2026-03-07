//
//  TestimonialCard.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct TestimonialCard: View {
    let testimonial: Testimonial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Stars
            HStack(spacing: 3) {
                ForEach(0..<testimonial.rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.kyAccent)
                }
            }
            Text("\(testimonial.text)")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundColor(Color.kyText.opacity(0.9))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            // Footer
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(testimonial.avatarColor.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Text(testimonial.initials)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(testimonial.avatarColor)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(testimonial.name)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.kyText)
                    Text(testimonial.treatment)
                        .font(.system(size: 10))
                        .foregroundColor(Color.kySubtext)
                }
            }
        }
        .padding(18)
        .frame(width: 240, alignment: .leading)
        .background(Color.kyCard)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.kyBorder, lineWidth: 1)
        )
    }
}
