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
                switch authVM.authState {
                case .loading :
                    ProgressView()
                default:
                    MainTabView()
                }
            }
        }
        .environmentObject(authVM)
//        .animation(.default, value: authVM.authState)
    }
}
