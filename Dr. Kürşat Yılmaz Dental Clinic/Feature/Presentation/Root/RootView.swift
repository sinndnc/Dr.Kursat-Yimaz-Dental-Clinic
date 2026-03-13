//
//  RootView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var navState = AppNavigationState()
    @StateObject private var authVM: AuthViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            
            switch authVM.authState {
            case .loading:
                SplashView()
            case .authenticated, .unauthenticated, .registrationPending:
                MainTabView()
            }
        }
        .environment(navState)
        .environmentObject(authVM)
        .animation(.easeInOut(duration: 0.4), value: authVM.authState)
    }
}
