//
//  RootView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var authVM: AuthViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            Color.kyBackground.ignoresSafeArea()
            Group {
                if authVM.isLoading {
                    SplashView()
                }else{
                    MainTabView()
                }
            }
            .environmentObject(authVM)
            .animation(.easeInOut(duration: 0.4), value: authVM.isLoading)
        }
    }
}
