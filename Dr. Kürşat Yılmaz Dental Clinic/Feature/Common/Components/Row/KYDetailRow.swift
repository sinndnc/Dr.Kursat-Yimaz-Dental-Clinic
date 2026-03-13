//
//  KYDetailRow.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYDetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .kyText
    var iconColor: Color = .kySubtext

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.kySans(14))
                .foregroundColor(.kySubtext)
            Spacer()
            Text(value)
                .font(.kySans(14, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}
