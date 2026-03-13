//
//  KyTextField.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KyTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.kySans(12, weight: .medium))
                .foregroundColor(isFocused ? .kyAccent : .kySubtext)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(isFocused ? .kyAccent : .kySubtext)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.kySans(15))
                    .foregroundColor(.kyText)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .tint(.kyAccent)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(Color.kyCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isFocused ? Color.kyAccent.opacity(0.5) : Color.kyBorder,
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}
