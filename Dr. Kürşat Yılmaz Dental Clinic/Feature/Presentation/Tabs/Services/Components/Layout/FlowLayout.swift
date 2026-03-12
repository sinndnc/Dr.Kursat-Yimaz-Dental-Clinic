//
//  FlowLayout.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/7/26.
//

import SwiftUI

struct FlowLayout: View {
    let tags: [String]
    let accentColor: Color
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(tags, id: \.self) { tag in
                    tagView(tag)
                        .alignmentGuide(.leading) { d in
                            if abs(width - d.width) > geo.size.width {
                                width = 0
                                height -= d.height + 8
                            }
                            let result = width
                            if tag == tags.last {
                                width = 0
                            } else {
                                width -= d.width + 8
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if tag == tags.last { height = 0 }
                            return result
                        }
                }
            }
        }
        .frame(height: CGFloat(((tags.count - 1) / 3 + 1)) * 34)
    }

    @ViewBuilder
    private func tagView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(accentColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(accentColor.opacity(0.1))
            .clipShape(Capsule())
    }
}
