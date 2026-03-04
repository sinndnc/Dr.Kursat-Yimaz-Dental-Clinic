//
//  RootView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    
    @State private var isCheckingUser = true
    
    var body: some View {
        Group {
            if authService.isLoggedIn {
                MainTabView()
            }else{
                if isCheckingUser {
                    ProgressView()
                } else {
                    AuthView()
                }
            }
        }
        .task{
            await appState.handleAuthChange()
            isCheckingUser = false
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isLoggedIn)
        .overlay(alignment: .top) {
            if let error = appState.globalError {
                ErrorToast(message: error) { appState.globalError = nil }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: appState.globalError)
            }
        }
    }
}
