//
//  AuthFlowView.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/11/26.
//

import SwiftUI
import Combine

enum AuthRoute: Hashable {
    case signUp
    case forgotPassword
    case verifyEmail
}

struct AuthFlowView: View {
    let initialSheet: AuthSheet
    @Environment(AppNavigationState.self) private var appNav
    
    // Auth'un kendi internal path'i
    @State private var authPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $authPath) {
            Group {
                switch initialSheet {
                case .login:    LoginView()
                case .signUp:   SignUpView()
                case .auth: AuthSelectionView()
                }
            }
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:           SignUpView()
                case .forgotPassword:   ForgotPasswordView()
                case .verifyEmail:      EmptyView()
                }
            }
        }
    }
}
