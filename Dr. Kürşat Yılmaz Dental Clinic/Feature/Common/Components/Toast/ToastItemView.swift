//
//  ToastItemView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI
import Foundation

struct ToastItemView: View {
    let toast: ToastData
    let onDismiss: () -> Void
    
    @State private var progress: CGFloat = 1.0
    @State private var isSpinning = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(toast.type.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                if case .loading = toast.type {
                    Image(systemName: toast.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(toast.type.color)
                        .rotationEffect(.degrees(isSpinning ? 360 : 0))
                        .animation(
                            .linear(duration: 1).repeatForever(autoreverses: false),
                            value: isSpinning
                        )
                        .onAppear { isSpinning = true }
                } else {
                    Image(systemName: toast.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(toast.type.color)
                }
            }
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let message = toast.message {
                    Text(message)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer(minLength: 0)
            
            // Action or Dismiss
            if let action = toast.action {
                Button(action.label) {
                    action.handler()
                    onDismiss()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(toast.type.color)
                .buttonStyle(.plain)
            } else {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color(.systemGray5), in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(toast.type.color.opacity(0.25), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
                .shadow(color: toast.type.color.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        // Progress bar
        .overlay(alignment: .bottom) {
            if toast.duration > 0 {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(toast.type.color.opacity(0.5))
                        .frame(width: geo.size.width * progress, height: 2)
                        .animation(.linear(duration: toast.duration), value: progress)
                }
                .frame(height: 2)
                .padding(.horizontal, 14)
                .padding(.bottom, 2)
                .onAppear {
                    progress = 0
                }
            }
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    let y = value.translation.height
                    // Resistive drag
                    dragOffset = y < 0 ? y : sqrt(abs(y)) * 2
                }
                .onEnded { value in
                    if value.translation.height < -40 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}
