//
//  AlertModifier.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/13/26.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @ObservedObject private var manager = AlertManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if let alert = manager.current {
                AlertView(data: alert) {
                    manager.dismiss()
                }
                .zIndex(999)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: manager.current?.id)
    }
}
