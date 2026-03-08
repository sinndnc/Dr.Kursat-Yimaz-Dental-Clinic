//
//  RootView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/5/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject private var auth: AuthService
    
    @EnvironmentObject private var fs: FirestoreService
    @EnvironmentObject private var currentUser: CurrentUser
    @EnvironmentObject private var navState: AppNavigationState
    
    var body: some View {
        ZStack{
            Color.kyBackground.ignoresSafeArea()
            Group{
                switch currentUser.authState {
                case .loading:
                    ProgressView()
                case .unauthenticated:
                    LoginView(showLogin: .constant(true))
                case .registrationPending:
                    Text("Registiration Pending")
//                    CompleteProfileView()   // e.g. collect missing patient info
                case .authenticated:
                    MainTabView()
                        .onAppear {
                            fs.startListeners(forClinicId: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")
                        }
                }
            }
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: currentUser.isAuthenticated
        )
    }
}
