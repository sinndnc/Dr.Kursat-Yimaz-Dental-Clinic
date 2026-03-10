//
//  NavigationState.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/8/26.
//

import Combine
import SwiftUI

enum AuthSheet: Identifiable {
    case auth
    case login
    case signUp
    
    var id: String { "\(self)" }
}

@Observable
class AppNavigationState {
    var isAuthenticated: Bool = false
    var authSheet: AuthSheet? = nil
    
    var selectedTab: AppTab = .home
    
    func navigateToTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    func presentAuth() {
        authSheet = .auth
    }
    
    func presentSignUp() {
        authSheet = .signUp
    }
    
    // ✅ Auth bitince bunu çağır — her şeyi sıfırlar
    func completeAuth() {
        isAuthenticated = true
        authSheet = nil
    }
    
    func logout() {
        isAuthenticated = false
    }
}
