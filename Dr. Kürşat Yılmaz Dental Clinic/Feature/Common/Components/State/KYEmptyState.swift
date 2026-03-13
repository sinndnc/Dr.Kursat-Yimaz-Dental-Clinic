//
//  KYEmptyState.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct KYEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionLabel: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.kyAccent.opacity(0.08))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.kyAccent.opacity(0.6))
            }
            VStack(spacing: 6) {
                Text(title)
                    .font(.kySerif(17, weight: .bold))
                    .foregroundColor(.kyText)
                Text(message)
                    .font(.kySans(13))
                    .foregroundColor(.kySubtext)
                    .multilineTextAlignment(.center)
            }
            if let action, !actionLabel.isEmpty {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.kySans(14, weight: .semibold))
                        .foregroundColor(.kyBackground)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.kyAccent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(32)
    }
}
