//
//  DrKursatYilmazDentalClinicApp.swift
//  Dr. Kürşat Yılmaz Dental Clinic
//
//  Created by Sinan Dinç on 3/4/26.
//

import SwiftUI

@main
struct DrKursatYilmazDentalClinicApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var currentUser = CurrentUser()
    @StateObject private var navState =  AppNavigationState()
    
    @StateObject private var auth = AuthService.shared
    @StateObject private var firestore = FirestoreService.shared
    
    @StateObject private var seeder = MockDataSeeder()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    do{
                        try await seeder.uploadServices()
                    }catch{
                        
                    }
                }
                .environmentObject(auth)
                .environmentObject(navState)
                .environmentObject(firestore)
                .environmentObject(currentUser)
                .environment(\.currentUser, currentUser)
        }
        
    }
}
