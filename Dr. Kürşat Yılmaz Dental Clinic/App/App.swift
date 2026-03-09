//
//  DrKursatYilmazDentalClinicApp.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/4/26.
//

import SwiftUI

@main
struct DrKursatYilmazDentalClinicApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegateü
    
    @StateObject private var navState =  AppNavigationState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(navState)
        }
        
    }
}
