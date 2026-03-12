//
//  ProfileTextField.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/12/26.
//

import SwiftUI

struct ProfileTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.kyAccent.opacity(0.10))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.kyAccent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.kyMono(10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(.kySubtext)
                TextField(placeholder, text: $text)
                    .font(.kySans(15))
                    .foregroundColor(.kyText)
                    .tint(.kyAccent)
            }
        }
    }
}
