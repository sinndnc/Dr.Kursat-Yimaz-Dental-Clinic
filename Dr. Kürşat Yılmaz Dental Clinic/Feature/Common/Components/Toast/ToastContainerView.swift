//
//  ToastContainerView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

public struct ToastContainerView: View {
    @ObservedObject private var manager = ToastManager.shared
 
    public init() {}
 
    public var body: some View {
        VStack(spacing: 8) {
            ForEach(manager.toasts) { toast in
                ToastItemView(toast: toast) {
                    manager.dismiss(toast)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.92)),
                        removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.88))
                    )
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: manager.toasts)
    }
}
 
