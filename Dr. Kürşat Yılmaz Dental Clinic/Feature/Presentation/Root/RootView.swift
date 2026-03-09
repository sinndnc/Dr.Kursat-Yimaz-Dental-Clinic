//
//  RootView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI
struct RootView: View {
    
    @EnvironmentObject private var navState: AppNavigationState
    
    @StateObject private var authVM: AuthViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            Group {
                switch authVM.authState {
                case .loading:
                    ProgressView()
                case .unauthenticated:
                    LoginView(showLogin: .constant(true))
                case .registrationPending:
                    Text("Registration Pending")
                case .authenticated:
                    MainTabView()
                       
                }
            }
        }
        .environmentObject(authVM)
        .animation(.easeInOut(duration: 0.3), value: authVM.authState)
    }
}
