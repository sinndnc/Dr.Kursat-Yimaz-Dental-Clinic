//
//  KySecureField.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KySecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.kySans(12, weight: .medium))
                .foregroundColor(isFocused ? .kyAccent : .kySubtext)
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .font(.system(size: 15))
                    .foregroundColor(isFocused ? .kyAccent : .kySubtext)
                    .frame(width: 20)
                
                Group {
                    if showPassword {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.kySans(15))
                .foregroundColor(.kyText)
                .tint(.kyAccent)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showPassword.toggle()
                    }
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundColor(.kySubtext)
                }
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
