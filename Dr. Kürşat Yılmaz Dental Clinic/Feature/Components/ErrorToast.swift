//
//  ErrorToast.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct ErrorToast: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.white)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.9))
        .cornerRadius(14)
        .shadow(color: .red.opacity(0.3), radius: 10, y: 4)
        .padding(.horizontal, 20)
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 4) { onDismiss() } }
    }
}
