//
//  KYDetailHeader.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYDetailHeader: View {
    let title: String
    var subtitle: String? = nil
    var dismiss: (() -> Void)? = nil

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            HStack {
                Button {
                    if let dismiss { dismiss() }
                    else { presentationMode.wrappedValue.dismiss() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.kyCard)
                            .frame(width: 38, height: 38)
                            .overlay(Circle().strokeBorder(Color.kyBorder, lineWidth: 1))
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.kyText)
                    }
                }
                Spacer()
            }
            VStack(spacing: 2) {
                Text(title)
                    .font(.kySerif(17, weight: .bold))
                    .foregroundColor(.kyText)
                if let subtitle {
                    Text(subtitle)
                        .font(.kySans(12))
                        .foregroundColor(.kySubtext)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
